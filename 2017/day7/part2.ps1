. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $nodes = get-content $Path | % {
        $bits = $_ -split ",?\s"
        $node = [PSCustomObject]@{
            Name             = $bits[0]
            NodeWeight       = [int]($bits[1].TrimStart("()").TrimEnd(")"))
            TotalWeight      = $null
            SupportedBy      = $null
            Supporting       = @()
            Supporting_Names = @()
        }
        if ($bits.Count -gt 3) {
            $Node.Supporting_Names = $bits[3..($bits.Count - 1)]
        }
        $node
    }
    foreach ($Node in $Nodes) {
        $node.Supporting += $nodes | ? { $_.Name -in $node.Supporting_Names }
        $node.Supporting | % { $_.SupportedBy = $node }
    }
    $rootNode = $nodes | ? { $_.SupportedBy -eq $null }


    # Walk the tree, calculating total weight
    function Calc-TotalWeight($node) {
        $Node.TotalWeight = $node.NodeWeight
        foreach ($supportedNode in $node.Supporting) {
            $Node.TotalWeight += Calc-TotalWeight($supportedNode)
        }
        return $Node.TotalWeight
    }
    $null = Calc-TotalWeight($rootNode)

    # Follow the path of weights that are different
    function Find-WrongNode($node) {
        if ($node.Supporting.Count -eq 0) {
            return $node
        }
        if ( ($node.Supporting.TotalWeight | group).Count -eq 1 ) {
            return $node
        }
        $BustedNodes = ($node.Supporting | group TotalWeight | ? Count -EQ 1).Group
        if ($BustedNodes.Count -eq 1) {
            return Find-WrongNode($BustedNodes[0])
        }
        else {
            return $node
        }

    }
    $wrongNode = Find-WrongNode($rootNode)
    $correctWeight = $wrongNode.SupportedBy.Supporting.TotalWeight | ? { $_ -ne $wrongNode.TotalWeight } | select -First 1

    $weightChange = $correctWeight - $wrongNode.TotalWeight
    $wrongNode.NodeWeight + $weightChange
    
}



Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 60
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

