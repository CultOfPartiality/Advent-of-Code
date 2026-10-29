. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test2.txt"

# function Solution {
#     param ($Path)

$rawRules, $rawMyTicket, $rawTickets = (get-content $Path -Raw) -split ([System.Environment]::NewLine * 2)

$rules = $rawRules -split [System.Environment]::NewLine | % {
    , ($_ -replace ".*: ", "" -split " or " | % { , @([int[]]($_ -split "-")) })
}
function Check-Ticket {
    param($ticket, $rules)

    foreach ($value in $ticket) {
        $invalid = $true
        :valueCheck
        foreach ($rule in $rules) {
            foreach ($range in $rule) {
                if ($range[0] -le $value -and $value -le $range[1]) {
                    $invalid = $false
                    break valueCheck
                }
            }
        }
        if($invalid){
            return $false
        }
    }
    return $true
}

$myTicket = @( [int[]]( ($rawMyTicket -split [System.Environment]::NewLine)[1] -split ",") )
$tickets = $rawTickets -split [System.Environment]::NewLine | select -skip 1 | % { , @([int[]]($_ -split ",")) }
$validTickets = ($tickets | ?{Check-Ticket $_ $rules}) + ,@($myTicket)


#TODO Now for each field in order let it be any rule. Then loop and check each value, invalidating what rules could be for which spots




# }
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 71
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

