module main

import os

fn read_input(filename string) ![]i64 {
	data := os.read_file(filename) or { return error('Failed to read file: ${err}') }

	lines[string] := data.split_into_lines()
	mut result := []i64{cap: data.len}

	for l in lines {
		rot := l.str().parse_int(10, 64) or { return error('Failed to read line: ${err}') }
		result << rot
	}

	return result
}

fn main() {
	input_file := os.args[1] or { 'example_input.txt' }
	input := read_input(input_file) or { panic('Failed to read input: ${err}') }

	println('Part 1: ')
	println('Part 2: ')
}
