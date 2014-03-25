#!/usr/bin/perl

use strict;
use warnings;

package CountWeights;

use Math::BigInt try => 'GMP', ':constant';

use List::Util qw(sum reduce);

sub count_weights
{
    my ($sum, $weights_array_ref) = @_;

    my @weights_sorted = reverse (sort { $a <=> $b } map { Math::BigInt->new($_) } @$weights_array_ref);

    my $calc;

    $calc = sub {
        my ($depth, $remaining, $counts) = @_;

        my $w = $weights_sorted[$depth];

        if ($depth == $#weights_sorted)
        {
            if ($remaining % $w == 0)
            {
                my @c = (@$counts, $remaining / $w);
                return (Math::BigInt->new(sum(@c))->bfac() / (reduce { $a * $b } map { Math::BigInt->new($_)->bfac() } @c));
            }
            else
            {
                return 0;
            }
        }

        my $ret = 0;

        foreach my $new_c (reverse(0 .. int($remaining / $w)))
        {
            $ret += $calc->($depth+1, $remaining - $new_c * $w, [@$counts, $new_c]);
        }

        return $ret;
    };

    return $calc->(0, $sum, []);
}

package main;


use Test::More tests => 1;

# TEST
is (
    ''.CountWeights::count_weights(3,[1,2]),
    ''.(2+1),
    'Testing 1,2 weights for 3.',
);
