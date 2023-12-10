
#NOTE can actually logically reason out this onee, as I did for part 2

#other otion might be to make some cases for jumping ahead, like if you don't have a run and two pairs

function Next-Password {
    param ($prevPwd,$showWorking = $true)

    $valid = $false
    while(-not $valid){
        if($showWorking){write-host "Current iteration: $prevPwd"}
        #increment last letter
        $rollover = [Regex]::Match($prevPwd,'[a-y]z+$')
        if($rollover.Success){
            $prevPwd = "$($prevPwd.SubString(0,$rollover.Index))$([char]([int]$rollover.Value[0]+1))$("a"*($rollover.Length-1))"
        }
        else {
            $prevPwd = "$($prevPwd.Substring(0,$prevPwd.Length-1))$([char]([int]$prevPwd[-1]+1))"
        }
        #Remove i, o, l
        if($prevPwd -match '[iol]'){
            $prevPwd = $prevPwd -replace '[iol].*',''
            $prevPwd = ( $prevPwd,[char]([int]$Matches[0][0]+1) ) -join ""
            $prevPwd = $prevPwd + ('a'*(8-$prevPwd.Length) -join '') 
        }
        #Check validity
        $valid = 2..($prevPwd.Length-1)|%{
            [int]$prevPwd[$_-2] -eq [int]$prevPwd[$_-1]-1 -and
            [int]$prevPwd[$_-1] -eq [int]$prevPwd[$_]-1 
        }|?{$_}|select -Unique
        $valid = [bool]$valid -and 
                 $prevPwd -notmatch '[iol]' -and
                 $prevPwd -match '([a-z])\1.*((?!\1).)\2'
    }
    $prevPwd
}

function test {
    param ([scriptblock]$function,$inputData,$expectedAnswer)
    write-host "Example '$inputData': "-NoNewline -ForegroundColor Yellow
    $answer = $function.Invoke($inputData,$false)
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
$part1 = Next-Password "hepxcrrq"
write-host "Answer for part 1: $part1" -ForegroundColor Magenta
