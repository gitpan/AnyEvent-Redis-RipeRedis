#!/usr/bin/perl

use strict;
use warnings;

use AnyEvent;
use AnyEvent::Redis::RipeRedis;

my $cv = AE::cv();

my $redis = AnyEvent::Redis::RipeRedis->new(
  host => 'localhost',
  port => '6379',
  password => 'your_password',

  on_connect => sub {
    print "Connected to Redis server\n";
  },

  on_disconnect => sub {
    print "Disconnected from Redis server\n";
  },

  on_error => sub {
    my $err_msg = shift;
    my $err_code = shift;
    warn "$err_msg. Error code: $err_code\n";
  },
);

# Execute Lua script
$redis->eval_cached( 'return { KEYS[1], KEYS[2], ARGV[1], ARGV[2] }',
    2, 'key1', 'key2', 'first', 'second', {
  on_done => sub {
    my $data = shift;
    foreach my $val ( @{$data}  ) {
      print "$val\n";
    }
    $cv->send();
  }
} );

$cv->recv();

$redis->disconnect();