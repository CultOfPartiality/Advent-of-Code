use strict;
use warnings;

use Path::Tiny;
use Carp::Assert;
use POSIX 'floor';

my $dir = path("..");
my $file = $dir->child("input.txt");
my $file_handle = $file->openr_utf8();

my $total = 0;
while( my $line = $file_handle->getline() ){
    $total = $total + floor( $line / 3 )-2;
}

assert($total == 3291356) if DEBUG;
print "Part 1: ",$total