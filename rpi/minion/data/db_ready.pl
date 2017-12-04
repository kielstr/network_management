#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use Env qw( POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD POSTGRES_HOST );
use DBI;

my ( $dbh_pg );

until ( $dbh_pg ) {

	$dbh_pg = DBI->connect( 
		"dbi:Pg:dbname=mic;host=postgres", 
		'mic',
		'mic'
	) ;

	sleep 1;
	say 'waiting for database to allow connections';
}

$dbh_pg->disconnect;

exec @ARGV;