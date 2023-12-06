$inputSource = "$PSScriptRoot/input.txt"

$results = (Get-Content $inputSource) -match '.*[aeiou].*[aeiou].*[aeiou].*' -match '([a-z])\1' -notmatch "ab|cd|pq|xy"

"Part 1: $($results.Count) results are nice"

$results = (Get-Content $inputSource) -match '([a-z]{2}).*\1' -match '([a-z]).\1'

"Part 2: $($results.Count) results are nice"