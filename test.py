import lzw

# Compresses "example file.txt" into "example file.txt.lzw".
with open('compact.txt') as input_file:
    with open('compact.lzw', 'wb') as compressed_file:
        compressed_file.write(lzw.compress(input_file.read()))

# Decompresses and prints "example file.txt.lzw" content.
with open('compact.lzw', 'rb') as compressed_file:
    print(lzw.decompress(compressed_file.read()))