. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input.txt"

function OriginalSolution {
    param ($Path)

    $valid = 0
    $testVal,$limit = [int[]] ((get-content $Path) -split "-")
    
    while ($testVal -le $limit) {
        $val = ([string]$testVal).ToCharArray() | % { [int]$_ - 48 }
  
        #Check for validity
        $matchedPair = $false
        foreach ($pair in 0..4) {
            $matchedPair = $matchedPair -or ($val[$pair] -eq $val[$pair + 1])
            if ($val[$pair] -gt $val[$pair + 1]) {
                for ($i = $pair + 1; $i -lt 6; $i++) { 
                    $val[$i] = $val[$pair]
                }
                $matchedPair = $false
                $testVal = ([int]($val -join '')) - 1
                break
            }
        }
        if ($matchedPair) { $valid++ }
        $testVal++
    }
    $valid

}

function NewSolution {
    param ($Path)

    $valid = 0
    $testVal,$limit = [int[]] ((get-content $Path) -split "-")

    function isvalidnumber($inNumber) {
        $number = $inNumber
        $matchedPair = $false
        $increasing = $true
        for ($i = 0; $i -lt 5; $i++) {
            $lsn = $number % 10
            $number = [Math]::Truncate($number/10)
            $msn = $number % 10

            $matchedPair = $matchedPair -or ($lsn -eq $msn)
            $increasing = $increasing -and ($msn -le $lsn)
            if(!$increasing){
                for ($i = $i; $i -ge 0; $i--) {
                    $number = $number*10 + $msn
                }
                $inNumber = $number-1
                break
            }
        }
        return ($matchedPair -and $increasing), ($inNumber+1)
    }

    
    while ($testVal -le $limit) {
        $isvalid,$testVal = isvalidnumber($testVal)
        if ($isvalid) {$valid++}
    }
    $valid

}

<#
Run the test with:
    Invoke-Script -ScriptBlock {. "./2019/day4/part1_nostrings.ps1"} -Repeat 10 -Flag @{_profiler = $true}
    Turns out messing with string arrays is slightly faster????
#>
if($_profiler){
    write-host "New"
    $result = NewSolution "$PSScriptRoot\input.txt"
}
else{
    write-host "Old"
    $result = OriginalSolution "$PSScriptRoot\input.txt"
}

