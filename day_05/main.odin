package day_05

import "core:fmt"
import "core:slice"
import "core:strings"
import "core:testing"

import "../parse"
import "../utils"

RuleSet :: map[[2]int]struct {}

parse_rules :: proc(rules: string) -> (rules_set: RuleSet) {
	rules := rules
	for rule in strings.split_lines_iterator(&rules) {
		rule := rule

		left := parse.read_number(&rule) or_break
		parse.take(&rule, '|') or_break
		right := parse.read_number(&rule) or_break

		map_insert(&rules_set, [2]int{left, right}, struct {}{})
	}

	return
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

ruleset_cmp :: proc(a, b: int) -> bool {
	m := cast(^RuleSet)context.user_ptr

	return ([2]int{a, b}) in m^
}

part_1 :: proc(input: string) -> (middle_pages_sum: int) {
	rules_string, update_string :=
		utils.split_once(input, "\n\n") or_else panic("Can't split input")

	rules := parse_rules(rules_string)
	defer delete(rules)

	// Add ruleset to context
	context.user_ptr = &rules

	update_loop: for update in strings.split_lines_iterator(&update_string) {
		pages := parse_update(update)
		defer delete(pages)

		slice.is_sorted_by(pages[:], ruleset_cmp) or_continue

		middle_pages_sum += pages[len(pages) / 2]
	}

	return
}

part_2 :: proc(input: string) -> (middle_pages_sum: int) {
	rules_string, update_string :=
		utils.split_once(input, "\n\n") or_else panic("Can't split input")


	rules := parse_rules(rules_string)
	defer delete(rules)

	// Add ruleset to context
	context.user_ptr = &rules

	for update in strings.split_lines_iterator(&update_string) {
		update := update

		pages: [dynamic]int
		defer delete(pages)

		for {
			page := parse.read_number(&update) or_break
			append(&pages, page)
			parse.take(&update, ',')
		}

		if slice.is_sorted_by(pages[:], ruleset_cmp) {
			continue
		}

		slice.sort_by(pages[:], ruleset_cmp)

		middle_pages_sum += pages[len(pages) / 2]
	}

	return
}

main :: proc() {
	utils.aoc_main(part_1, part_2)
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
