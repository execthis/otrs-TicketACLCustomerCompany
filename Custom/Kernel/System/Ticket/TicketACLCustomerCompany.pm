# --
# Kernel/System/Ticket/TicketACLCustomerCompany.pm - all ticket functions
# Copyright (C) 2016 Perl-Services.de, http://perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::TicketACLCustomerCompany;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our $ObjectManagerDisabled = 1;

{
    no warnings 'redefine';

    my $Code = Kernel::System::Ticket->can('_GetChecks');

    sub Kernel::System::Ticket::_GetChecks {
        my ( $Self, %Param ) = @_;

        my $Return = $Self->Kernel::System::Ticket::TicketACL::_GetChecks( %Param );

        my $CheckAll       = $Param{CheckAll};
        my %RequiredChecks = %{ $Param{RequiredChecks} };

        my $CompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');

        if ( ( $CheckAll || $RequiredChecks{CustomerCompany} ) && $Param{CustomerID} ) {
            my %Company = $CompanyObject->CustomerCompanyGet(
                CustomerID => $Param{CustomerID},
            );

            $Return->{Checks}->{CustomerCompany}        = \%Company;
            $Return->{Checks}->{Ticket}->{CustomerName} = $Company{CustomerCompanyName};
        }

        if (
            ( $CheckAll || $RequiredChecks{CustomerCompany} )
            && IsPositiveInteger( $Return->{ChecksDatabase}->{Ticket}->{CustomerID} )
            )
        {
            my %Company = $CompanyObject->CustomerCompanyGet(
                CustomerID => $Return->{ChecksDatabase}->{Ticket}->{CustomerID},
            );

            $Return->{ChecksDatabase}->{CustomerCompany}        = \%Company;
            $Return->{ChecksDatabase}->{Ticket}->{CustomerName} = $Company{CustomerCompanyName};
        }

        return $Return;
    }
}

1;
