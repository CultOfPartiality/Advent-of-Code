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

    #Allow passing a hash into the unit test, for running the solution with multiple inputs
    if($inputData.Path){
        write-host "Example '$($inputData.Path)': " -NoNewline -ForegroundColor Yellow
    }
    else{
        write-host "Example '$inputData': " -NoNewline -ForegroundColor Yellow
    }

    $measuredTime = measure-command { $answer = $function.InvokeReturnAsIs($inputData) }
    if($answer -eq $expectedAnswer){
        write-host "Example passed ✔ ($($measuredTime.TotalSeconds)s)" -ForegroundColor Green
    }
    else{
        write-host "Example failed ✖  | " -NoNewline -ForegroundColor Red
        Write-host "Expected '$expectedAnswer', produced '$answer' ($($measuredTime.TotalSeconds)s)" -ForegroundColor Red
        exit 
    }   
}
