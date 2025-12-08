module main

import os

fn read_input(filename string) ![]i64 {
	data := os.read_file(filename) or { return error('Failed to read file: ${err}') }

	lines[string] := data.split_into_lines()
	mut result := []i64{cap: data.len}

	for l in lines {
		rot := l.str().replace_once('L', '-').replace_once('R', '').parse_int(10, 64) or {
			return error('Failed to read line: ${err}')
		}
		result << rot
	}

	return result
}

fn main() {
	input := read_input('input.txt') or { panic('Failed to read input: ${err}') }

	mut dial := i64(50)
	mut zeros_between_rots := 0
	mut zeros := 0

	for rot in input {
		if rot < 0 {
			zeros += int(((100 - dial) % 100 - rot) / 100)
		} else {
			zeros += int((dial + rot) / 100)
		}
		dial = (dial + rot) % 100
		if dial < 0 {
			dial += 100
		}
		if dial == 0 {
			zeros_between_rots += 1
		}
	}

	println('Part 1: ${zeros_between_rots} zeros')
	println('Part 2: ${zeros} zeros')
}
