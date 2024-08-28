. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    # Step 1 - Parse and build the tree
    $nodes = @{}
    get-content $Path | % {
        [int]$name, $conns = $_ -split " <-> "
        $conns = [int[]]($conns -split ", ")
        $nodes[$name] = @{
            name            = $name
            conns           = $conns
            connectedToRoot = $null
        }
    }

    # Step 2 - Walk the tree while there are still untouched nodes
    function Check-RootConnectivity($node) {
        foreach ($connectionID in $node.conns) {
            $connectedNode = $nodes[$connectionID]
            if ($null -eq $connectedNode.connectedToRoot) {
                $connectedNode.connectedToRoot = $true
                Check-RootConnectivity($connectedNode)
            }
        }
    }
    $groups = 0
    while ($nodes.Count) {
        $startingNode = $nodes[($nodes.Values.name | select -first 1)]
        $startingNode.connectedToRoot = $true
        
        Check-RootConnectivity($startingNode)
        $groups++
        $nodes.Clone().Values | ?{$_.connectedToRoot} | %{
            $nodes.Remove($_.name)
        }
    }
    $groups

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 2
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

