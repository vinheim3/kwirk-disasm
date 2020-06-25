import clipboard

string = ".db $18 $0e $14 $ff $0b $0e $12 $04 $20"
string = string[4:]

hexchars = [int(f"0x{char[1:]}", 16) for char in string.split()]

adjusted_chars = []

for char in hexchars:
    if char == 0xff:
        adjusted_chars.append(" ")
    elif char == 0x1d:
        adjusted_chars.append("#")
    elif char == 0x1e:
        adjusted_chars.append("'")
    elif char == 0x1f:
        adjusted_chars.append("-")
    elif char == 0x20:
        adjusted_chars.append("!")
    elif char == 0x21:
        adjusted_chars.append("?")
    elif char == 0xe0:
        adjusted_chars.append(":")
    elif char >= 0x3c:
        adjusted_chars.append(chr(char-0x3c+ord("0")))
    else:
        adjusted_chars.append(chr(char+ord("A")))

final_str = ".asc \"" + "".join(adjusted_chars) + "\""
print(final_str)
clipboard.copy(final_str)
