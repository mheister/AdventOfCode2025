module main

import math
import os

struct Tile {
	x u32
	y u32
}

fn read_input(filename string) ![]Tile {
	data := os.read_file(filename) or { return error('Failed to read file: ${err}') }

	lines[string] := data.split_into_lines()
	mut result := []Tile{cap: data.len}

	for l in lines {
		x_str, y_str := l.str().split_once(',') or { return error('Invalid line: ${l}') }
		x := x_str.parse_uint(10, 32) or { return error('Failed to parse x: ${err}') }
		y := y_str.parse_uint(10, 32) or { return error('Failed to parse y: ${err}') }
		result << Tile{
			x: u32(x)
			y: u32(y)
		}
	}

	return result
}

fn area_tlbr(tl Tile, br Tile) i64 {
	return (i64(br.x) - tl.x + 1) * (i64(br.y) - tl.y + 1)
}

fn area_trbl(tr Tile, bl Tile) i64 {
	return (i64(tr.x) - bl.x + 1) * (i64(bl.y) - tr.y + 1)
}

fn main() {
	input_file := os.args[1] or { 'example_input.txt' }
	input := read_input(input_file) or { panic('Failed to read input: ${err}') }

	mut tl_idx, mut br_idx := 0, 1
	mut tr_idx, mut bl_idx := 0, 1
	mut tl := input[tl_idx]
	mut br := input[br_idx]
	mut tr := input[tr_idx]
	mut bl := input[bl_idx]

	// pass one: find initial corners
	for piv in input {
		if piv.x <= tl.x && piv.y <= tl.y {
			tl = piv
		}
		if piv.x >= br.x && piv.y >= br.y {
			br = piv
		}
		if piv.x >= tr.x && piv.y <= tr.y {
			tr = piv
		}
		if piv.x <= bl.x && piv.y >= bl.y {
			bl = piv
		}
	}

	// pass two: refine corners
	for _ in 0 .. 10 {
		for piv in input {
			tlbr_area := area_tlbr(tl, br)
			if piv.x <= tl.x || piv.y <= tl.y {
				if area_tlbr(piv, br) > tlbr_area {
					tl = piv
				}
			}
			if piv.x >= tl.x || piv.y >= tl.y {
				if area_tlbr(tl, piv) > tlbr_area {
					br = piv
				}
			}
			trbl_area := area_trbl(tr, bl)
			if piv.x >= tl.x || piv.y <= tl.y {
				if area_trbl(piv, bl) > trbl_area {
					tr = piv
				}
			}
			if piv.x <= tl.x || piv.y >= tl.y {
				if area_trbl(tr, piv) > trbl_area {
					bl = piv
				}
			}
		}
	}

	tlbr_area := area_tlbr(tl, br)
	trbl_area := area_trbl(tr, bl)
	max_area := math.max(tlbr_area, trbl_area)
	println('Top-left: (${tl.x}, ${tl.y})')
	println('Bottom-right: (${br.x}, ${br.y})')
	println('Top-right: (${tr.x}, ${tr.y})')
	println('Bottom-left: (${bl.x}, ${bl.y})')

	println('Part 1: largest area is ${max_area}')
	println('Part 2: ')
}
