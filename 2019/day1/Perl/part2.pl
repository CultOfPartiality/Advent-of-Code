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
    my $fuel = floor( $line / 3 )-2;
    while($fuel > 0){
        $total += $fuel;
        $fuel = floor( $fuel / 3 )-2;
    }
}

assert($total == 4934153) if DEBUG;
print "Part 2: ",$total