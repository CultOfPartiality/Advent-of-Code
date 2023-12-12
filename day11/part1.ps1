. "$PSScriptRoot\..\Unit-Test.ps1"

function part1 {
    #Standard Inputs
    param ($path)

    $rawInput = Get-Content $path

    #
    # Expand Universe
    #

    #Expand Rows
    $expandedRows = $rawInput|%{$_ -match "#" ? $_ : $_,$_}
    $maxRow = $expandedRows.Count-1
    $maxCol = $expandedRows[0].Length-1
    #Expand columns.
    #Scan colum to check for galexy
    $toExtendCol = 0..$maxCol | %{
        $colIndex = $_
        $colData = $expandedRows | %{$_[$colIndex]} | Join-String 
        $colData -notmatch "#"
    }
    #if column contains galexy, duplicate entry in that column for every row
    $expandedCols = 0..$maxRow | %{
        $row = $_
        ,@(0..($toExtendCol.Length-1) | %{ $toExtendCol[$_] ? $expandedRows[$row][$_],$expandedRows[$row][$_] : $expandedRows[$row][$_]})
    }
    #Expand rows
    $universe = $expandedCols
    $maxRow = $universe.Count-1
    $maxCol = $universe[0].Length-1

    #
    # Find all galexies
    #
    $galexies = 0..$maxRow | %{
        $row = $_
        ($universe[$row] | Join-String | Select-String '#' -AllMatches).Matches | %{
            if($_.Index -ne $null) { 
                [PSCustomObject]@{x=$_.Index;y=$row}
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

Unit-Test ${function:part1} "$PSScriptRoot\testcases\Part1_374.txt" 374
# Unit-Test ${function:part1} "$PSScriptRoot\testcases\test2_8.txt" 8

$res = part1 -path "$PSScriptRoot\input.txt"
write-host "Part 1: $res" -ForegroundColor Magenta