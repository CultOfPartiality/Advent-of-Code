. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $data = (get-content $Path) -split " " | % { [int]$_ }
    $g_metaDataTotal = [ref]0
    function Parse-Node {
        param (
            $Index,
            $Data,
            $Total
        )

        # Setup node
        $Node = @{}
        $Node.ChildCount = $data[$Index]
        $Node.MetaDataCount = $data[$Index + 1]
        $Node.Children = @()

        $currentIndex = $Index + 2
        for ($childNum = 0; $childNum -lt $Node.ChildCount; $childNum++) {
            $childNode, $currentIndex = Parse-Node -Index $currentIndex -Data $Data -Total $Total
            $Node.Children += $childNode.Clone()
        }

        $Node.MetaData = $data[$currentIndex..($currentIndex + $Node.MetaDataCount - 1)]
        $Node.MetaData | % { $Total.Value += $_ }

        return $Node, ($currentIndex + $Node.MetaDataCount)
    }

    $root, $finalIndex = Parse-Node -Index 0 -Data $data -Total $g_metaDataTotal
    $g_metaDataTotal.Value

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 138
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

