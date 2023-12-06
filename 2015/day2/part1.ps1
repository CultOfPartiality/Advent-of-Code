$inputSource = "$PSScriptRoot/input.txt"

$dimensions = Get-Content $inputSource | %{ ,@( [int[]]($_ -split 'x') | Sort-Object ) } 
$area = $dimensions | %{ 3*$_[0]*$_[1] + 2*$_[0]*$_[2] + 2*$_[1]*$_[2] }
$total = $area | measure -sum | select -ExpandProperty Sum

$ribbons = $dimensions | %{ 2*($_[0]+$_[1]) + $_[0]*$_[1]*$_[2] }
$totalRibbon = $ribbons | measure -sum | select -ExpandProperty Sum

write-host "Solution: $total feet^2 of paper, $totalRibbon feet of ribbon"