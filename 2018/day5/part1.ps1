. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
   param ($Path)


    $polymer = [System.Collections.ArrayList] ((get-content $Path).ToCharArray() | %{ [int]$_ })
    $keepReacting = $true
    while($keepReacting){
        $i=0
        write-host "Polymer length: " $polymer.Count
        # If a reaction took place, then we'll do another round
        $keepReacting = $false
        while($i -lt ($polymer.Count-1)){
            # Convert both chars to ASCII. Two letters with different capitalisation differ by 32
            $unitASCIIDiff = [math]::ABS($polymer[$i] - $polymer[$i+1])
            # Jump the index back one if we did a removal, to speed up the process
            # If a removal ajoins two more units that can be removed, then lets do that immediately
            if($unitASCIIDiff -eq 32){
                $polymer.RemoveRange($i,2)
                $keepReacting=$true
                $i = [math]::Max(0,$i-1)
            }
            else{$i++}
        }
    }
    write-host "Final length: " $polymer.Count
    $polymer.Count
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 10
$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

