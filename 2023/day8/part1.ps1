#Get input
#$inputSource = "$PSScriptRoot/example.txt"
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
    }
}

# =================== Walk Nodes =================== #
$currentNode = $nodes."AAA"
$directionIndex = 0
$steps = 0
while ($currentNode.name -ne "ZZZ") {
    $nextNode = $currentNode."$($directions[$directionIndex])"
    $currentNode = $nodes."$nextNode"
    $steps++
    $directionIndex = $directionIndex -ge ($directions.Length-1) ? 0 : $directionIndex+1
}
write-host "$steps steps taken to reach ZZZ"