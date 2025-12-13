module main

import arrays
import os

fn read_input(filename string) ![][]u8 {
	data := os.read_file(filename) or { return error('Failed to read file: ${err}') }

	lines[string] := data.split_into_lines()
	mut result := [][]u8{cap: data.len}

	for l in lines {
		result << l.str().bytes()
	}

	return result
}

fn print_manifold(m [][]u8) {
	for l in m {
		str := arrays.join_to_string[u8](l, '', |x| x.ascii_str())
		println("${str}")
	}
}

fn find_beam_indices(row []u8) []int {
	mut indices := []int{cap: row.len}
	for i, val in row {
		match val {
			u8(`S`) {indices << i}
			u8(`|`) {indices << i}
			else {}
		}
	}
	return indices
}

fn shoot_beam(mut m [][]u8) u32 {
	mut splits := u32(0)
	for row in 1..m.len {
		beam_indices := find_beam_indices(m[row - 1])
		for idx in beam_indices {
			if m[row][idx] == u8(`.`) {
				m[row][idx] = u8(`|`)
			} else if m[row][idx] == u8(`^`) {
				m[row][idx - 1] = u8(`|`)
				m[row][idx + 1] = u8(`|`)
				splits++
			}
		}
	}
	return splits
}

fn main() {
	input_file := os.args[1] or { 'example_input.txt' }
	mut input := read_input(input_file) or { panic('Failed to read input: ${err}') }

	print_manifold(input)
	println('\n--- Shooting beam ---\n')
	splits := shoot_beam(mut input)
	print_manifold(input)

	println('Part 1: ${splits}')
	println('Part 2: ')
}
