#====================================================================
# LX-Office ERP
# Copyright (C) 2004
# Based on SQL-Ledger Version 2.1.9
# Web http://www.lx-office.org
#
#====================================================================

package Common;

use Time::HiRes qw(gettimeofday);

use vars qw(@db_encodings %db_encoding_to_charset);

@db_encodings = (
  { "label" => "ASCII",          "dbencoding" => "SQL_ASCII", "charset" => "ASCII" },
  { "label" => "UTF-8 Unicode",  "dbencoding" => "UNICODE",   "charset" => "UTF-8" },
  { "label" => "ISO 8859-1",     "dbencoding" => "LATIN1",    "charset" => "ISO-8859-1" },
  { "label" => "ISO 8859-2",     "dbencoding" => "LATIN2",    "charset" => "ISO-8859-2" },
  { "label" => "ISO 8859-3",     "dbencoding" => "LATIN3",    "charset" => "ISO-8859-3" },
  { "label" => "ISO 8859-4",     "dbencoding" => "LATIN4",    "charset" => "ISO-8859-4" },
  { "label" => "ISO 8859-5",     "dbencoding" => "LATIN5",    "charset" => "ISO-8859-5" },
  { "label" => "ISO 8859-15",    "dbencoding" => "LATIN9",    "charset" => "ISO-8859-15" },
  { "label" => "KOI8-R",         "dbencoding" => "KOI8",      "charset" => "KOI8-R" },
  { "label" => "Windows CP1251", "dbencoding" => "WIN",       "charset" => "CP1251" },
  { "label" => "Windows CP866",  "dbencoding" => "ALT",       "charset" => "CP866" },
);

%db_encoding_to_charset = map { $_->{dbencoding}, $_->{charset} } @db_encodings;

use constant DEFAULT_CHARSET => 'ISO-8859-15';

sub unique_id {
  my ($a, $b) = gettimeofday();
  return "${a}-${b}-${$}";
}

sub tmpname {
  return "/tmp/lx-office-tmp-" . unique_id();
}

sub retrieve_parts {
  $main::lxdebug->enter_sub();

  my ($self, $myconfig, $form, $order_by, $order_dir) = @_;

  my $dbh = $form->dbconnect($myconfig);

  my (@filter_values, $filter);
  if ($form->{"partnumber"}) {
    $filter .= qq| AND (partnumber ILIKE ?)|;
    push(@filter_values, '%' . $form->{"partnumber"} . '%');
  }
  if ($form->{"description"}) {
    $filter .= qq| AND (description ILIKE ?)|;
    push(@filter_values, '%' . $form->{"description"} . '%');
  }
  substr($filter, 1, 3) = "WHERE" if ($filter);

  $order_by =~ s/[^a-zA-Z_]//g;
  $order_dir = $order_dir ? "ASC" : "DESC";

  my $query =
    qq|SELECT id, partnumber, description | .
    qq|FROM parts $filter | .
    qq|ORDER BY $order_by $order_dir|;
  my $sth = $dbh->prepare($query);
  $sth->execute(@filter_values) || $form->dberror($query . " (" . join(", ", @filter_values) . ")");
  my $parts = [];
  while (my $ref = $sth->fetchrow_hashref()) {
    push(@{$parts}, $ref);
  }
  $sth->finish();
  $dbh->disconnect();

  $main::lxdebug->leave_sub();

  return $parts;
}

sub retrieve_projects {
  $main::lxdebug->enter_sub();

  my ($self, $myconfig, $form, $order_by, $order_dir) = @_;

  my $dbh = $form->dbconnect($myconfig);

  my (@filter_values, $filter);
  if ($form->{"projectnumber"}) {
    $filter .= qq| AND (projectnumber ILIKE ?)|;
    push(@filter_values, '%' . $form->{"projectnumber"} . '%');
  }
  if ($form->{"description"}) {
    $filter .= qq| AND (description ILIKE ?)|;
    push(@filter_values, '%' . $form->{"description"} . '%');
  }
  substr($filter, 1, 3) = "WHERE" if ($filter);

  $order_by =~ s/[^a-zA-Z_]//g;
  $order_dir = $order_dir ? "ASC" : "DESC";

  my $query =
    qq|SELECT id, projectnumber, description | .
    qq|FROM project $filter | .
    qq|ORDER BY $order_by $order_dir|;
  my $sth = $dbh->prepare($query);
  $sth->execute(@filter_values) || $form->dberror($query . " (" . join(", ", @filter_values) . ")");
  my $projects = [];
  while (my $ref = $sth->fetchrow_hashref()) {
    push(@{$projects}, $ref);
  }
  $sth->finish();
  $dbh->disconnect();

  $main::lxdebug->leave_sub();

  return $projects;
}

sub retrieve_employees {
  $main::lxdebug->enter_sub();

  my ($self, $myconfig, $form, $order_by, $order_dir) = @_;

  my $dbh = $form->dbconnect($myconfig);

  my (@filter_values, $filter);
  if ($form->{"name"}) {
    $filter .= qq| AND (name ILIKE ?)|;
    push(@filter_values, '%' . $form->{"name"} . '%');
  }
  substr($filter, 1, 3) = "WHERE" if ($filter);

  $order_by =~ s/[^a-zA-Z_]//g;
  $order_dir = $order_dir ? "ASC" : "DESC";

  my $query =
    qq|SELECT id, name | .
    qq|FROM employee $filter | .
    qq|ORDER BY $order_by $order_dir|;
  my $sth = $dbh->prepare($query);
  $sth->execute(@filter_values) || $form->dberror($query . " (" . join(", ", @filter_values) . ")");
  my $employees = [];
  while (my $ref = $sth->fetchrow_hashref()) {
    push(@{$employees}, $ref);
  }
  $sth->finish();
  $dbh->disconnect();

  $main::lxdebug->leave_sub();

  return $employees;
}

sub retrieve_delivery_customer {
  $main::lxdebug->enter_sub();

  my ($self, $myconfig, $form, $order_by, $order_dir) = @_;

  my $dbh = $form->dbconnect($myconfig);

  my (@filter_values, $filter);
  if ($form->{"name"}) {
    $filter .= qq| (name ILIKE ?) AND|;
    push(@filter_values, '%' . $form->{"name"} . '%');
  }

  $order_by =~ s/[^a-zA-Z_]//g;
  $order_dir = $order_dir ? "ASC" : "DESC";

  my $query =
    qq!SELECT id, name, customernumber, (street || ', ' || zipcode || city) AS address ! .
    qq!FROM customer ! .
    qq!WHERE $filter business_id = (SELECT id FROM business WHERE description = 'Endkunde') ! .
    qq!ORDER BY $order_by $order_dir!;
  my $sth = $dbh->prepare($query);
  $sth->execute(@filter_values) ||
    $form->dberror($query . " (" . join(", ", @filter_values) . ")");
  my $delivery_customers = [];
  while (my $ref = $sth->fetchrow_hashref()) {
    push(@{$delivery_customers}, $ref);
  }
  $sth->finish();
  $dbh->disconnect();

  $main::lxdebug->leave_sub();

  return $delivery_customers;
}

sub retrieve_vendor {
  $main::lxdebug->enter_sub();

  my ($self, $myconfig, $form, $order_by, $order_dir) = @_;

  my $dbh = $form->dbconnect($myconfig);

  my (@filter_values, $filter);
  if ($form->{"name"}) {
    $filter .= qq| (name ILIKE ?) AND|;
    push(@filter_values, '%' . $form->{"name"} . '%');
  }

  $order_by =~ s/[^a-zA-Z_]//g;
  $order_dir = $order_dir ? "ASC" : "DESC";

  my $query =
    qq!SELECT id, name, customernumber, (street || ', ' || zipcode || city) AS address FROM customer ! .
    qq!WHERE $filter business_id = (SELECT id FROM business WHERE description = 'H�ndler') ! .
    qq!ORDER BY $order_by $order_dir!;
  my $sth = $dbh->prepare($query);
  $sth->execute(@filter_values) ||
    $form->dberror($query . " (" . join(", ", @filter_values) . ")");
  my $vendors = [];
  while (my $ref = $sth->fetchrow_hashref()) {
    push(@{$vendors}, $ref);
  }
  $sth->finish();
  $dbh->disconnect();

  $main::lxdebug->leave_sub();

  return $vendors;
}

sub mkdir_with_parents {
  $main::lxdebug->enter_sub();

  my ($full_path) = @_;

  my $path = "";

  $full_path =~ s|/+|/|;

  foreach my $part (split(m|/|, $full_path)) {
    $path .= "/" if ($path);
    $path .= $part;

    die("Could not create directory '$path' because a file exists with " .
        "the same name.\n") if (-f $path);

    if (! -d $path) {
      mkdir($path, 0770) || die("Could not create the directory '$path'. " .
                                "OS error: $!\n");
    }
  }

  $main::lxdebug->leave_sub();
}

sub webdav_folder {
  $main::lxdebug->enter_sub();

  my ($form) = @_;

  return $main::lxdebug->leave_sub()
    unless ($main::webdav && $form->{id});

  my ($path, $number);

  $form->{WEBDAV} = {};

  if ($form->{type} eq "sales_quotation") {
    ($path, $number) = ("angebote", $form->{quonumber});
  } elsif ($form->{type} eq "sales_order") {
    ($path, $number) = ("bestellungen", $form->{ordnumber});
  } elsif ($form->{type} eq "request_quotation") {
    ($path, $number) = ("anfragen", $form->{quonumber});
  } elsif ($form->{type} eq "purchase_order") {
    ($path, $number) = ("lieferantenbestellungen", $form->{ordnumber});
  } elsif ($form->{type} eq "credit_note") {
    ($path, $number) = ("gutschriften", $form->{invnumber});
  } elsif ($form->{vc} eq "customer") {
    ($path, $number) = ("rechnungen", $form->{invnumber});
  } else {
    ($path, $number) = ("einkaufsrechnungen", $form->{invnumber});
  }

  return $main::lxdebug->leave_sub() unless ($path && $number);

  $path = "webdav/${path}/${number}";

  if (!-d $path) {
    mkdir_with_parents($path);

  } else {
    my $base_path = substr($ENV{'SCRIPT_NAME'}, 1);
    $base_path =~ s|[^/]+$||;

    foreach my $file (<$path/*>) {
      my $fname = $file;
      $fname =~ s|.*/||;
      $form->{WEBDAV}{$fname} =
        ($ENV{"HTTPS"} ? "https://" : "http://") .
        $ENV{'SERVER_NAME'} . "/" . $base_path . $file;
    }
  }

  $main::lxdebug->leave_sub();
}

1;
