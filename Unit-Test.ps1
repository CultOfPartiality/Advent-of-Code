<#
Use like:

    Unit-Test ${function:Total-Numbers} '[1,2,3]' 6
    Unit-Test ${function:Solution} @{ Num1=1234; Num2=2345 } 22

Function might best look like:

    function part1 {
        param ($rawInput,[switch]$showWorking)
    }

#>
function Unit-Test {
    param ([scriptblock]$function,$inputData,$expectedAnswer)
    write-host "Example '$inputData': " -NoNewline -ForegroundColor Yellow
    $answer = $function.InvokeReturnAsIs($inputData)
    if($answer -eq $expectedAnswer){
        write-host "Example passed ✔ " -ForegroundColor Green
        #Return $true
    }
    else{
        write-host "Example failed ✖  | " -NoNewline -ForegroundColor Red
        Write-host "Expected '$expectedAnswer', produced '$answer'" -ForegroundColor Red
        exit 
    }   
}

