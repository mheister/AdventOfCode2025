module main

import arrays
import os

fn read_input(filename string) ![][]u8 {
	data := os.read_file(filename) or { return error('Failed to read file: ${err}') }

	banks[string] := data.split_into_lines()
	mut result := [][]u8{cap: banks.len}

	for bank in banks {
		mut result_bank := []u8{cap: bank.str().len}
		for c in bank.str() {
			result_bank << (c - `0`).bytes()[0]
		}
		result << result_bank
	}

	return result
}

fn get_jolt(bank []u8, n_bats u8) !u64 {
	mut res := u64(0)
	mut hi_idx := -1
	for digit in 0 .. n_bats {
		keep_digits := n_bats - digit - 1
		hi_idx = arrays.idx_max(bank[hi_idx + 1..bank.len - keep_digits])! + hi_idx + 1
		res = res * 10 + bank[hi_idx]
	}
	return res
}

fn main() {
	// input := read_input('example_input.txt') or { panic('Failed to read input: ${err}') }
	input := read_input('input.txt') or { panic('Failed to read input: ${err}') }

	mut total_jolt_2bats := u64(0)
	mut total_jolt_12bats := u64(0)
	for bank in input {
		total_jolt_2bats += get_jolt(bank, 2) or { panic('${err}') }
		total_jolt_12bats += get_jolt(bank, 12) or { panic('${err}') }
	}

	println('Part 1: ${total_jolt_2bats}')
	println('Part 2: ${total_jolt_12bats}')
}
