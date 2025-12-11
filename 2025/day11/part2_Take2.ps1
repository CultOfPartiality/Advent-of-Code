. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test2.txt"
$Path = "$PSScriptRoot/input.txt"

# function Solution {
#     param ($Path)

$Servers = @{}
get-content $Path | % {
    $split = $_ -replace ":", "" -split " "
    $Servers[$split[0]] = [PSCustomObject]@{
        Name               = $split[0]
        ConnectedToNames   = [array]($split | select -Skip 1)
        ConnectedFromNames = @()
        PathsToHere        = 0
    }
}
$Servers["out"] = [PSCustomObject]@{
    Name               = "out"
    ConnectedToNames   = @()
    ConnectedFromNames = @()
    PathsToHere        = 0
}
foreach ($server in $Servers.Values) {
    foreach ($ConnectionName in $server.ConnectedToNames) {
        $Servers[$ConnectionName].ConnectedFromNames += $server.Name
    }
}

# CLOSE! Need to work out the rank of each, then only do that rank once so we don't get stuck in the middle


@('svr', 'fft'), @('fft', 'dac'), @('dac', 'out') | % {
    $from, $to = $_
    foreach ($server in $Servers.Values) {
        $Server.PathsToHere = 0
    }
    $Servers[$from].PathsToHere = 1
    $candidateList = $Servers[$from].ConnectedToNames
    while ($candidateList.Count) {
        $nextCandidates = @()
        foreach ($candidate in ($candidateList | % { $Servers[$_] }) ) {
            $nodesPathsHere = ($candidate.ConnectedFromNames | % { $Servers[$_].PathsToHere })
            if ( $nodesPathsHere -contains 0) {
                $nextCandidates += $candidate.Name
                continue
            }
            $candidate.PathsToHere = $nodesPathsHere | sum-array
            if ($candidate.Name -eq $to) {
                $nextCandidates = @()
                break
            }
            $nextCandidates += $candidate.ConnectedToNames
        }
        $candidateList = $nextCandidates | select -Unique
    }
    write-host "$from to $to had $($candidate.PathsToHere) unique paths"
}

# }
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 2
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

# #NOT 26