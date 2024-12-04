package utils

import "core:testing"

@(test)
test_count_with_stride :: proc(t: ^testing.T) {
	testing.expect_value(t, count_with_stride("Test", "Test", 1), 1)
	testing.expect_value(t, count_with_stride("T e s t", "Test", 1), 0)
	testing.expect_value(t, count_with_stride("T e s t", "Test", 2), 1)
}
