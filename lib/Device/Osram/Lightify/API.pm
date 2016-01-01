=head1 NAME

Device::Osram::Lightify::API - API Documentation

=head1 API Overview

The starting point for using this module is that you have a hub with
an IP address upon your local LAN, which is able to communicate successfully
with any installed bulbs you have.

The module itself is responsible for talking to your hub, and sending
commands to it to initiate actions, or perform introspection, so you'll
need the IP address of your hub available.

=cut

=head1 Discovery

To discover the lights which are available to your hub we connect to
the hub on port 4000 and send the following binary string to it:

=for example begin

    0x0B 0x00 0x00 0x13 0x00 0x00 0x00 0x00 0x01 0x00 0x00 0x00 0x00

=for example end

Once sent we then read back a header.  The header contains 11 bytes
of reply.  From this header we read the 10th byte which will tell us
the number of bulbs which are available.

Once we know the number of bulbs we then continue to read 50 additional
bytes which are used to describe the bulb itself.

=for example begin

  01 - ID byte 1
  02 - ID byte 2
  03 - MAC Address 1
  04 - MAC Address 2
  05 - MAC Address 3
  05 - MAC Address 4
  06 - MAC Address 5
  07 - MAC Address 6
  08 - MAC Address 7
  09 - MAC Address 8
  10 - Bulb Type
  11 - Firmware Version 1
  12 - Firmware Version 2
  13 - Firmware Version 3
  14 - Firmware Version 4
  15 - Online/Offline
  16 - Group ID 1
  17 - Group ID 2
  18 - Status 0 == off, 1 == on
  19 - Brightness (0-100)
  20 - Temperature 1
  21 - Temperature 2
  22 - R
  23 - G
  24 - B
  25 - W
  26 - Name 1
  27 - Name 2
  28 - Name 3
  29 - Name 4
  30 - Name 5
  31 - Name 6
  .. - Name 15

=for example end

And that is how you learn the bulbs, and their current statuses!

=cut


=head1 Broadcast

There are two simple commands which will turn all bulbs on, or off.

To turn all bulbs on send this:

=for example begin

    0x0f 0x00 0x00 0x32 0x01 0x00 0x00 0x00 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0x01

=for example end

To turn all bulbs off send this:

=for example begin

    0x0f 0x00 0x00 0x32 0x01 0x00 0x00 0x00 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0x00

=for example end

In each case you must read back 20 bytes which will contain the result.

=cut


use strict;
use warnings;

1;
