  #!/usr/bin/perl

  use strict;
  use DBI;

  # Connect to the database.
  my $dbh = DBI->connect("dbi:mysql:database=test;host=slug",
                         "scherer", "kks",
                         {'RaiseError' => 1});

  # Drop table 'foo'. This may fail, if 'foo' doesn't exist.
  # Thus we put an eval around it.
#   eval { $dbh->do("DROP TABLE foo") };
#  print "Dropping foo failed: $@\n" if $@;

  # Create a new table 'foo'. This must not fail, thus we don't
  # catch errors.

#  $dbh->do("CREATE TABLE foo  (key INT UNSIGNED NOT NULL AUTO_INCREMENT ,id INT, name VARCHAR(20))");

#  $dbh->do("CREATE TABLE `foo` ( `key` INT UNSIGNED NOT NULL AUTO_INCREMENT , `id` INT NOT NULL , `name` VARCHAR( 20 ) NOT NULL , PRIMARY KEY ( `key` )) TYPE = MYISAM ;");

  # INSERT some data into 'foo'. We are using $dbh->quote() for
  # quoting the name.
  $dbh->do("INSERT INTO foo VALUES ('' ,3, " . $dbh->quote("Tim") . ")");

  # Same thing, but using placeholders
  $dbh->do("INSERT INTO foo VALUES (?, ?, ?)", undef,'' , 4, "Jochen");

  # Now retrieve data from the table.
  my $sth = $dbh->prepare("SELECT * FROM foo");
  $sth->execute();
  while (my $ref = $sth->fetchrow_arrayref()) {
    print "Found a row: $ref->[0]  id = $ref->[1], name = $ref->[2]\n";
  }
  $sth->finish();

  # Disconnect from the database.
  $dbh->disconnect();


