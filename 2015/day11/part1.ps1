function Next-Password {
    param ($prevPwd)
    
    function Inc {
        param ($letter)
        #TODO
        $letter
    }

    $valid = $false
    while(-not $valid){
        #increment last letter
        $rollover = [Regex]::Match($prevPwd,'[a-y]z+$')
        if($rollover.Success){
            $prevPwd = "$($prevPwd.SubString(0,$rollover.Index))$(Inc $rollover.Value[0])$("a"*($rollover.Length-1))"
        }
    }
    $prevPwd    
}

function test {
    param ([scriptblock]$function,$inputData,$expectedAnswer)    
    $answer = $function.Invoke($inputData)
    if($answer -eq $expectedAnswer){
        write-host "Example passed ✔ " -ForegroundColor Green
        Return $true
    }
    else{
        write-host "Example failed ✖ " -ForegroundColor Red
        Write-host "Produced: $answer. Expected: $expectedAnswer" -ForegroundColor Red
        Return $false
    }   
}

#tests
$testsPassing = (test ${function:Next-Password} "abcdefgh" "abcdffaa") -and
                (test ${function:Next-Password} "ghijklmn" "ghjaabcc")
if(-not $testsPassing){exit}

#Run the actual input
$part1 = Next-Password "abcdefgh"
write-host "Answer for part 1: $part1" -ForegroundColor Magenta
