# UInt classes have pop_count and other cool methods
[Uint16]::PopCount(15)
[Uint16]::RotateLeft(0x8000,1)
[Uint16]::RotateRight(0x0001,1)


#Splitting arrays (optimise some previous helper functions?)
$bigList = 1..1000

$counter = [pscustomobject] @{ Value = 0 }
$groupSize = 100

$groups = $bigList | Group-Object -Property { [math]::Floor($counter.Value++ / $groupSize) }


# Array comparisons. Performance?
[Collections.Generic.SortedSet[String]]::CreateSetComparer().Equals($a,$b)

#LINQ?
# https://learn.microsoft.com/en-us/dotnet/csharp/linq/

#Hashset class?
# https://learn.microsoft.com/en-us/dotnet/api/system.collections.generic.hashset-1?view=net-9.0