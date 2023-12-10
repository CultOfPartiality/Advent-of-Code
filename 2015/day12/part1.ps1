function Total-Numbers {
    param ($rawInput,[switch]$showWorking)
    $rawInput = $rawInput -replace '{.*?:("red").*?}',''
    $rawInput = $rawInput | Select-String '(-?\d+)' -AllMatches
    # if($rawInput -eq $null){
    #     [int]0
    # }
    # else{
        $rawInput = $rawInput | select -ExpandProperty Matches | %{[int]$_.Value}
        $rawInput = $rawInput | measure -sum | select -ExpandProperty sum
        [int]$rawInput
    # }
}

function test {
    param ([scriptblock]$function,$inputData,$expectedAnswer)
    write-host "Example '$inputData': " -NoNewline -ForegroundColor Yellow
    $answer = $function.InvokeReturnAsIs($inputData)
    if($answer -eq $expectedAnswer){
        write-host "Example passed ✔ " -ForegroundColor Green
        Return $true
    }
    else{
        write-host "Example failed ✖  | " -NoNewline -ForegroundColor Red
        Write-host "Expected '$expectedAnswer', produced '$answer'" -ForegroundColor Red
        Return $false
    }   
}

#tests
$testsPassing = (test ${function:Total-Numbers} '[1,2,3]' 6) -and
                (test ${function:Total-Numbers} '{}' 0) -and
                (test ${function:Total-Numbers} '{"a":2,"b":4}' 6) -and
                (test ${function:Total-Numbers} '[1,{"c":"red","b":2},3]' 4) -and
                (test ${function:Total-Numbers} '{"d":"red","e":[1,2,3,4],"f":5}' 0) -and
                (test ${function:Total-Numbers} '[1,"red",5]' 6) #-and
if(-not $testsPassing){exit}

# Run the actual input
$part1 = Total-Numbers (Get-Content "$PSScriptRoot/input.txt" -Raw)
write-host "Answer for part 1: $part1" -ForegroundColor Magenta
