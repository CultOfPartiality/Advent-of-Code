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
            Weight           = [int]($bits[1].TrimStart("()").TrimEnd(")"))
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
    $nodes | ? { $_.SupportedBy -eq $null } | Select -ExpandProperty Name
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" "tknk"
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

