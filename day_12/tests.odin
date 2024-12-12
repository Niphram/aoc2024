package day_12

import "core:testing"

EXAMPLE_1: string : `AAAA
BBCD
BBCC
EEEC
`


EXAMPLE_2: string : `OOOOO
OXOXO
OOOOO
OXOXO
OOOOO
`


EXAMPLE_3: string : `RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
`


EXAMPLE_4: string : `EEEEE
EXXXX
EEEEE
EXXXX
EEEEE
`


EXAMPLE_5: string : `AAAAAA
AAABBA
AAABBA
ABBAAA
ABBAAA
AAAAAA
`


@(test)
part_1_example_1 :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(transmute([]u8)EXAMPLE_1), 140)
}

@(test)
part_1_example_2 :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(transmute([]u8)EXAMPLE_2), 772)
}

@(test)
part_1_example_3 :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(transmute([]u8)EXAMPLE_3), 1930)
}
@(test)
part_2_example_1 :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(transmute([]u8)EXAMPLE_1), 80)
}

@(test)
part_2_example_2 :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(transmute([]u8)EXAMPLE_2), 436)
}

@(test)
part_2_example_3 :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(transmute([]u8)EXAMPLE_3), 1206)
}

@(test)
part_2_example_4 :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(transmute([]u8)EXAMPLE_4), 236)
}

@(test)
part_2_example_5 :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(transmute([]u8)EXAMPLE_5), 368)
}
