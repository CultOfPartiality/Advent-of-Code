#Get input
#$inputSource = "$PSScriptRoot/example2.txt"
$inputSource = "$PSScriptRoot/input.txt"


# =================== Parse Data =================== #
$inputText = Get-Content $inputSource

$directions = $inputText[0]

$nodes = @{}
$inputText[2..$inputText.Length] | %{ 
    $nodeName = $_.Substring(0,3)
    $leftNode = $_.Substring(7,3)
    $rightNode = $_.Substring(12,3)
    $nodes."$nodeName" = [PSCustomObject]@{
        name = $nodeName;
        L = $leftNode;
        R = $rightNode;
        stepsToZ = @();
    }
}

$currentNodes = $nodes.Values | where {$_.Name[2] -eq "A"}

# =================== Walk Nodes =================== #
$loopCounts = $currentNodes | ForEach-Object {
    $node = $_
    $directionIndex = 0
    $steps=0
    while ($node.name[2] -ne "Z") {
        $steps++
        $nextNode = $node."$($directions[$directionIndex])"
        $node = $nodes."$nextNode"

        $directionIndex = $directionIndex -ge ($directions.Length-1) ? 0 : $directionIndex+1
    }
    $steps
}

#while( ($loopCounts|group).length -gt 1){$loopCounts=$loopCounts|sort;$loopCounts[0] *= 2}

function gcd{ 
    param ($a,$b)
    #Euclidean Algorithm
    while($b -ne 0){
        $temp = $b
        $b = $a % $b
        $a = $temp 
    }
    $a
}

function lcm{
    param($a,$b)
    $a * ($b/(gcd $a $b))
}

$combo = $loopCounts
while(($combo).Count -gt 1){
    $combo[1] = lcm $combo[0] $combo[1] 
    $combo = $combo[1..($combo.length-1)]
}
$combo