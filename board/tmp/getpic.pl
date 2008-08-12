#!/usr/bin/perl

use CGI::Carp qw(fatalsToBrowser);

use strict;

use lib '.';

my $metadata=<STDIN>;
my ($oek_ip, $image_length);

# Grab Oekaki IP and Image Length
if ($metadata=~/^S[0-9]{8}(.*)([0-9]{8})\n?/)
{
	$oek_ip = $1;
	$image_length = $2;
}
else
{
	die "Invalid input (poo/magic_header not supported in Oekaki submission because K. Anon is lazy) " if ($metadata !~ /^S/);
}

# Sanity check
die unless($oek_ip=~/^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/);

my $buffer = do { local $/; <STDIN> };

my $tmpname_o=$oek_ip.'.png';
my $tmpname_anim=$oek_ip.'.pch';

open IMGFILE,">$tmpname_o" or die("Couldn't write to directory");
open ANIMFILE,">$tmpname_anim" or die("Couldn't write to directory");

binmode IMGFILE;
binmode ANIMFILE;
binmode STDIN;


# Grab Image Data
my $image_data = substr($buffer, 0, $image_length);

print IMGFILE $image_data;
close IMGFILE;

undef $image_data;	# Clear memory.

# Grab PCH Data (Animation)
my $animation_length = substr($buffer, $image_length, 8);
my $animation_data = substr($buffer, $image_length+8, $animation_length);

print ANIMFILE $animation_data;
close ANIMFILE;

undef $animation_data;
undef $buffer;

chmod 0644, $tmpname_o;
chmod 0644, $tmpname_anim;

print "Content-Type: text/plain\n";
print "\n";
print "ok";
