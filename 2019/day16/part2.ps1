. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $RealSignal = (get-content $Path).ToCharArray() | % { [int]"$_" }
    $InputSignal_SecondHalf = $RealSignal*5000
    $MessageOffset = [int]($RealSignal[0..6] -join "")
    $MessageOffset_FromTheEnd = ($RealSignal.Count * 10000) - $MessageOffset
    write-host "`nInput is $($RealSignal.Count) digits long"
    write-host "Expanded input is $($RealSignal.Count * 10000) digits long"
    write-host "Message offset is $MessageOffset"

    function FFT {
        param ($InputSignal_SecondHalf,$MessageOffset)
        $result = @()
        $tot = 0
        for ($i = 0; $i -lt $MessageOffset; $i++) {
            $tot = ($tot + $InputSignal_SecondHalf[0-1-$i]) % 10
            $result += $tot
        }
        [array]::Reverse($result)
        $result
    }

    1..100 | % {
        $InputSignal_SecondHalf = FFT -InputSignal $InputSignal_SecondHalf -MessageOffset $MessageOffset_FromTheEnd
        write-host "Completed iteration $_"
    }

    [int]($InputSignal_SecondHalf[0..7] -join "")

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test4.txt" 84462026
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test5.txt" 78725270
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test6.txt" 53553731
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

