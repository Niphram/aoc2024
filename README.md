# Advent of Code 2024 in Odin

[![Test](https://github.com/Niphram/aoc2024/actions/workflows/test.yml/badge.svg)](https://github.com/Niphram/aoc2024/actions/workflows/test.yml)

Learning Odin this year

## Running/Compiling

To just compile the binary, use `odin build day_XX`. This produces a binary for your OS. Then run the binary like any other binary.

Use `odin run` to compile and run the programs in one step: `odin run day_XX`.

### Using a different input file

By default all the programs load the input from `./day_XX/input.txt` (relative to the binary)

Pass a filepath as the first argument to load another file:
`./day_01.(bin|exe) my_day_1_input.txt`

Wenn using `odin run` you need to add a double-dash to pass arguments to the binary instead of the compiler: `odin run day_01 -- my_day_1_input.txt`

## Testing

Unit-tests can be run using `odin test day_XX`.

The `tests` folder contains a package that requires every other package and can be used to run all the tests at once (the github actions run these tests): `odin test ./tests -all-packages`
