. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    get-content $Path |
    % { , ($_ -Split "\s") } |
    % {
        $values = $_ | %{[int][string]$_} | sort
        $values[-1] - $values[0]
    } |
    Measure-Object -Sum | select -ExpandProperty Sum
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 18
$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

