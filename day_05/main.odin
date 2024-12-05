package day_05

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
import "core:testing"

import "../parse"
import "../utils"

read_comma :: proc(s: ^string) -> (result: rune, ok: bool) {
	return parse.take(s, ',')
}

part_1 :: proc(input: string) -> (middle_pages_sum: int) {
	page_order_string, update_string :=
		utils.split_once(input, "\n\n") or_else panic("Can't split input")

	rules := make([dynamic][2]int)
	defer delete(rules)

	for line in strings.split_lines_iterator(&page_order_string) {
		line := line

		left := parse.read_number(&line) or_break
		parse.take(&line, '|') or_break
		right := parse.read_number(&line) or_break

		append(&rules, [2]int{left, right})
	}


	check_update_loop: for update in strings.split_lines_iterator(&update_string) {
		update := update

		pages: [dynamic]int
		defer delete(pages)

		for {
			page := parse.read_number(&update) or_break
			append(&pages, page)
			parse.take(&update, ',')
		}


		for page, i in pages {
			for rule in rules {
				if rule.x == page {
					if slice.contains(pages[:i], rule.y) {
						continue check_update_loop
					}
				}
			}
		}

		middle_pages_sum += pages[len(pages) / 2]
	}

	return
}

part_2 :: proc(input: string) -> (middle_pages_sum: int) {
	page_order_string, update_string :=
		utils.split_once(input, "\n\n") or_else panic("Can't split input")

	rules := make([dynamic][2]int)
	defer delete(rules)

	for line in strings.split_lines_iterator(&page_order_string) {
		line := line

		left := parse.read_number(&line) or_break
		parse.take(&line, '|') or_break
		right := parse.read_number(&line) or_break

		append(&rules, [2]int{left, right})
	}


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

		page_loop: for page, i in pages {
			for rule in rules {
				if rule.x == page {
					if slice.contains(pages[:i], rule.y) {
						invalid_update = true
						break page_loop
					}
				}
			}
		}

		if !invalid_update {
			continue
		}

		sorted := false
		for !sorted {
			sorted = true

			for page, i in pages {
				for rule in rules {
					if rule.x == page {
						if idx, ok := slice.linear_search(pages[:i], rule.y); ok {

							pages[idx], pages[i] = pages[i], pages[idx]

							sorted = false
						}
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
