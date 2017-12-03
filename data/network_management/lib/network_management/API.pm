package network_management::API;
use Dancer2;
use Dancer2::Plugin::Database;

use Try::Tiny;
use Data::Dumper 'Dumper';
use Minion;

use feature 'say';
our $VERSION = '0.1';


set serializer => 'JSON';


get '/' => sub {  
    #return Dancer2::Core::HTTP->status_message(500);
    status 500;
    #return {'status' => 'alive'};
};

get '/create_control_network' => sub {
    my $minion = Minion->new(Pg => 'postgresql://mic:mic@postgres/mic');
    my $id = $minion->enqueue( create_control_network => [ 'svn', 'image_name', 'image_tag' ]);

    return {job_id => $id};
};

post '/add-queue' => sub {
    my $params = params;
    my $database = database;
    my @successful;

    my $err = {
        code => undef,
        text => [],
    };

    my $sql = qq/
        INSERT INTO queue (
            owner, 
            queue_id,
            rate, 
            ceiling,
            prio
        ) values (
            ?,
            ?,
            ?,
            ?,
            ?
        )
    /;


    for my $client ( @{ $params->{queues} } ) {
        
        for my $requirement ( qw(owner queue_id rate ceiling) ) {
            unless ( defined $client->{$requirement} ) {
                my $message = $client->{ 'macaddr' } . ' -- missing ' . $requirement;

                push @{ $err->{ 'text' } }, $message;

                $err->{ 'code' } = 400;

                error $message;
            }
        }

        unless ( $err->{ 'code' } == 400 ) {
            try {
               $database->do( $sql, {}, 
                    $client->{ 'owner' },
                    $client->{ 'queue_id' },
                    $client->{ 'rate' },
                    $client->{ 'ceiling' },
                    $client->{ 'prio' }
                );

               push @successful, $client->{ 'macaddr' };

            } catch {
                my $code = $database->err;

                if ( $code == 1062 ) {
                    push @{ $err->{ 'text' } }, $client->{ 'macaddr' } . ' -- duplicate key. check macaddr, ip and hostname are not already in the system';
                }
         
                info 'failed to insert into the database ' . $_;

                $err->{ 'code' } = 401;
                push @{ $err->{ 'text' } }, $client->{ 'macaddr' } . ' -- Backend failure please try again';
            }
        }
    }

    my $return = {
        status => $err->{ 'code' } ? $err->{ 'code' } : 200,
    };

    $return->{ clients_successful } = int @successful
        if @successful;

    if ( $err->{ 'code' } ) {
        status $err->{ 'code' };
        $return->{ error_msg } = $err->{ 'text' };
    } 

    return $return;
};

post '/add-client' => sub {
    my $params = params;
    my $database = database;
    my @successful;

    my $err = {
        code => undef,
        text => [],
    };

    my $sql = qq/
        INSERT INTO client (
            macaddr, 
            hostname, 
            ip, 
            owner, 
            rate, 
            ceiling, 
            queue_id,
            prio
        ) values (
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?
        )
    /;

    for my $client ( @{ $params->{clients} } ) {
        
        for my $requirement ( qw(macaddr ip queue_id rate ceiling hostname owner) ) {
            unless ( defined $client->{$requirement} ) {
                my $message = $client->{ 'macaddr' } . ' -- missing ' . $requirement;

                push @{ $err->{ 'text' } }, $message;

                $err->{ 'code' } = 400;

                error $message;
            }
        }

        unless ( defined $err->{ 'code' } and $err->{ 'code' } == 400 ) {
            try {
               $database->do( $sql, {}, 
                    $client->{ 'macaddr' },
                    $client->{ 'hostname' },
                    $client->{ 'ip' },
                    $client->{ 'owner' },
                    $client->{ 'rate' },
                    $client->{ 'ceiling' },
                    $client->{ 'queue_id' },
                    ($client->{ 'prio' } ? $client->{ 'prio' } : 1 )

                );

               push @successful, $client->{ 'macaddr' };

            } catch {
                my $code = $database->err;

                if ( $code == 1062 ) {
                    push @{ $err->{ 'text' } }, $client->{ 'macaddr' } . ' -- duplicate key. check macaddr, ip and hostname are not already in the system';
                }
         
                info 'failed to insert into the database ' . $_;

                $err->{ 'code' } = 401;
                push @{ $err->{ 'text' } }, $client->{ 'macaddr' } . ' -- Backend failure please try again';
            }
        }
    }

    my $return = {
        status => $err->{ 'code' } ? $err->{ 'code' } : 200,
    };

    $return->{ clients_successful } = int @successful
        if @successful;

    if ( defined $err->{ 'code' } and $err->{ 'code' } ) {
        status $err->{ 'code' };
        $return->{ error_msg } = $err->{ 'text' };
    } 

    return $return;
};

true;
