#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use Env qw( POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD POSTGRES_HOST );
use DBI;

my ( $dbh_mysql );
my $dsn = "DBI:mysql:database=network_management;host=mysql;port=3306";

until ( $dbh_mysql ) {

	$dbh_mysql = DBI->connect($dsn, 'nm', 'Tripper');

	sleep 1;
	say 'waiting for database to allow connections';
}

$dbh_mysql->disconnect;

exec @ARGV;
