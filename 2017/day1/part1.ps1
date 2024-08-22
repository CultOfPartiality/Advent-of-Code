. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
   param ($Path)
    $data = (get-content $Path).ToCharArray() | %{[int][string]$_}
    $total = 0
    for ($i = 0; $i -lt $data.Count; $i++) {
        $currentNum = $data[$i]
        $nextNum = $data[(($i+1) % $data.Count)]
        if($currentNum -eq $nextNum){
            $total+=$currentNum
        }
    }
    $total
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 3
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 4
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test3.txt" 0
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test4.txt" 9
$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

