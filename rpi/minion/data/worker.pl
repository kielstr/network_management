#!/usr/bin/env perl

use strict;
use warnings;
use Minion;
use Data::Dumper 'Dumper';
use Env qw(CONNECTION_STRING NUMBER_OF_JOBS);
use feature 'say';
use DBI;


# tc -s -d class show dev eth0
# watch  tc -s -d class show dev eth0

say "CONNECTION_STRING: $CONNECTION_STRING";
say "NUMBER_OF_JOBS: $NUMBER_OF_JOBS";

my $dsn = "dbi:Pg:dbname=network_management;host=postgres";

my $minion = Minion->new( Pg => $CONNECTION_STRING );
my $dbh = DBI->connect($dsn, 'mic', 'mic') or die DBI->errstr;

$minion->add_task(create_control_network => sub {

	open my $output_file, '>', '/data/control_network' or die $!;

	my ( $job, @args ) = @_;

	my $queues = $dbh->selectall_hashref('SELECT * FROM queue', 'id')
		or die $dbh->errstr;

	my $clients = $dbh->selectall_hashref('SELECT b.queue_id as parent_id, a.queue_id as class_id, a.rate as rate, a.ceiling as ceiling, a.prio as prio, a.hostname as hostname FROM client a JOIN queue b ON a.owner = b.owner', 'class_id')
		or die $dbh->errstr;

	print $output_file _gen_header();

	for my $parent_id ( keys %$queues ) {
		my $queue_cfg = $queues->{$parent_id};
		print $output_file _gen_parent_queue($queue_cfg->{queue_id}, $queue_cfg->{rate}, $queue_cfg->{ceiling}, $queue_cfg->{prio});

	}
	
	for my $client_id ( keys %$clients ) {
		print $output_file _gen_client( map { $clients->{ $client_id }{ $_ } } qw(parent_id class_id rate ceiling prio hostname) );
	}
	
	print $output_file _gen_footer();

	say "Created file control_network";

	$output_file->close;

});

sub _gen_header {

return qq~	
### IPTABLES ####
#

# Clear NAT
iptables -t nat -F

# Forward all httpd traffic to www
#iptables -t nat -A PREROUTING -p tcp -d 192.168.1.10 --dport 80 -j \
#	DNAT --to-destination 10.0.0.4:80

# Forward for server network
iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE

# Users
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth0 -j MASQUERADE

# second WiFi network
iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -o eth0 -j MASQUERADE

# Clear marking rules
iptables -t mangle -F

# Clear chains
iptables -F

# if its LAN traffic do nothing 
iptables -A INPUT -d 192.168.1.10 -s 10.0.0.0/24 -j RETURN
iptables -A INPUT -d 192.168.1.10 -s 192.168.1.0/24 -j RETURN
iptables -A INPUT -d 192.168.1.10 -s 192.168.2.0/24 -j RETURN

#
## Packet shapping
#

# Clear out queues.
tc qdisc del dev eth0 root

# Create qdisc
tc qdisc add dev eth0 root handle 1: htb default 1

# Add root class
tc class add dev eth0 parent 1: classid 1:1 htb rate 100mbit ceil 100mbit

~;
}
sub _gen_parent_queue {
	my ($class_id, $rate, $ceiling, $prio) = @_;

return qq/
####
tc class add dev eth0 parent 1:1 classid $class_id htb rate $rate ceil $ceiling prio $prio
/;

}

sub _gen_client {
	my ( $parent_class, $class_id, $rate, $ceiling, $prio, $hostname ) = @_;
	my ( undef, $fw_mark ) = split ':', $class_id;
qq/
tc class add dev eth0 parent $parent_class classid $class_id htb rate $rate ceil $ceiling prio $prio
tc filter add dev eth0 parent 1:0 protocol ip prio $prio handle $fw_mark fw classid $class_id

iptables -t mangle -A POSTROUTING -d $hostname -j MARK --set-mark $fw_mark
iptables -t mangle -A POSTROUTING -d $hostname -j RETURN
/;

}

sub _gen_footer {
qq~
#####################################################
# ALL DYNAMIC HOSTS (192.168.1.100 - 192.168.1.200)
#

# Q_ID: 1:70 DHCP unassigned (visitors)

tc class add dev eth0 parent 1:1 classid 1:70 htb rate 2mbit ceil 4mbit prio 3
tc filter add dev eth0 parent 1:0 protocol ip prio 3 handle 70 fw classid 1:70

iptables -t mangle -A POSTROUTING -d 192.168.1.0/24 -j MARK --set-mark 70
iptables -t mangle -A POSTROUTING -d 192.168.1.0/24 -j RETURN

##########################################################################################
# Rest of the traffic from the internet. Host on 10.0.0.0/24 and 192.168.2.0/24 hit this
# queue.

# Q_ID: 1:80 10.0.0.0/24 and 192.168.2.0/24 (servers and wifi #2)

tc class add dev eth0 parent 1:1 classid 1:80 htb rate 12mbit ceil 12mbit prio 1
tc filter add dev eth0 parent 1:0 protocol ip prio 1 handle 80 fw classid 1:80

iptables -t mangle -A PREROUTING ! -s 10.0.0.0/24 -d 192.168.1.10 -j MARK --set-mark 80
iptables -t mangle -A PREROUTING ! -s 10.0.0.0/24 -d 192.168.1.10 -j RETURN

iptables -t mangle -A PREROUTING ! -s 192.168.1.0/24 -d 192.168.1.10 -j MARK --set-mark 80
iptables -t mangle -A PREROUTING ! -s 192.168.1.0/24 -d 192.168.1.10 -j RETURN

iptables -t mangle -A PREROUTING ! -s 192.168.2.0/24 -d 192.168.1.10 -j MARK --set-mark 80
iptables -t mangle -A PREROUTING ! -s 192.168.2.0/24 -d 192.168.1.10 -j RETURN

############################
# INTERNET TRAFFIC UPLOADS

# When the src address is the gateway and the dst addr is not one of our networks
#  then its an internet upload

# Q_ID: 1:90 -- all internet uploads (all ips)

tc class add dev eth0 parent 1:1 classid 1:90 htb rate 500kbit ceil 1mbit prio 4
tc filter add dev eth0 parent 1:0 protocol ip prio 4 handle 90 fw classid 1:90

iptables -t mangle -A POSTROUTING -s 192.168.1.10 ! -d 10.0.0.0/24 -j MARK --set-mark 90
iptables -t mangle -A POSTROUTING -s 192.168.1.10 ! -d 10.0.0.0/24 -j RETURN

iptables -t mangle -A POSTROUTING -s 192.168.1.10 ! -d 192.168.1.0/24 -j MARK --set-mark 90
iptables -t mangle -A POSTROUTING -s 192.168.1.10 ! -d 192.168.1.0/24 -j RETURN

iptables -t mangle -A POSTROUTING -s 192.168.1.10 ! -d 192.168.2.0/24 -j MARK --set-mark 90
iptables -t mangle -A POSTROUTING -s 192.168.1.10 ! -d 192.168.2.0/24 -j RETURN
~;
}

my $worker = $minion->worker;

$worker->status->{jobs} = $NUMBER_OF_JOBS;

say "Minion worker starting.";
$worker->run;

$dbh->disconnect;
