. "$PSScriptRoot\..\..\Unit-Test.ps1"

function Solution {
    param ($Path)

    # Parse the data into the rules and the update orders
    $rawRules, $rawOrders = (get-content $Path).Where({ $_ -ne "" }).Where({ $_ -match "\|" }, 'Split')
    $rules = foreach ($line in $rawRules) { , ($line -split "\|" | % { [int]$_ }) }
    $orders = foreach ($line in $rawOrders) { , ($line -split ","  | % { [int]$_ }) }

    # For each update order, grab only rules that apply for both numbers in the update order
    # Then work through them, if we find one that's invalid then fault that order out
    # If they're all valid, then add the middle number to the total
    $total = 0
    foreach ($order in $orders) {
        $valid = $true
        $applicableRules = $rules.Where({ $_[0] -in $order -and $_[1] -in $order })
        :pageLoop foreach ($page in $order) {
            foreach ($rule in $applicableRules) {
                if ( $order.IndexOf($rule[0]) -gt $order.IndexOf($rule[1])) {
                    $valid = $false
                    break pageLoop
                }
            }
        }
        if ($valid) {
            $total += $order[($order.Count - 1) / 2]
        }
    }

    # Output the final total
    $total

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 143
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

