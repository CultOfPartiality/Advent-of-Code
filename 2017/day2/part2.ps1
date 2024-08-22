. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $rows = get-content $Path |
    % { , ($_ -Split "\s") } |
    % {
        $values = $_ | %{[int][string]$_} | sort
        ,$values
    }
    $results = foreach($row in $rows) {
        for ($i = 0; $i -lt $row.Count; $i++) {
            $value = $row[$i]
            $row | select-object -SkipIndex $i | %{
                if($value % $_ -eq 0){
                    $value/$_
                }
            }
        }
    }
    $results | measure -Sum | select -ExpandProperty Sum
}
function Solution_Alt {
    param ($Path)

    $rows = get-content $Path |
    % { , ($_ -Split "\s") } |
    % {
        $values = $_ | %{[int][string]$_} | sort
        ,$values
    }
    $results = foreach($row in $rows) {
        Get-AllPairs $row | %{ $_[1]/$_[0] } | ?{[math]::Truncate($_) -eq $_ }
    }
    $results | measure -Sum | select -ExpandProperty Sum
}

Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 9
Unit-Test  ${function:Solution_Alt} "$PSScriptRoot/testcases/test2.txt" 9
$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
$measuredTime = measure-command {$result = Solution_Alt "$PSScriptRoot\input.txt"}
Write-Host "Part 2 (alt solution): $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

