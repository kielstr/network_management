package network_management;
use Dancer2;
use Dancer2::Plugin::Database;

use Data::Dumper 'Dumper';

use feature 'say';
our $VERSION = '0.1';

get '/' => sub {
    my $database = database;

    my $clients = $database->selectall_hashref('SELECT * FROM client', 'id');

    say STDERR Dumper $clients;
    
    template 'index' => { 'title' => 'network_manangement' };
};

get '/add-client' => sub {
    my $params = params;
    my $database = database;

    my $macaddr = $params->{macaddr};
    my $ip = $params->{ip};
    my $queue = $params->{queue};
    my $rate = $params->{rate};
    my $ceiling = $params->{ceiling};
    my $dnsname = $params->{dnsname};
    my $owner = $params->{owner};
    
    my $sql = qq/
        INSERT INTO client (
            macaddr, 
            dnsname, 
            ip, 
            owner, 
            rate, 
            ceiling, 
            queue
        ) values (
    / 
    . join(',', $database->quote($macaddr), $database->quote($dnsname), $database->quote($ip), $database->quote($owner), $database->quote($rate), $database->quote($ceiling), $database->quote($queue))
    . ')';
    
    say STDERR $sql;
    
    $database->do( $sql );
    
    say STDERR Dumper $params;
    template 'index' => { 'title' => 'network_manangement' };
};

true;
