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

    $solutions = @()
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
    while ($searchSpace.Count) {
        $state = $searchSpace.Dequeue()
        $remainingPieces = $allPieces | ? { $_.index -notin $state.Pieces.index } | ? { $_.values -contains $state.NextJoin }
        if (-not $remainingPieces.count) {
            $solutions += $state
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

    $solutions | %{$_.Pieces.values|measure -Sum } | measure -Property Sum -Maximum | select -ExpandProperty Maximum


}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 31
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

