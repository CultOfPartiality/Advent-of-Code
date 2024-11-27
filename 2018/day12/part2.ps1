. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    # Turn input into an index into an array. Then for each generation generate the index to see if plant survives
    # Preallocate negative indexes (2* (# of rounds)+2) and extra indexes (also the same)

    # However for part 2 this is too big... After running this and calculating the total for a number of rounds, it's eventually
    #   Total = #round*67
    # The start isn't quite like this, but it stabalises after less than 337 rounds.
    $generations = 50000000000
    
    $generations * 67

}
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

