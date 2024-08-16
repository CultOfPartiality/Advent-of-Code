. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $data = get-content $Path
    $state = ($data[0]).ToCharArray() | % { [int][string]$_ } 
    $DiskSize = [int]$data[1]

    <#Start with an appropriate initial state (your puzzle input). Then, so long as you don't have enough data yet to fill the disk, repeat the following steps:
        Call the data you have at this point "a".
        Make a copy of "a"; call this copy "b".
        Reverse the order of the characters in "b".
        In "b", replace all instances of 0 with 1 and all 1s with 0.
        The resulting data is "a", then a single 0, then "b".
    #>
    while ($state.Count -lt $DiskSize) {
        $a = $state.Clone()
        $b = $a.Clone()
        [array]::Reverse($b)
        $b = $b | % { ($_ + 1) % 2 }
        $state = $a + @(0) + $b
        write-host "Data size generated: $(100.0*$state.Count/$DiskSize)%"
    }

    <#Generate checksum
    Calculate the checksum only for the data that fits on the disk, even if you generated more data than that in the previous step.

    The checksum for some given data is created by considering each non-overlapping pair of characters in the input data. If the two characters match (00 or 11),
     the next checksum character is a 1. If the characters do not match (01 or 10), the next checksum character is a 0. This should produce a new string which is
     exactly half as long as the original. If the length of the checksum is even, repeat the process until you end up with a checksum with an odd length.
    #>
    $checksum = $state[0..($DiskSize - 1)]
    while ( ($checksum.Count % 2) -ne 1 ) {
        $checksum = for ($i = 0; $i -lt $checksum.Count; $i += 2) {
        ($checksum[$i] + $checksum[$i + 1] + 1) % 2
        }
    }

    $checksum -join ""
   
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" "01100"
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input_part2.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
