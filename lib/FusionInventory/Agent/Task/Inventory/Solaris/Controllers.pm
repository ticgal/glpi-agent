package FusionInventory::Agent::Task::Inventory::Solaris::Controllers;

use strict;
use warnings;

use parent 'FusionInventory::Agent::Task::Inventory::Module';

use FusionInventory::Agent::Tools;

sub isEnabled {
    my (%params) = @_;
    return if $params{no_category}->{controller};
    return canRun('cfgadm');
}

sub doInventory {
    my (%params) = @_;

    my $inventory = $params{inventory};
    my $logger    = $params{logger};

    my $handle = getFileHandle(
        command => 'cfgadm -s cols=ap_id:type:info',
        logger  => $logger,
    );

    return unless $handle;

    while (my $line = <$handle>) {
        next if $line =~  /^Ap_Id/;
        next unless $line =~ /^(\S+)\s+(\S+)\s+(\S+)/;
        my $name = $1;
        my $type = $2;
        my $manufacturer = $3;
        $inventory->addEntry(
            section => 'CONTROLLERS',
            entry => {
                NAME         => $name,
                MANUFACTURER => $manufacturer,
                TYPE         => $type,
            }
        );
    }
    close $handle;
}

1;
