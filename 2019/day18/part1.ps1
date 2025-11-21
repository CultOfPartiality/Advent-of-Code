. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

#function Solution {
#    param ($Path)


# The tunnels are too narrow to move diagonally.
# Only one entrance (marked @) is present among the open passages (marked .) and stone walls (#), but you also detect an assortment of keys (shown as lowercase letters) and doors (shown as uppercase letters)


<#### Step 1 - Read in, parse into raw map ####>
$data = get-content $Path
$Width = $data[0].Length
$Height = $data.Count
$RawMap = New-Object "char[,]" $Width,$Height
for ($y = 0; $y -lt $Height; $y++) {
    for ($x = 0; $x -lt $Width; $x++) {
        $RawMap[$x,$y] = $data[$y][$x]
    }
}
<#### Step 1.1 - Setup data structure. Since we only care about distance between important nodes, we can shrink the workload down to a graph
                 Include our location in the structure ####>

<#### Step 1.2? - Write a function for walking the structure to get distances to every item from current location ####>

<#### Step 3 - Setup a fifo/priority queue, and try every option available (e.g. if you could get 2 keys to start, try both).
               Update the map when keys found to remove walls
               Do search depth first, so we can prune paths towards the end ####>

<#
best = maxINT
while fifo not empty
    get map to check
    get distance to all keys
    calculate possible keys to get next
    for each possible key
        Update location & total steps
        Remove new key's wall (Prune any nodes that now have no wall, update links)
        if total steps more than best case so far
            continue
        If any keys left
            Add back to fifo
        else if total steps < best
            best = total steps
#>


#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
#Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

