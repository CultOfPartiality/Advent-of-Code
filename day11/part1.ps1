. "$PSScriptRoot\..\Unit-Test.ps1"

function part1 {
    #Standard Inputs
    param ($path)

    $universe = Get-Content $path
    $maxRow = $universe.Count-1
    $maxCol = $universe[0].Length-1

    #
    # Check for universe expansion
    #

    #Check which rows need expanding
    $expandRows = $universe|%{$_ -notmatch "#"}

    #Expand columns.
    #Scan colum to check for galexy
    $expandCols = 0..$maxCol | %{
        $colIndex = $_
        $colData = $universe | %{$_[$colIndex]} | Join-String 
        $colData -notmatch "#"
    }

    #
    # Find all galexies
    #

    $galexies = 0..$maxRow | %{
        $row = $_
        ($universe[$row] | Join-String | Select-String '#' -AllMatches).Matches | %{
            if($_.Index -ne $null) {
                #add expansions
                $numOfRowExpansions = $expandRows[0..$row] | measure -sum | select -ExpandProperty Sum
                $numOfColExpansions = $expandCols[0..$_.Index] | measure -sum | select -ExpandProperty Sum
                $x = $_.Index + $numOfColExpansions * ($global:expansion-1)
                $y = $row + $numOfRowExpansions * ($global:expansion-1)
                [PSCustomObject]@{x=$x;y=$y}
            }
        }
    }

    #
    # Get dist between every galexy 
    #
    $dists_x2 = $galexies | %{
        $A = $_
        $galexies.Where({$_ -ne $A}) | %{
            $B = $_
            [Math]::Abs($A.x-$B.x) + [Math]::Abs($A.y-$B.y)
        }
    } | measure -Sum |select -ExpandProperty Sum
    #since we have duplicates (g1 -> g2, and g2 -> g1), divide by 2
    $dists_x2/2

}

$expansion = 2
Unit-Test ${function:part1} "$PSScriptRoot\testcases\Part1_374.txt" 374
# Unit-Test ${function:part1} "$PSScriptRoot\testcases\test2_8.txt" 8
$expansion = 10
Unit-Test ${function:part1} "$PSScriptRoot\testcases\Part1_374.txt" 1030
$expansion = 100
Unit-Test ${function:part1} "$PSScriptRoot\testcases\Part1_374.txt" 8410

$expansion = 1000000
$res = part1 -path "$PSScriptRoot\input.txt"
write-host "Part 1: $res" -ForegroundColor Magenta