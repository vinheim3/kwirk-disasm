import sys
import clipboard

# Extracts a number of bytes directly from the rom in rows of x (perRow)
# If 0 is specified for perRow, words are returned instead

if len(sys.argv) < 4:
    print('Usage: ' + sys.argv[0] + ' startAddress endAddress perRow')
    sys.exit()

with open('OK.gb', 'rb') as f:
    data = f.read()

start, end, groups = sys.argv[1:]

start = int(f"0x{start}", 16)
end = int(f"0x{end}", 16)
groups = int(groups)

bytes = data[start:end+1]

comps = []
if groups != 0:
    curr_comp = []
    for i, byte in enumerate(bytes):
        if i != 0 and i%groups == 0:
            full_str = "	.db "+" ".join(f"${byte:02x}" for byte in curr_comp)
            comps.append(full_str)
            curr_comp = []
        curr_comp.append(byte)
    if curr_comp:
        full_str = "	.db "+" ".join(f"${byte:02x}" for byte in curr_comp)
        comps.append(full_str)
else:
    curr_comp = []
    for i, byte in enumerate(bytes):
        if i != 0 and i%2 == 0:
            full_str = f"	.dw ${curr_comp[1]:02x}{curr_comp[0]:02x}"
            comps.append(full_str)
            curr_comp = []
        curr_comp.append(byte)
    if curr_comp:
        if len(curr_comp) == 2:
            full_str = f"	.dw ${curr_comp[1]:02x}{curr_comp[0]:02x}"
        else:
            full_str = f"	.db ${curr_comp[0]:02x}"
        comps.append(full_str)

final_str = "\n".join(comps)
clipboard.copy(final_str)
print(final_str)