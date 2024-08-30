fa = 16807
fb = 48271
d = 0x7FFFFFFF

def part_a(a, b, times):
    count = 0
    for _ in range(times):
        a = (a * fa) % d
        b = (b * fb) % d
        if a & 0xffff == b & 0xffff:
            count += 1
    return count

part_a(65,8921,40000000)