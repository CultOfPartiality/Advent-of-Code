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
    $LongestBridge = 0
    $StrongestBridge = 0
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
            Write-Host "$debugCounter steps, $($searchSpace.Count) options in the queue, $($Solutions) completed bridges found (longest: $LongestBridge, strength: $StrongestBridge)"
        }

        $state = $searchSpace.Dequeue()
        $remainingPieces = $allPieces | ? { $_.values -contains $state.NextJoin } | ? { $_.index -notin $state.Pieces.index }
        if (-not $remainingPieces.count) {
            $solutions++
            $strength = $state.Pieces.values | measure -Sum | Select -ExpandProperty Sum
            if( ($state.Pieces.Count -eq $longestBridge) -and ($strength -gt $StrongestBridge)){
                $StrongestBridge = $strength
            }
            elseif($state.Pieces.Count -gt $longestBridge){
                $longestBridge = $state.Pieces.count
                $StrongestBridge = $strength
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
    $strongestBridge

}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 19
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

