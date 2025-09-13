. "$PSScriptRoot\..\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\..\UsefulStuff.ps1"

# Reused IntCode computer this year
. "$PSScriptRoot\..\..\IntCodeComputer.ps1"


function Solution {
    param ($Path)

    $originalMemory = (get-content $Path) -split ',' | % { [int]$_ } 
    
    foreach ($noun in 0..99) {
        foreach ($verb in 0..99) {
            $Comp = [Computer]::New($originalMemory)
            $Comp.memory[1] = $noun
            $Comp.memory[2] = $verb
            $Comp.RunComputer($null)
            if($Comp.memory[0] -eq 19690720){
                return 100*$noun + $verb
            }
        }
    }
}
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 3500
$measuredTime = measure-command { $result = Solution "$PSScriptRoot/../input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

