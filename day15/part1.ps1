. "$PSScriptRoot\..\Unit-Test.ps1"

function HASH {
    param ([String]$inputStr)
    $currentValue = 0
    [char[]]$inputStr | %{
        $ascii = [int][byte][char]$_
        $currentValue = ($currentValue+$ascii)*17 % 256
    }
    return $currentValue
}

function Initialize-Seq{
    param ($Path)
$data = Get-Content $Path
$data = $data -split ","

$data | %{HASH $_} | measure -Sum | select -ExpandProperty Sum
}

Unit-Test  ${function:Initialize-Seq} "$PSScriptRoot\testcases\test1.txt" 1320
$result = Initialize-Seq "$PSScriptRoot\input.txt"
Write-Host "Part 1: $result" -ForegroundColor Magenta