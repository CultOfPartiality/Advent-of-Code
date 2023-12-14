
#transpose array of strings
$transBlock = 0..($block[0].Length-1) | %{
	$col = $_
	0..($block.Count-1) | %{
		$row = $_
		$block[$row][$col]
	} | Join-String
}
