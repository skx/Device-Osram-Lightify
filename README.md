Device::Osram::Lightify
=======================

This module allows an Osram Lightify system to be controlled by Pure
Perl.

It is assumed that you will have paired your hub with all your bulbs,
and otherwise completed the setup of your system via the mobile
application before you use this code.

This code allows you to retrieve all the known-lights, by querying
your local hub, allowing their state to be examined and modified.


# Current Status

* Introspection works such that you can dynamically retrieve all known
bulbs and their state:
     * On vs. Off
     * Brightness
     * Temperature
     * MAC address
     * Firmware Version
     * Name.
     * R,G,B,W values.
* Sending "all on" works.
* Sending "all off" works.
* You can set a specific light on, or off.
* You can change the brightness of a specific bulb.

TODO

* Set the colour of a specific bulb.
* Set the temperature of a specific bulb.

# Simple Example

These examples all talk to the hub at IP address `192.168.10.136`,
you'd obviously specify the IP to your own hub there!

Turn all devices off:

    #!/usr/bin/perl

    use Device::Osram::Lightify::Hub;

    my $x = Device::Osram::Lightify::Hub->new( host => "192.168.10.136" );
    $x->all_off();

Or turn on only the bulb with name `hall`:

    #!/usr/bin/perl
    use Device::Osram::Lightify::Hub;

    my $x = Device::Osram::Lightify::Hub->new( host => "192.168.10.136" );

    foreach my $light ( $x->lights() ) {
        if ( $light->name() eq "hall" ) {
            $light->off();
            exit(0);
        }
    }


Steve
--
