. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$number = 800

function Solution {
    param ($number)

    function Calc-InnerIndex($number) {
    
        $ringOddIndex = 3
        $ringNum = 9
        while ($ringNum -lt $number) {
            $ringOddIndex += 2
            $ringNum = $ringOddIndex * $ringOddIndex
        }
        $prevRingOddIndex = $ringOddIndex - 2
        $prevRingNum = $prevRingOddIndex * $prevRingOddIndex


        $corner = $prevRingNum + ($ringOddIndex - 1)
        $cornerNum = 1
        while ($number -gt $corner) {
            $corner += ($ringOddIndex - 1)
            $cornerNum++
        }
        $distanceFromCorner = $corner - $number
        #Calc inner, and go back one
        $prevEndCorner = [math]::pow($prevRingOddIndex - 2, 2) + $cornerNum * ($prevRingOddIndex - 1)
        if ($prevEndCorner -le 1) {
            $innerIndex = 1    
        }
        else {
            $innerIndex = $prevEndCorner - ($distanceFromCorner - 1)
        }
        $innerIndex
    }

    $prevRingOddIndex = 3
    $prevRingNum = 9
    $ringOddIndex = 5
    $ringNum = 25
    $midRingCorners = 1..3 | % { $ringNum - $_ * ($ringOddIndex - 1) }

    $sumArray = $null, 1, 1, 2, 4, 5, 10, 11, 23, 25, 26, 54

    $index = 12
    while ($sumArray[-1] -le $number) {
        # Find adjacent squares, that are less than this index
        # This is done by charaterising, and based on that we know what numbers to check for
        $value = 0
        switch ($index) {
            #First three corners
            { $_ -in $midRingCorners } {
                $innerCorner = (Calc-InnerIndex($index)) - 1
                $value += $sumArray[$innerCorner]
                $value += $sumArray[$index - 1]
            }
            #Last corner
            $prevRingNum {
                $innerCorner = (Calc-InnerIndex($index)) - 1
                $value += $sumArray[$innerCorner]
                $value += $sumArray[$innerCorner + 1]
                $value += $sumArray[$index - 1]
            }
            #First in a new ring
            { $_ -eq ($prevRingNum + 1) } {
                $prevInnerIndex = Calc-InnerIndex($prevRingNum)
                $value += $sumArray[$prevInnerIndex]
                $value += $sumArray[$index - 1]
            }
            #Second in a new ring
            { $_ -eq ($prevRingNum + 2) } {
                $prevInnerIndex = (Calc-InnerIndex($prevRingNum)) 
                $value += $sumArray[$prevInnerIndex]
                $value += $sumArray[$prevInnerIndex + 1]
                $value += $sumArray[$index - 1]
                $value += $sumArray[$index - 2]
            }
            #Just after a corner
            { ($_ - 1) -in $midRingCorners } {
                $prevInnerIndex = Calc-InnerIndex($index)
                $value += $sumArray[$prevInnerIndex]
                $value += $sumArray[$prevInnerIndex + 1]
                $value += $sumArray[$index - 1]
                $value += $sumArray[$index - 2]
            }
            #Just before a corner
            { ($_ + 1) -in $midRingCorners } {
                $prevInnerIndex = Calc-InnerIndex($index)
                $value += $sumArray[$prevInnerIndex]
                $value += $sumArray[$prevInnerIndex - 1]
                $value += $sumArray[$index - 1]
            }
            #Mid edge
            Default {
                $innerIndex = Calc-InnerIndex($index)
                $value += $sumArray[$innerIndex - 1]
                $value += $sumArray[$innerIndex]
                $value += $sumArray[$innerIndex + 1]
                $value += $sumArray[$index - 1]
            }
        }
        $sumArray += $value

    
        # Increment the index, and go to next ring if needed
        $index++
        if ( $index -eq $ringNum ) {
            $prevRingOddIndex = $ringOddIndex
            $prevRingNum = $ringNum
            $ringOddIndex += 2
            $ringNum = $ringOddIndex * $ringOddIndex
            $midRingCorners = 1..3 | % { $ringNum - $_ * ($ringOddIndex - 1) }
        }
    }
    $sumArray[-1]


}

Unit-Test  ${function:Solution} 360 362
Unit-Test  ${function:Solution} 700 747
Unit-Test  ${function:Solution} 800 806
Unit-Test  ${function:Solution} 870 880
Unit-Test  ${function:Solution} 930 931
Unit-Test  ${function:Solution} 932 957
Unit-Test  ${function:Solution} 932 957
Unit-Test  ${function:Solution} 970 1968
Unit-Test  ${function:Solution} 2000 2105
$measuredTime = measure-command { $result = Solution 325489 }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

#335840 it too high