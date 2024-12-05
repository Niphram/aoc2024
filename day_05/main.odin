package day_05

import "core:container/bit_array"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
import "core:testing"

import "../parse"
import "../utils"

parse_rules :: proc(rules: string) -> ^bit_array.Bit_Array {
	prio_rules := bit_array.create(9999, 1111) or_else panic("Could not initialize bitset")

	rules := rules
	for rule in strings.split_lines_iterator(&rules) {
		rule := rule

		left := parse.read_number(&rule) or_break
		parse.take(&rule, '|') or_break
		right := parse.read_number(&rule) or_break

		bit_array.set(prio_rules, left * 100 + right)
	}

	return prio_rules
}

parse_update :: proc(update: string) -> [dynamic]int {
	update := update

	pages: [dynamic]int

	for {
		page := parse.read_number(&update) or_break
		append(&pages, page)
		parse.take(&update, ',')
	}

	return pages
}


part_1 :: proc(input: string) -> (middle_pages_sum: int) {
	rules_string, update_string :=
		utils.split_once(input, "\n\n") or_else panic("Can't split input")

	rules := parse_rules(rules_string)
	defer bit_array.destroy(rules)

	update_loop: for update in strings.split_lines_iterator(&update_string) {
		pages := parse_update(update)
		defer delete(pages)

		for pl, i in pages {
			for pr, j in pages[i + 1:] {
				if bit_array.get(rules, pr * 100 + pl) {
					continue update_loop
				}
			}
		}

		middle_pages_sum += pages[len(pages) / 2]
	}

	return
}

part_2 :: proc(input: string) -> (middle_pages_sum: int) {
	rules_string, update_string :=
		utils.split_once(input, "\n\n") or_else panic("Can't split input")


	rules := parse_rules(rules_string)
	defer bit_array.destroy(rules)

	for update in strings.split_lines_iterator(&update_string) {
		update := update

		pages: [dynamic]int
		defer delete(pages)

		for {
			page := parse.read_number(&update) or_break
			append(&pages, page)
			parse.take(&update, ',')
		}

		invalid_update := false

		page_loop: for pl, i in pages {
			for pr, j in pages[i + 1:] {
				if bit_array.get(rules, pr * 100 + pl) {
					invalid_update = true
					break page_loop
				}
			}
		}

		if !invalid_update {
			continue
		}

		sorted := false
		for !sorted {
			sorted = true

			for &pl, i in pages {
				for &pr, j in pages[i + 1:] {
					if bit_array.get(rules, pr * 100 + pl) {
						pl, pr = pr, pl
						sorted = false
					}
				}
			}
		}

		middle_pages_sum += pages[len(pages) / 2]
	}

	return
}

main :: proc() {
	input := os.read_entire_file("day_05/input.txt") or_else panic("Could not read input file")
	defer delete(input)

	fmt.printfln("Part 1: %i", part_1(string(input)))
	fmt.printfln("Part 2: %i", part_2(string(input)))
}

EXAMPLE_INPUT: string : `47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
`


@(test)
part1_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(EXAMPLE_INPUT), 143)
}

@(test)
part2_test :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(EXAMPLE_INPUT), 123)
}
