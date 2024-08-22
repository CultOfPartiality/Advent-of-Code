. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$number = 14

# function Solution {
#     param ($number)
    
$ringOddIndex = 3
$ringNum = 9
$midRingCorners = 1..3 | %{$ringNum - $_*($ringOddIndex - 1)}
$middles = $corners | %{$_ - ($ringOddIndex-1)/2}

$sumArray = @()
$sumArray += $null
$sumArray += 1

$index = 2
while ($sumArray[-1] -le $number) {
    # Find adjacent squares, that are less than this index
    # This is done by charaterising, and based on that we know what numbers to check for:
    #   First three corners - Check prev index, and prev ring's matching corner
    #   The final corner    - 
    #   A middle            - 
    #   An edge             - 
    switch ($index) {
        { $_ -in $corners} { }
        $ringNum { }
        { $_ -in $middles} { }
        Default { }
    } 
    # Increment the index, and go to next ring if needed
    $index++
    if ( $index -eq $ringNum ) {
        $ringOddIndex += 2
        $ringNum = $ringOddIndex * $ringOddIndex
        $corners = 1..3 | %{$ringNum - $_*($ringOddIndex - 1)}
        $middles = $corners | %{$_ - ($ringOddIndex-1)/2}
    }
}


# }

# Unit-Test  ${function:Solution} 1 0
# Unit-Test  ${function:Solution} 12 3
# Unit-Test  ${function:Solution} 23 2
# Unit-Test  ${function:Solution} 1024 31
# $measuredTime = measure-command { $result = Solution 325489 }
# Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

