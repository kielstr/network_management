#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use Env qw( POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD POSTGRES_HOST );
use DBI;

my $dbh = DBI->connect( 
	"dbi:Pg:dbname=$POSTGRES_DB;host=$POSTGRES_HOST", 
	$POSTGRES_USER, 
	$POSTGRES_PASSWORD 
) ;

unless ( $dbh ) {
	exit 1;
}

$dbh->disconnect;

exit 0;
