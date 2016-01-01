
=head1 NAME

Device::Osram::Lightify::Hub - Communicate with an Osram Lightify Hub

=head1 DESCRIPTION

This module allows basic operation of the Osram lightify bulbs,
via connections to the Osram hub.

=cut

=head1 SYNOPSIS

   use Device::Osram::Lightify;

   my $tmp = Device::Osram::Lightify::Hub->new( host => "1.2.3.4" );

   # Turn all devices on
   $tmp->all_on();

   # Turn all devices off
   $tmp->all_of();

=cut

=head1 DESCRIPTION

This module is work-in-progress and currently allows only global/broadcast
actions to be carried out, along with the discovery of nodes.

In the future it will be possible to control the nodes we've discovered
dynamically.

=cut

=head1 METHODS

=cut

use strict;
use warnings;

package Device::Osram::Lightify::Hub;

use IO::Socket::INET;
use Device::Osram::Lightify::Light;


=head2 new

Create a new hub-object, it is mandatory to provide a C<host> parameter
which will give the IP (and optional port) of the Osram hub.

=cut

sub new
{
    my ( $proto, %supplied ) = (@_);
    my $class = ref($proto) || $proto;

    my $self = {};
    bless( $self, $class );


    $self->{ 'host' } = $supplied{ 'host' } || die "Missing host parameter";

    return $self;
}


=head2 all_on

Switch all known nodes on.

=cut

sub all_on
{
    my ($self) = (@_);

    # Get the open socket
    $self->_connect() unless( $self->{'_socket'} );
    my $sock = $self->{ '_socket' };

    # Send the magic to initiate "All On"
    my $x = "";
    foreach my $char (
        qw! 0x0f 0x00 0x00 0x32 0x01 0x00 0x00 0x00 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0x01 !
      )
    {
        $x .= chr( hex($char) );
    }
    syswrite( $sock, $x, length($x) );

    # Read 8-byte header + 12-byte reply
    my $buffer = $self->_read(20);
}


=head2 all_off

Switch all known nodes off.

=cut

sub all_off
{
    my ($self) = (@_);

    # Get the open socket
    $self->_connect() unless( $self->{'_socket'} );
    my $sock = $self->{ '_socket' };

    # Send the magic to initiate "All Off"
    my $x = "";
    foreach my $char (
        qw! 0x0f 0x00 0x00 0x32 0x01 0x00 0x00 0x00 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0xff 0x00 !
      )
    {
        $x .= chr( hex($char) );
    }
    syswrite( $sock, $x, length($x) );

    # Read 8-byte header + 12-byte reply
    my $buffer = $self->_read(20);

}



=head2 lights

Return a new C<Osram::Lightify::Light> object for each of the lights
that could be discovered.

=cut

sub lights
{
    my ($self) = (@_);

    my @ret;

    # Get the open socket
    $self->_connect() unless( $self->{'_socket'} );
    my $sock = $self->{ '_socket' };

    # Send the magic to initiate a scan.
    my $x = "";
    foreach my $char (
         qw! 0x0B 0x00 0x00 0x13 0x00 0x00 0x00 0x00 0x01 0x00 0x00 0x00 0x00 !)
    {
        $x .= chr( hex($char) );
    }
    syswrite( $sock, $x, length($x) );

    # Read 8-byte header + 3 bytes reply
    my $buffer = $self->_read(11);

    # Eight byte header we ignore.
    # 0 = ??
    # 1 = ??
    # ... ??
    # 8 = ??
    # 9 = Number of bulbs
    # 10 = ??

    # The number of devices.
    my $count = ord( substr( $buffer, 9, 1 ) );

    # For each one.
    while ($count)
    {
        # Read 8 byte header + 42 bytes for each light.
        my $buffer = $self->_read(50);
        $count = $count - 1;

        push( @ret,
              Device::Osram::Lightify::Light->new( hub    => $self,
                                                   binary => $buffer
                                                 ) );
    }

    return (@ret);
}



=begin doc _connect

Private and internal-method.

Connect to the hub, via the host we were given in our constructor.

=end doc

=cut

sub _connect
{
    my ($self) = (@_);

    my $host = $self->{ 'host' };
    my $port = 4000;

    if ( $host =~ /^(.*):([0-9]+)$/ )
    {
        $host = $1;
        $port = $2;
    }

    $self->{ '_socket' } =
      IO::Socket::INET->new( Proto    => "tcp",
                             Type     => SOCK_STREAM,
                             Blocking => 1,
                             PeerAddr => $host,
                             PeerPort => $port,
                           );

    die "Failed to connect to $host:$port" unless ( $self->{ '_socket' } );
    binmode( $self->{ '_socket' } );
}


=begin doc

Private and internal-method.

Read N-bytes from the open socket.  We do this a byte at a time,
and return only when we've read as much as we should.

=end doc

=cut

sub _read
{
    my ( $self, $count ) = (@_);

    my $out;

    while ($count)
    {
        my $buf;
        my $c = sysread( $self->{ '_socket' }, $buf, 1, 0 );
        if ($c)
        {
            $count -= $c;
            $out .= $buf;

        }

    }
    return ($out);
}


1;



=head1 AUTHOR

Steve Kemp <steve@steve.org.uk>

=cut

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 Steve Kemp <steve@steve.org.uk>.

This library is free software. You can modify and or distribute it under
the same terms as Perl itself.

=cut
