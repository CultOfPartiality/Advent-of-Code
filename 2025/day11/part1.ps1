. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $Servers = @{}
    get-content $Path | % {
        $split = $_ -replace ":", "" -split " "
        $Servers[$split[0]] = [PSCustomObject]@{
            Name            = $split[0]
            ConnectionNames = [array]($split | select -Skip 1)
            Connections     = @()
        }
    }
    foreach ($server in $Servers.Values) {
        foreach ($ConnectionName in $server.ConnectionNames) {
            $server.Connections += $Servers[$ConnectionName]
        }
    }

    $searchSpace = new-object "System.Collections.Stack"
    $searchSpace.Push($Servers["you"])
    $totalPaths = 0
    while ($searchSpace.Count) {
        $node = $searchSpace.Pop()
        foreach ($nextStep in $node.ConnectionNames) {
            if ($nextStep -eq "out") {
                $totalPaths++
                continue
            }
            $searchSpace.Push($Servers[$nextStep])
        }
    }
    $totalPaths

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 5
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

