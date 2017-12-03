#!/usr/bin/env perl
use strict;
use warnings;
use Minion;
use Data::Dumper 'Dumper';
use feature 'say';

# Connect to backend
my $minion = Minion->new(Pg => 'postgresql://mic:mic@kiels-laptop/mic');

# Add tasks
my $id = $minion->enqueue(build_img => [ 'svn', 'image_name', 'image_tag']);

my $job = $minion->job($id);

# Check job state
until ( $job->info->{state} ne 'active' ) {
    sleep 1;
}

my $state = $job->info->{state};

say "state: $state";
