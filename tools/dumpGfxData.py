import sys

if len(sys.argv) < 3:
    print('Usage: ' + sys.argv[0] + ' startAddress size [spaced]')
    sys.exit()

start_address = int(f"0x{sys.argv[1]}", 16)
size = int(f"0x{sys.argv[2]}", 16)

with open('OK.gb', 'rb') as f:
    data = f.read()[start_address:start_address+size]

if len(sys.argv) == 4:
    newdata = bytearray()
    code = sys.argv[3]

    if code == 'b':
        for b in data:
            newdata.append(0)
            newdata.append(b)
    elif code == 'a':
        for b in data:
            newdata.append(b)
            newdata.append(0)
    else:
        print("[spaced] must be (b)efore or (a)fter")
else:
    newdata = data

with open("gfx_new.bin", 'wb') as f:
    f.write(newdata)
