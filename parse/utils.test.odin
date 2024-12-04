package parse

import "core:testing"

@(test)
test_first_index :: proc(t: ^testing.T) {
	TEST_CASES :: []struct {
		s, substr: string,
		idx:       int,
		ok:        bool,
	} {
		{"test-case", "test", 0, true},
		{"   test-case", "test", 3, true},
		{"   test", "test", 3, true},
		{"unknown", "test", -1, false},
	}

	for test_case in TEST_CASES {

		idx, ok := first_index(test_case.s, test_case.substr)
		testing.expect_value(t, ok, test_case.ok)
		testing.expect_value(t, idx, test_case.idx)
	}
}
