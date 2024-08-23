. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot\testcases\test1.txt"

function Solution {
   param ($Path)

$passphrases = Get-Content $Path

$total = 0
foreach($passphrase in $passphrases){
    $duplicatedWords = $passphrase -split " " | group | ?{ $_.Count -gt 1}
    if($duplicatedWords.Count -eq 0){
        $total++
    }
}
$total

}
Unit-Test  ${function:Solution} "$PSScriptRoot\testcases\test1.txt" 2
$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
