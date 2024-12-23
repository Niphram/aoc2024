package small_bitset

import "base:intrinsics"

BitSet :: struct($N: uint) {
	data: [(N + 127) / 128]u128,
}

get :: proc(bitset: BitSet($N), i: uint) -> bool {
	part := bitset.data[i / 128]
	return bool(part & (1 << (i % 128)))
}

set :: proc(bitset: ^BitSet($N), i: uint) {
	bitset.data[i / 128] |= 1 << (i % 128)
}

unset :: proc(bitset: ^BitSet($N), i: uint) {
	bitset.data[i / 128] &= ~(1 << (i % 128))
}

card :: proc(bitset: BitSet($N)) -> uint {
	count: uint

	for part in bitset.data {
		count += uint(intrinsics.count_ones(part))
	}

	return count
}

BitsetIterator :: struct($N: uint) {
	bitset: ^BitSet(N),
	idx:    uint,
}


make_iterator :: proc(bitset: ^BitSet($N)) -> (it: BitsetIterator(N)) {
	return BitsetIterator(N){bitset = bitset}
}

iterate_by_set :: proc(it: ^BitsetIterator($N)) -> (index: uint, ok: bool) {
	for it.idx < N {
		index = it.idx
		it.idx += 1

		if get(it.bitset^, index) do return index, true
	}

	return
}

iterate_by_unset :: proc(it: ^BitsetIterator($N)) -> (index: uint, ok: bool) {
	for it.idx < N {
		index = it.idx
		it.idx += 1

		if !get(it.bitset^, index) do return index, true
	}

	return
}
