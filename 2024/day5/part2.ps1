. "$PSScriptRoot\..\..\Unit-Test.ps1"

function Solution {
    param ($Path)

    # Parse the data into the rules and the update orders
    $rawRules, $rawOrders = (get-content $Path).Where({ $_ -ne "" }).Where({ $_ -match "\|" }, 'Split')
    $rules = foreach ($line in $rawRules) { , ($line -split "\|" | % { [int]$_ }) }
    $orders = foreach ($line in $rawOrders) { , ($line -split ","  | % { [int]$_ }) }

    # For each update order, grab only rules that apply for both numbers in the update order
    # Then work through them, if we find one that's invalid then fault that order out and add to our list
    # This is basically the same process as part 1
    $invalidOrders = foreach ($order in $orders) {
        $applicableRules = $rules.Where({ $_[0] -in $order -and $_[1] -in $order })
        :pageLoop foreach ($page in $order) {
            foreach ($rule in $applicableRules) {
                if ( $order.IndexOf($rule[0]) -gt $order.IndexOf($rule[1])) {
                    , $order
                    break pageLoop
                }
            }
        }
    }

    # For each invalid, start a new list. For each page, scan from the start on the currently built new list:
    #   If there's no rule between the two pages, move to the next page, leaving the potential insertion index
    #    the same
    #   If there is a rule between them, and the new page must come before the existing page, then insert the 
    #    new page into the previously valid insertion index. If it has to come after the existing page, update
    #    the insertion index to be the existing page index + 1
    # After looping over all the characters in the new list, insert at the insertion index
    $total = 0
    foreach ($order in $invalidOrders) {
        $applicableRules = $rules.Where({ $_[0] -in $order -and $_[1] -in $order })
        $newOrder = [System.Collections.ArrayList]@()
        foreach ($page in $order) {
            $index = 0
            foreach ($existingPage in $newOrder) {
                $currentRule = $applicableRules.Where({ $existingPage -in $_ -and $page -in $_[1] })
                if ($currentRule.Count -lt 1) { continue }
                elseif ($currentRule[0][0] -eq $page) { break }
                else { $index = $newOrder.IndexOf($existingPage) + 1}
            }
            $newOrder.Insert($index, $page)
        }
        # Once ordered correctly, add the middle page to the total
        $total += $neworder[($neworder.Count - 1) / 2]
    }

    # Output the final total
    $total


}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 123
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

