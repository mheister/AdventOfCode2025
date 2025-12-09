module main

import arrays
import os

// parse into a grid with extra border around
fn read_input(filename string) ![][]u8 {
	data := os.read_file(filename) or { return error('Failed to read file: ${err}') }

	lines[string] := data.split_into_lines()
	nrows := lines.len + 2
	ncols := lines[0].len + 2

	mut result := [][]u8{cap: nrows}

	result << []u8{len: ncols, cap: ncols, init: u8(`.`)}
	for l in lines {
		mut row := []u8{cap: ncols}
		row << u8(`.`)
		for c in l.str().runes().map(u8(it)) {
			row << c
		}
		row << u8(`.`)
		result << row
	}
	result << []u8{len: ncols, cap: ncols, init: u8(`.`)}

	return result
}

fn bitcount3(val u8) u8 {
	x := val & 1 + ((val & 0b10) >> 1) + ((val & 0b100) >> 2)
	println('r ${val:b} ${x}')
	return val & 1 + ((val & 0b10) >> 1) + ((val & 0b100) >> 2)
}

const offsets = [
	[-1, -1],
	[-1, 0],
	[-1, 1],
	[0, -1],
	[0, 1],
	[1, -1],
	[1, 0],
	[1, 1],
]

// row, col in original grid w/o border
fn count_adjacent_rolls(grid [][]u8, row int, col int) u8 {
	prow := row + 1
	pcol := col + 1
	return u8(offsets.filter(grid[prow + it[0]][pcol + it[1]] == u8(`@`)).len)
}

fn main() {
	// input := read_input('example_input.txt') or { panic('Failed to read input: ${err}') }
	input := read_input('input.txt') or { panic('Failed to read input: ${err}') }
	mut marked := input.clone()

	mut accesible_rolls_step1 := 0

	nrows := input.len - 2
	ncols := input[0].len - 2

	for row in 0 .. nrows {
		for col in 0 .. ncols {
			if input[row + 1][col + 1] != u8(`@`) {
				continue
			}
			if count_adjacent_rolls(input, row, col) < 4 {
				accesible_rolls_step1 += 1
				marked[row + 1][col + 1] = u8(`x`)
			}
		}
		str := arrays.join_to_string[u8](marked[row + 1][1..ncols + 1], '', |ch| ch.ascii_str())
		println('${str}')
	}
	println('')

	mut accesible_rolls_total := accesible_rolls_step1
	for {
		mut newly_removed := 0
		for row in 0 .. nrows {
			for col in 0 .. ncols {
				if marked[row + 1][col + 1] != u8(`@`) {
					continue
				}
				if count_adjacent_rolls(marked, row, col) < 4 {
					accesible_rolls_total += 1
					newly_removed += 1
					// mark immediately
					marked[row + 1][col + 1] = u8(`x`)
				}
			}
		}
		if newly_removed == 0 {
			break
		}
	}

	println('Part 1: ${accesible_rolls_step1}')
	println('Part 2: ${accesible_rolls_total}')
}
