. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test0.txt"

function Solution {
    param ($Path)


    # Parse input
    $inputParams = (get-content $Path) -split " "
    $setup = [PSCustomObject]@{
        players    = ([int]$inputParams[0])
        lastMarble = (100*[int]$inputParams[6])
    }

    # Setup elves and play area
    $playArea = [System.Collections.ArrayList]@(0, 2, 1)
    $playArea.Capacity = $setup.lastMarble+1
    $elves = @{}
    $currentElf = 2 #starting from elf 0
    $currentMarbleIndex = 1
    $currentTime = get-date

    foreach ($marble in 3..$setup.lastMarble) {
        if ($marble % 23 -eq 0) {
            $currentMarbleIndex = ($currentMarbleIndex - 7 + $playArea.Count) % $playArea.Count
            $elves[$currentElf] += $marble + $playArea[$currentMarbleIndex]
            $playArea.RemoveAt($currentMarbleIndex)
        }
        else {
            if (($currentMarbleIndex + 2) -eq ($playArea.Count) ) {
                $currentMarbleIndex = $playArea.Add($marble)
            }
            else {
                $currentMarbleIndex = ($currentMarbleIndex + 2) % ($playArea.Count)
                $playArea.Insert($currentMarbleIndex, $marble)
            }
        }
        $currentElf = ($currentElf + 1) % $setup.players
        # write-host ($playArea -join ",")
        if($marble % 100000 -eq 0){
            $time = get-date
            write-host "Marble $marble, $((100.0*$marble/$setup.lastMarble).ToString("0.0"))%, last run took $($time.Subtract($currentTime).TotalSeconds)s"
            $currentTime = get-date
        }
    }

    ($elves.Values | measure -Maximum).Maximum
}

# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test0.txt" 32
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 8317
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 146373
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test3.txt" 2764
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test4.txt" 54718
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test5.txt" 37305
$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
Write-Host "Part 2 (x100): $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

