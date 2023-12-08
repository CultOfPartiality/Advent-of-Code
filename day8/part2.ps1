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
    }
}

$currentNodes = $nodes.Values | where {$_.Name[2] -eq "A"}

# =================== Walk Nodes =================== #
$directionIndex = 0
$steps = 0
while ( ($currentNodes.name | where {$_[2] -ne "Z"}).Count -ne 0 ) {
    $currentNodes =  $currentNodes | % {
        $nextNode = $_."$($directions[$directionIndex])"
        $nodes."$nextNode"    
    }
    $steps++
    $directionIndex = $directionIndex -ge ($directions.Length-1) ? 0 : $directionIndex+1
}
write-host "$steps steps taken for all starts to reach --Z"