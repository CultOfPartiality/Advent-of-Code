. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
   param ($Content)
    $data = ($Content).ToCharArray() | %{[int][string]$_}
    $total = 0
    for ($i = 0; $i -lt $data.Count; $i++) {
        $currentNum = $data[$i]
        $nextNum = $data[(($i+$data.Count/2) % $data.Count)]
        if($currentNum -eq $nextNum){
            $total+=$currentNum
        }
    }
    $total
}
Unit-Test  ${function:Solution} "1212" 6
Unit-Test  ${function:Solution} "1221" 0
Unit-Test  ${function:Solution} "123425" 4
Unit-Test  ${function:Solution} "123123" 12
Unit-Test  ${function:Solution} "12131415" 4
$measuredTime = measure-command {$result = Solution (Get-Content "$PSScriptRoot/input.txt")}
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

