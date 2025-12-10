. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

# function Solution {
#     param ($Path)

$machines = get-content $Path | % {
    $blocks = $_ -split " "
    $Buttons = $blocks[1..($blocks.Count - 2)] | % {
        , ($_ -replace "[\(\)]", "" -split "," | % { [int]$_ })
    }
    $Joltages = $blocks[-1] -replace "[\{\}]", "" -split "," | % { [int]$_ }
    [PSCustomObject]@{
        Counters = $Joltages
        Buttons  = $Buttons
    }
}

$machine = $machines[0]
$sets = @()
foreach($index in 0..($machine.Counters.Count-1)){
    $buttons = $machine.Buttons | ?{$_ -contains $index}
    write-host "To make counter $index, need $($machine.Counters[$index]) button presses, from [$(($buttons | %{"($($_ -join ","))"}) -join " ")]"
    $sets += [PSCustomObject]@{
        index = $index
        buttons = $buttons
    }
}
$sets = $sets | sort -Property {$_.buttons.Count}

# }
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 33
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta