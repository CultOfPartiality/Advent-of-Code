. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$number = 14

function Solution {
    param ($number)
    <# Each spiral ends with the next squared odd number
    1^2 =  1
    3^2 =  9
    5^2 = 25
    7^2 = 49
    ...

   So to find which ring a number is in, find which squared odd numbers it sits between
#>
    $ringOddIndex = 1
    $ringNum = 1
    while ($number -gt $ringNum) {
        $ringOddIndex += 2
        $ringNum = $ringOddIndex * $ringOddIndex
    }
    $prevRingOddIndex = $ringOddIndex - 2
    $prevRingNum = $prevRingOddIndex * $prevRingOddIndex

    # Work out how far the number in question is from the middle of the side of the square 
    # The ring index is the side length of the square. The possible numbers will be (for 25 say):
    #   9->13, 13->17, 17->21, 21->25
    # So take the last odd squared num, and increment by the side length - 1, until we find the 
    # corner that's just past the number in question. Removing half the (length-1) gets us the
    # middle square nearest the number in question. Absolute difference, plus the index of the ring 
    # number (1->0, 3->1, 5->2...) gets us the steps
    $endCorner = $prevRingNum + ($ringOddIndex - 1)
    while ($number -gt $endCorner) {
        $endCorner += ($ringOddIndex - 1)
    }
    $middleNumber = $endCorner - ($ringOddIndex - 1) / 2
    $steps = ($ringOddIndex - 1) / 2 + [math]::Abs($number - $middleNumber)
    $steps
}

Unit-Test  ${function:Solution} 1 0
Unit-Test  ${function:Solution} 12 3
Unit-Test  ${function:Solution} 23 2
Unit-Test  ${function:Solution} 1024 31
$measuredTime = measure-command { $result = Solution 325489 }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

