library(readr)
library(stringr)
is.wholenumber <- function(x, tol = .Machine$double.eps^0.5)  abs(x - round(x)) < tol

# data <- read_lines("./2024/day13/testcases/test1.txt")
data <- read_lines("./2024/day13/input.txt")

total <- 0
for (i in seq(1, length(data), 4)) {
    ButtonA <- as.numeric(unlist(str_extract_all(data[i], "\\d+")))
    ButtonB <- as.numeric(unlist(str_extract_all(data[i + 1], "\\d+")))
    Prize <- as.numeric(unlist(str_extract_all(data[i + 2], "\\d+")))

    A <- matrix(data = c(ButtonA, ButtonB), nrow = 2, ncol = 2)
    b <- matrix(data = Prize, nrow = 2, ncol = 1)
    solved <- solve(A, b)

    if (i == 53) {
        print(paste("Index ", i, ": ", is.wholenumber(solved[1])))
    }
    if ( all (is.wholenumber(solved) )) {
        total <- total + 3 * solved[1] + solved[2]
    }
}
print(paste("Part 1: ", total))