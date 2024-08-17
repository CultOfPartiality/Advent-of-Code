import sys
import hashlib

text = sys.argv[1]
repeats = int(sys.argv[2])
for i in range(repeats):
    text = hashlib.md5(text.encode('UTF-8')).hexdigest()

print(text)