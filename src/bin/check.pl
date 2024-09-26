#!/usr/bin/perl

use strict;

my @loDiffs = qx( diff -wBrq /scratch/work/oe-layersetup/configs /scratch/work/oe-layersetup/configs2 );

foreach my $lpDiff (@loDiffs)
{
    my ($lpA,$lpB) = ($lpDiff =~ /Files (.+) and (.+) differ/);

    if (defined($lpA) && defined($lpB))
    {
        system("tkdiff -w -B $lpA $lpB");
    }
}

