. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test2.txt"
$Path = "$PSScriptRoot/input.txt"

function Solution {
    param ($Path)

    # Parse server information, and build linked graph
    $Servers = @{}
    get-content $Path | % {
        $split = $_ -replace ":", "" -split " "
        $Servers[$split[0]] = [PSCustomObject]@{
            Name               = $split[0]
            ConnectedToNames   = [array]($split | select -Skip 1)
            ConnectedFromNames = @()
            PathsToHere        = 0
            rank               = 0
        }
    }
    $Servers["out"] = [PSCustomObject]@{
        Name               = "out"
        ConnectedToNames   = @()
        ConnectedFromNames = @()
        PathsToHere        = 0
        rank               = 0
    }
    foreach ($server in $Servers.Values) {
        foreach ($ConnectionName in $server.ConnectedToNames) {
            $Servers[$ConnectionName].ConnectedFromNames += $server.Name
        }
    }

    # Work out the rank of each server, so we can evaluate them in order when required to avoid order-of-operations issues
    $Servers['svr'].Rank = 1
    $candidateList = $Servers['svr'].ConnectedToNames
    while ($candidateList.Count) {
        $nextCandidates = @()
        foreach ($candidate in ($candidateList | % { $Servers[$_] }) ) {
            $previousRanks = ($candidate.ConnectedFromNames | % { $Servers[$_].rank })
            if ( $previousRanks -contains 0) {
                $nextCandidates += $candidate.Name
                continue
            }
            $candidate.rank = ($previousRanks | measure -Maximum).Maximum + 1
            $nextCandidates += $candidate.ConnectedToNames
        }
        $candidateList = $nextCandidates | select -Unique
    }

    # From inspection, we need to go from svr to fft, then to dac, then to out
    # For each leg, calculate the number of paths to get from the start to the end
    # Once we know all three, thier product is the total possible paths that hit all three
    @('svr', 'fft'), @('fft', 'dac'), @('dac', 'out') | % {
        $from, $to = $_
        #Reset the possible path counts
        foreach ($server in $Servers.Values) {
            $Server.PathsToHere = 0
        }
        $Servers[$from].PathsToHere = 1
        # We consider nodes based on rank, so we can guarentee we've always calculated the paths to previous nodes
        $candidateList = $Servers[$from].ConnectedToNames | sort { $servers[$_].Rank } 
        while ($candidateList.Count) {
            $nextCandidates = @()
            foreach ($candidate in ($candidateList | % { $Servers[$_] }) ) {
                # Add up the possible paths from each node that leads to here. If they're not from the 
                # start node in question, they'll be 0 so they won't matter
                $nodesPathsHere = ($candidate.ConnectedFromNames | % { $Servers[$_].PathsToHere })
                $candidate.PathsToHere = $nodesPathsHere | sum-array
                if ($candidate.Name -eq $to) {
                    #We've found the node in question; time to bail
                    $nextCandidates = @()
                    break
                }
                # Add the next nodes from this one to the list
                $nextCandidates += $candidate.ConnectedToNames
            }
            $candidateList = $nextCandidates | select -Unique | sort { $servers[$_].Rank } 
        }
        write-host "$from to $to had $($candidate.PathsToHere) unique paths"
        $candidate.PathsToHere
    } | multiply-array
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 2
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta