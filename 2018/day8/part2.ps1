. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $data = (get-content $Path) -split " " | % { [int]$_ }
    function Parse-Node {
        param (
            $Index,
            $Data
        )

        # Setup node
        $Node = @{}
        $Node.ChildCount = $data[$Index]
        $Node.MetaDataCount = $data[$Index + 1]
        $Node.Children = @()

        $currentIndex = $Index + 2
        for ($childNum = 0; $childNum -lt $Node.ChildCount; $childNum++) {
            $childNode, $currentIndex = Parse-Node -Index $currentIndex -Data $Data
            $Node.Children += $childNode.Clone()
        }

        $Node.MetaData = $data[$currentIndex..($currentIndex + $Node.MetaDataCount - 1)]

        if($node.ChildCount){
            foreach($childRef in $Node.MetaData){
                $Node.Value += $Node.Children[$childRef-1].Value ?? 0
            }
        }
        else{
            $Node.Value = $Node.MetaData | measure -sum | select -ExpandProperty Sum
        }

        return $Node, ($currentIndex + $Node.MetaDataCount)
    }

    $root, $finalIndex = Parse-Node -Index 0 -Data $data
    $root.Value

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 66
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

