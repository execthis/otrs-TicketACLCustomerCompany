# --
# TicketACLCustomerCompany.pm - code to excecute during package installation
# Copyright (C) 2016 Perl-Services.de, http://perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package var::packagesetup::TicketACLCustomerCompany;

use strict;
use warnings;

use utf8;

use List::Util qw(first);

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::System::SysConfig
    Kernel::System::Valid
);

=head1 NAME

TicketACLCustomerCompany.pm - code to excecute during package installation

=head1 SYNOPSIS

All functions

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # create needed sysconfig object
    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');

    # rebuild ZZZ* files
    $SysConfigObject->WriteDefault();

    # define the ZZZ files
    my @ZZZFiles = (
        'ZZZAAuto.pm',
        'ZZZAuto.pm',
    );

    # reload the ZZZ files (mod_perl workaround)
    for my $ZZZFile (@ZZZFiles) {

        PREFIX:
        for my $Prefix (@INC) {
            my $File = $Prefix . '/Kernel/Config/Files/' . $ZZZFile;
            next PREFIX if !-f $File;
            do $File;
            last PREFIX;
        }
    }

    return $Self;
}

=item CodeInstall()

run the code install part

    my $Result = $CodeObject->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

    # create dynamic fields 
    $Self->_DoSysConfigChanges();

    return 1;
}

=item CodeReinstall()

run the code reinstall part

    my $Result = $CodeObject->CodeReinstall();

=cut

sub CodeReinstall {
    my ( $Self, %Param ) = @_;

    return 1;
}

=item CodeUpgrade()

run the code upgrade part

    my $Result = $CodeObject->CodeUpgrade();

=cut

sub CodeUpgrade {
    my ( $Self, %Param ) = @_;

    $Self->_DoSysConfigChanges();

    return 1;
}

=item CodeUninstall()

run the code uninstall part

    my $Result = $CodeObject->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_;

    $Self->_DoSysConfigChanges( Uninstall => 1 );

    return 1;
}

=item _DoSysConfigChanges()

=cut

sub _DoSysConfigChanges {
    my ($Self, %Param) = @_;

    my $SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');
    my $ConfigObject    = $Kernel::OM->Get('Kernel::Config');

    OPTION:
    for my $Option ( qw(ACLKeysLevel2::Properties ACLKeysLevel2::PropertiesDatabase) ) {
        my $Setting = $ConfigObject->Get($Option);

        next OPTION if !$Setting;

        $Setting->{CustomerCompany} = 'CustomerCompany';

        if ( $Param{Uninstall} ) {
            delete $Setting->{CustomerCompany};
        }

        $SysConfigObject->ConfigItemUpdate(
            Valid => 1,
            Key   => $Option,
            Value => $Setting,
        );
    }
}

1;

=back

=head1 TERMS AND CONDITIONS

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/gpl-2.0.txt>.

=cut

