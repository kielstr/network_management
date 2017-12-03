#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use network_management;
use network_management::API;

use Plack::Builder;
use Plack::Middleware::ReverseProxy;
use Plack::Middleware::ReverseProxyPath;

builder {
    enable 'Deflater';
    mount '/' => network_management->to_app;
    mount '/api' => network_management::API->to_app;
}



=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use network_manangement;
use Plack::Builder;

builder {
    enable 'Deflater';
    network_manangement->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use network_manangement;
use network_manangement_admin;

builder {
    mount '/'      => network_manangement->to_app;
    mount '/admin'      => network_manangement_admin->to_app;
}

=end comment

=cut

