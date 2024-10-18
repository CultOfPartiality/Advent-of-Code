. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)


    $allPieces = get-content $Path | % {
        [PSCustomObject]@{
            index  = $_.GetHashCode()
            values = ($_ -split "/" | % { [int]$_ })
        }
    }

    $solutions = 0
    $bestSolution = 0
    $searchSpace = New-Object 'System.Collections.Queue'

    # First round - Find each element with a 0, and add to queue
    $allPieces | ? { $_.values -contains 0 } | % {
        $piece = $_
        $state = [PSCustomObject]@{
            Pieces   = @(, $piece)
            NextJoin = ($piece.values -ne 0)[0]
        }
        $searchSpace.Enqueue($state)
    }

    # Then run until queue is empty, generating the next steps and adding those to the queue. If there is no next step, this is a solution
    $debugCounter=0
    while ($searchSpace.Count) {
        $debugCounter++
        if($debugCounter % 10000 -eq 0){
            Write-Host "$debugCounter steps, $($searchSpace.Count) options in the queue, $($Solutions) completed bridges found (best: $bestSolution)"
        }

        $state = $searchSpace.Dequeue()
        $remainingPieces = $allPieces | ? { $_.values -contains $state.NextJoin } | ? { $_.index -notin $state.Pieces.index }
        if (-not $remainingPieces.count) {
            $solutions++
            $value = $state.Pieces.values | measure -Sum | Select -ExpandProperty Sum
            if($value -gt $bestSolution){
                $bestSolution = $value
            }
            continue
        }
        foreach ($piece in $remainingPieces) {
            $nextJoin = $piece.values[0] -eq $piece.values[1] ? $piece.values[0] : ($piece.values -ne $state.NextJoin)[0]
            $nextState = [PSCustomObject]@{
                Pieces   = ($state.Pieces + $piece)
                NextJoin = $nextJoin
            }
            $searchSpace.Enqueue($nextState)
        }
    }

    #$solutions | %{$_.Pieces.values|measure -Sum } | measure -Property Sum -Maximum | select -ExpandProperty Maximum
    $bestSolution

}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 31
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

