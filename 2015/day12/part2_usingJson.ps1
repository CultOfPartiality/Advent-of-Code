function Total-Numbers {
    param ($rawInput, [switch]$showWorking)
    $rawInput | % {
        $item = $_
        switch ($_.GetType()) {
            [object[]] { $item|%{Total-Numbers $_}; break }
            {$_.Name = "PSCustomObject"} { $item|%{Total-Numbers $_}; break }
            [String] { Write-Host "Implement type: $_" -BackgroundColor Red; break }
            [int] {  Write-Host "Implement type: $_" -BackgroundColor Red; break  }
            Default { Write-Host "Missed a type: $_" -BackgroundColor Red }
        }    
    }
}

function test {
    param ([scriptblock]$function, $inputData, $expectedAnswer)
    write-host "Example '$inputData': " -NoNewline -ForegroundColor Yellow
    $answer = $function.InvokeReturnAsIs($inputData)
    if ($answer -eq $expectedAnswer) {
        write-host "Example passed ✔ " -ForegroundColor Green
        Return $true
    }
    else {
        write-host "Example failed ✖  | " -NoNewline -ForegroundColor Red
        Write-host "Expected '$expectedAnswer', produced '$answer'" -ForegroundColor Red
        Return $false
    }   
}

#tests
$testsPassing = (test ${function:Total-Numbers} (ConvertFrom-Json '{"a":[1,2,3]}') 6) -and
                (test ${function:Total-Numbers} (ConvertFrom-Json '{"a":{}}') 0) -and
                (test ${function:Total-Numbers} (ConvertFrom-Json '{"a":{"a":2,"b":4}}') 6) -and
                (test ${function:Total-Numbers} (ConvertFrom-Json '{"a":[1,{"c":"red","b":2},3]}') 4) -and
                (test ${function:Total-Numbers} (ConvertFrom-Json '{"a":{"d":"red","e":[1,2,3,4],"f":5}}') 0) -and
                (test ${function:Total-Numbers} (ConvertFrom-Json '{"a":{"d":"blue","e":[1,{"e":"red",200},3,4],"f":5,[[],{"e":"red",300}]}}') 13) -and
                (test ${function:Total-Numbers} (ConvertFrom-Json '{"a":[{"d":"blue","e":[1,{"e":"red",200},3,4],"f":5,[[],{"e":"red"}]},{"d":"blue","e":[1,{"e":"red",200},3,4],"f":5,[[],{"e":"red"}]}]}') 26) -and
                (test ${function:Total-Numbers} (ConvertFrom-Json '{"a":["d":"red","e":[1,{"e":"green",200},3,4],"f":5,{}]}') 213) -and
                (test ${function:Total-Numbers} (ConvertFrom-Json '{"a":[1,"red)",5]}') 6)
if (-not $testsPassing) { exit }

# Run the actual input
$part1 = Total-Numbers (Get-Content "$PSScriptRoot/input.txt" -Raw) -showWorking
write-host "Answer for part 1: $part1 (should be less than 90675)" -ForegroundColor Magenta
