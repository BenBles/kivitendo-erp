# This file has been auto-generated only because it didn't exist.
# Feel free to modify it at will; it will not be overwritten automatically.

package SL::DB::CustomVariable;

use strict;

use SL::DB::MetaSetup::CustomVariable;
use SL::DB::CustomVariableValidity;

__PACKAGE__->meta->initialize;

# Creates get_all, get_all_count, get_all_iterator, delete_all and update_all.
__PACKAGE__->meta->make_manager_class;

sub value {
  my $self = $_[0];
  my $type = $self->config->type;

  goto &bool_value      if $type eq 'boolean';
  goto &timestamp_value if $type eq 'timestamp';
  goto &number_value    if $type eq 'number';
  goto &text_value; # text and select
}

sub is_valid {
  my ($self) = @_;

  return SL::DB::Manager::CustomVariableValidity->get_all_count(config_id => $self->config_id, trans_id => $self->trans_id) == 0;
}

1;
