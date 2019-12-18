#!/usr/bin/perl -w
# ----------------------------------------------------------------------
# Create/update a (nearly) monochrome texture pack for NodeCore, for
# testing the game's accessibility for colorblind users.  All things
# should be visually distinguishable using luma hints alone, without
# relying on chroma channels.
# ----------------------------------------------------------------------
use strict;
use warnings;
use File::Find qw(find);
use File::Path qw(mkpath);

my $outd = "$ENV{HOME}/.minetest/textures/ncmono";

-d $outd or mkpath($outd);
-d $outd or die("failed to mkpath $outd");

find(
	{       wanted => sub {
			-f $_ and -s $_ and $_ =~ m#\.png$# or return;
			my $r = system("convert", $_, qw(-colorspace gray), "$outd/$_");
			$r and die("convert $_ returned $r");
			print "$_\n";
		}
	},
	"..");
