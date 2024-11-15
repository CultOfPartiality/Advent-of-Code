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
    $elves = @{}
    write-host "Play area populating..."
    $playArea = 0..$setup.lastMarble | %{
        $marble = $_
        [PSCustomObject]@{
            Marble = $marble
            NextIndex = -1
            PrevIndex = -1
        }
    } #new-object "psobject[]" ($setup.lastMarble+1)
    $playArea[0].NextIndex = 2
    $playArea[0].PrevIndex = 1
    $playArea[1].NextIndex = 0
    $playArea[1].PrevIndex = 2
    $playArea[2].NextIndex = 1
    $playArea[2].PrevIndex = 0
    $currentNode = $playArea[2]

    write-host " -> Complete"

    $currentTime = get-date
    foreach ($marble in 3..$setup.lastMarble) {
        if ($marble % 23 -eq 0) {
            #Remove the node 7 back
            1..7 | %{$currentNode = $playArea[$currentNode.PrevIndex]}
            $elves[$currentElf] += $marble + $currentNode.Marble
            $preNode = $playArea[$currentNode.PrevIndex]
            $postNode = $playArea[$currentNode.NextIndex]
            $preNode.NextIndex = $postNode.Marble
            $postNode.PrevIndex = $preNode.Marble
            $currentNode = $postNode
        }
        else {
            #Insertion into the linked list
            $preNode = $playArea[$currentNode.NextIndex]
            $postNode = $playArea[$preNode.NextIndex]
            #insert
            $playArea[$marble] = [PSCustomObject]@{
                Marble = $marble
                NextIndex = $postNode.Marble
                PrevIndex = $preNode.Marble
            }
            #update previous entries
            $preNode.NextIndex = $marble
            $postNode.PrevIndex = $marble
            $currentNode = $playArea[$marble]
        }
        $currentElf = ($currentElf + 1) % $setup.players

        #Progress
        if($marble % 100000 -eq 0){
            $time = get-date
            write-host "Marble $marble, $((100.0*$marble/$setup.lastMarble).ToString("0.0"))%, last run took $($time.Subtract($currentTime).TotalSeconds)s"
            $currentTime = get-date
        }
        
        #debug
    #     $debugNode = $playArea[0]
    #     0..$marble | %{
    #         write-host -NoNewline "$($debugNode.Marble),"
    #         $debugNode = $playArea[$debugNode.NextIndex]
    #     }
    #     Write-Host
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
write-host "make sure to add back the *100"
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

