import sys
import hashlib

text = sys.argv[1]
hash = hashlib.md5(text.encode('UTF-8')).hexdigest()
print(hash)