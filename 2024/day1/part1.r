library(here)

f_Part1 <- function(path){
	raw_data = read.delim(file = path, sep="", header=FALSE)
	raw_data$V1 = sort(raw_data$V1)
	raw_data$V2 = sort(raw_data$V2)

	data = transform(raw_data, total= (abs(V1-V2)) )

	print(paste("Solution for part 1:",sum(data$total)))
}

f_Part1(here("2024/day1/testcases/test1.txt"))
f_Part1(here("2024/day1/input.txt"))