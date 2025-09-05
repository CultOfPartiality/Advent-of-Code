. "$PSScriptRoot\..\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/../testcases/test1.txt"

function Solution {
    param ($Path)

    $originalMemory = (get-content $Path) -split ',' | % { [int]$_ } 

    function RunComputer{
        param($data,$Noun,$Verb)
        
        $data[1] = $Noun
        $data[2] = $Verb

        $index = 0
        while ($data[$index] -ne 99) {
            $indexes = $data[($index + 1)..($index + 3)]
            if ($data[$index] -eq 1) {
                $data[$indexes[2]] = $data[$indexes[0]] + $data[$indexes[1]]
            }
            elseif ($data[$index] -eq 2) {
                $data[$indexes[2]] = $data[$indexes[0]] * $data[$indexes[1]]
            }
            $index += 4
        }
        $data[0]
    }
    
    foreach ($noun in 0..99) {
        foreach ($verb in 0..99) {
            $val = RunComputer -data $originalMemory.Clone() -Noun $noun -Verb $verb
            if($val -eq 19690720){
                return 100*$noun + $verb
            }
        }
    }
}
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 3500
$measuredTime = measure-command { $result = Solution "$PSScriptRoot/../input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

