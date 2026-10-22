. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $entries = [int[]] (get-content $Path)
    foreach($entry in $entries){
        $Round1Other = 2020 - $entry
        $entryIndex = $entries.IndexOf($entry)
        $otherEntries = $entries | select -SkipIndex $entryIndex

        foreach($entry2 in $otherEntries){
            $Round2Other = $Round1Other - $entry2
            if($otherEntries.Contains($Round2Other)){
                return ($entry * $entry2 * $Round2Other)
            }
        }        
    }
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 241861950
$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
