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

fn get_jolt(bank []u8) !u8 {
	mut bank_wo_last := bank.clone()
	bank_wo_last.pop()
	idx1 := arrays.idx_max(bank_wo_last)!
	lower := arrays.max(bank[idx1 + 1..])!
	return bank[idx1] * 10 + lower
}

fn main() {
	// input := read_input('example_input.txt') or { panic('Failed to read input: ${err}') }
	input := read_input('input.txt') or { panic('Failed to read input: ${err}') }

	mut total_jolt := u64(0)
	for bank in input {
		total_jolt += get_jolt(bank) or { panic('${err}') }
	}

	println('Part 1: ${total_jolt}')
	println('Part 2: ')
}
