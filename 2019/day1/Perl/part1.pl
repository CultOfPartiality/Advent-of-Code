use strict;
use warnings;

use Path::Tiny;
use Carp::Assert;
use POSIX 'floor';

my $file_handle = path($0)->parent->parent->child("input.txt")->openr_utf8();

my $total = 0;
while( my $line = $file_handle->getline() ){
    $total = $total + floor( $line / 3 )-2;
}

assert($total == 3291356) if DEBUG;
print "Part 1: ",$total