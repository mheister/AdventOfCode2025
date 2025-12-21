module main

import os

type Shape = [][]bool

struct Space {
	width    u8
	height   u8
	presents []u8
}

struct Input {
	shapes []Shape
	spaces []Space
}

fn parse_shape(shape_str string) Shape {
	mut res := [][]bool{cap: 3}
	for line in shape_str.split_into_lines()[1..] {
		res << line.runes().map(|r| r == `#`)
	}
	return res
}

fn parse_space(space_str string) !Space {
	dims_str, presents_str := space_str.split_once(': ') or {
		return error('Invalid space ${space_str}')
	}
	w, h := dims_str.split_once('x') or { return error('${err}') }
	presents := presents_str.split_by_space().map(|p| u8(p.int()))
	return Space{
		width:    u8(w.int())
		height:   u8(h.int())
		presents: presents
	}
}

fn fallible_map[T, U](arr []T, f fn (T) !U) ![]U {
	mut result := []U{cap: arr.len}
	for item in arr {
		result << f(item) or { return err }
	}
	return result
}

fn read_input(filename string) !Input {
	data := os.read_file(filename) or { return error('Failed to read file: ${err}') }

	shapes_str, spaces_str := data.rsplit_once('\n\n') or {
		return error('Failed to read file: ${err}')
	}

	spaces := fallible_map[string, Space](spaces_str.split_into_lines(), parse_space) or {
		return error('Failed to parse spaces: ${err}')
	}

	return Input{
		shapes: shapes_str.split('\n\n').map(parse_shape)
		spaces: spaces
	}
}

fn main() {
	input_file := os.args[1] or { 'example_input.txt' }
	input := read_input(input_file) or { panic('Failed to read input: ${err}') }

	println('Part 1: ')
	println('Part 2: ')
}
