
def part2(testNum):
    recipies = [3,7]
    elf1 = 0
    elf2 = 1
    start = testNum

    test = []
    while(len(testNum) > 1):
        test.append(int(testNum[0]))
        testNum = testNum[1:]
    test.append(int(testNum[0]))

    #print(test)

    while(True):
        new = recipies[elf1]+recipies[elf2]
        if(new >= 10):
            recipies.append(1)
            if recipies[-1] == 1:
                if recipies[(-len(test)):] == test:
                    break
        new2 = new % 10
        recipies.append(new2)
        if recipies[-1] == new2:
                if recipies[(-len(test)):] == test:
                    break
        elf1 = (elf1 + 1 + recipies[elf1]) % len(recipies)
        elf2 = (elf2 + 1 + recipies[elf2]) % len(recipies)

        if recipies[-1] == new2:
            if recipies[(-len(test)):] == test:
                break

    print( start +" -> "+str( len(recipies) - len(test) ))

part2("51589")
part2("01245")
part2("92510")
part2("59414")
part2("864801")