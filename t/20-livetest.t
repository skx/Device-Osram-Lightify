#!/usr/bin/env perl

# Livetest:
# to run these tests export the IP of your hub to LIGHTIFY_LIVETEST_IP
# and optionally the MAC of a test lamp to LIGHTIFY_LIVETEST_MAC

use strict;
use warnings;

use Test::More;
use Time::HiRes 'sleep';


plan skip_all => 'LIGHTIFY_LIVETEST_IP not defined'
  unless $ENV{ LIGHTIFY_LIVETEST_IP };

plan tests => 12;

my $package = 'Device::Osram::Lightify::Hub';
use_ok $package or BAIL_OUT "Unable to load $package";

# hub and lamp

my $sleep = 0.2;    # slow down

ok my $hub = $package->new( host => $ENV{ LIGHTIFY_LIVETEST_IP } ),
  'Connect to hub';

ok my $mac = $ENV{ LIGHTIFY_LIVETEST_MAC } || ( $hub->lights )[0]->mac,
  'Set MAC for test lamp';

my $light;
subtest 'Switch on' => sub {
    ok $light = &_refresh, 'Load status';
    is $light->set_on, $light, 'Switch on';
    is $light->status, 'on', 'Status is on';
    ok $light = &_refresh, 'Refresh from hub';
    is $light->status, 'on', 'Status is on';
    sleep $sleep;
};

# brightness

subtest 'Brightness < 0' => sub {
    is $light->set_brightness(-1), $light, 'Set brightness to -1';
    is $light->brightness, 0, 'Brightness is 0';
    ok $light = &_refresh, 'Refresh from hub';
    is $light->brightness, 0, 'Brightness is 0';
    sleep $sleep;
};

subtest 'Brightness' => sub {
    for ( my $brightness = 0 ; $brightness <= 100 ; $brightness += 10 )
    {
        is $light->set_brightness($brightness), $light,
          "Set brightness to $brightness";
        is $light->brightness, $brightness, "Brightness is $brightness";
        ok $light = &_refresh, 'Refresh from hub';
        is $light->brightness, $brightness, "Brightness is $brightness";
        sleep $sleep;
    }
};

subtest 'Brightness > 100' => sub {
    is $light->set_brightness(101), $light, 'Set brightness to 101';
    is $light->brightness, 100, 'Brightness is 100';
    ok $light = &_refresh, 'Refresh from hub';
    is $light->brightness, 100, 'Brightness is 100';
    sleep $sleep;
};

# temperature

subtest 'Temperature < 2200' => sub {
    is $light->set_temperature(2199), $light, 'Set temperature to 2199';
    is $light->temperature, 2200, 'temperature is 2200';
    ok $light = &_refresh, 'Refresh from hub';
    is $light->temperature, 2200, 'temperature is 2200';
    sleep $sleep;
};

subtest 'Temperature' => sub {
    for ( my $temperature = 2200 ; $temperature <= 6500 ; $temperature += 430 )
    {
        is $light->set_temperature($temperature), $light,
          "Set temperature to $temperature";
        is $light->temperature, $temperature, "temperature is $temperature";
        ok $light = &_refresh, 'Refresh from hub';
        is $light->temperature, $temperature, "temperature is $temperature";
        sleep $sleep;
    }
};

subtest 'Temperature > 6500' => sub {
    is $light->set_temperature(6501), $light, 'Set temperature to 6501';
    is $light->temperature, 6500, 'temperature is 6500';
    ok $light = &_refresh, 'Refresh from hub';
    is $light->temperature, 6500, 'temperature is 6500';
    sleep $sleep;
};

# RGBW

my @colors = ( [255, 0,   0,   255],
               [255, 64,  0,   255],
               [255, 128, 0,   255],
               [255, 191, 0,   255],
               [255, 255, 0,   255],
               [191, 255, 0,   255],
               [128, 255, 0,   255],
               [64,  255, 0,   255],
               [0,   255, 0,   255],
               [0,   255, 64,  255],
               [0,   255, 128, 255],
               [0,   255, 191, 255],
               [0,   255, 255, 255],
               [0,   191, 255, 255],
               [0,   128, 255, 255],
               [0,   64,  255, 255],
               [0,   0,   255, 255],
               [64,  0,   255, 255],
               [128, 0,   255, 255],
               [191, 0,   255, 255],
               [255, 0,   255, 255],
               [255, 0,   191, 255],
               [255, 0,   128, 255],
               [255, 0,   64,  255],
               [255, 0,   0,   255],
             );

subtest 'Colors' => sub {
    for my $color (@colors)
    {
        my $color_string = join ',', $color->@*;
        is $light->set_rgbw( $color->@* ), $light, "Set color to $color_string";
        is $light->rgbw, $color_string, "Color is $color_string";
        ok $light = &_refresh, 'Refresh from hub';
        is $light->rgbw, $color_string, "Color is $color_string";
        sleep $sleep;
    }
};

# switch off

subtest 'Switch off' => sub {
    ok $light = &_refresh, 'Load status';
    is $light->set_off, $light, 'Switch off';
    is $light->status, 'off', 'Status is off';
    ok $light = &_refresh, 'Refresh from hub';
    is $light->status, 'off', 'Status is off';
};

# internal functions

sub _refresh
{
    for ( $hub->lights )
    {
        return $_ if $_->mac eq $mac;
    }
}
