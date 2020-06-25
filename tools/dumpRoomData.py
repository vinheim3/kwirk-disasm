with open('OK.gb', 'rb') as f:
    data = f.read()

addr = 0x4250
end_addr = 0x5bd3
refs = []

for i in range(450):
    b1 = data[addr+i*2]
    b2 = data[addr+i*2+1]
    refs.append((b2<<8)+b1)

types = ["roomSizeData", "roomObjectPositionData", "roomObjectTypeData"]
ref_to_type_map = {
    ref: types[i//150]
    for i, ref in enumerate(refs)
}
ref_to_i_map = {
    ref: (i%150)+1
    for i, ref in enumerate(refs)
}

sorted_refs = sorted(refs)

# map of reference to its list of bytes
ref_byte_map = {}
for i in range(len(sorted_refs)-1):
    ref = sorted_refs[i]
    ref2 = sorted_refs[i+1]
    ref_byte_map[ref] = data[ref:ref2]
# last
ref_byte_map[sorted_refs[-1]] = data[sorted_refs[-1]:end_addr]

# map of room index to if room is big or not
big_room_map = {
    i+1: ref_byte_map[ref][0]>0x10
    for i, ref in enumerate(refs[:150])
}


unique_objects = set()


headers = ["roomSizeTable", "roomObjectPositionsTable", "roomObjectTypesTable"]
out = []
for i, ref in enumerate(refs):
    if i % 150 == 0:
        out.append(f"{headers[i//150]}:")
    out.append(f"	.dw {ref_to_type_map[ref]}_{ref_to_i_map[ref]:03}")

for ref in sorted_refs:
    ref_type = ref_to_type_map[ref]
    bytes = ref_byte_map[ref]
    room_index = ref_to_i_map[ref]

    if ref_type == "roomObjectTypeData":
        unique_objects |= set(bytes)

    # TODO: figuring out how rooms > 30 are loaded
    # room size there is related to how the path leading out of the room is loaded

    out.append(f"{ref_type}_{ref_to_i_map[ref]:03}:")
    if ref_type != "roomObjectPositionData":
        out.append("	.db " + " ".join(f"${byte:02x}" for byte in bytes))
    else:
        if room_index > 30:
            for i in range(len(bytes)//2):
                out.append(f"	dwbe %{bytes[i*2]:08b}{bytes[i*2+1]:08b}")
        else:
            if big_room_map[room_index]:
                for i in range(len(bytes)//3):
                    out.append(f"	dlbe %{bytes[i*3]:08b}{bytes[i*3+1]:08b}{bytes[i*3+2]:08b}")
            else:
                for i in range(len(bytes)//2):
                    out.append(f"	dwbe %{bytes[i*2]:08b}{bytes[i*2+1]:08b}")

print("\n".join(out))
unique_objects = sorted(list(unique_objects))
print(";"+" ".join(f"${byte:02x}" for byte in unique_objects))