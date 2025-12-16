module main

import arrays
import math
import os
import time

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

fn area(c1 Tile, c2 Tile) u64 {
	return (u64(math.abs(int(c2.x) - int(c1.x))) + 1) * (u64(math.abs(int(c2.y) - int(c1.y))) + 1)
}

fn find_intersecting_segment(c1 Tile, c2 Tile, tiles []Tile) ?[2]Tile {
	tl := Tile{
		x: math.min(c1.x, c2.x)
		y: math.min(c1.y, c2.y)
	}
	br := Tile{
		x: math.max(c2.x, c1.x)
		y: math.max(c2.y, c1.y)
	}
	for ts in arrays.window(tiles, size: 2) {
		x1, x2 := math.min(ts[0].x, ts[1].x), math.max(ts[0].x, ts[1].x)
		y1, y2 := math.min(ts[0].y, ts[1].y), math.max(ts[0].y, ts[1].y)
		// println('line: (${x1}, ${y1}) to (${x2}, ${y2})')
		assert x1 == x2 || y1 == y2
		if x2 <= tl.x || y2 <= tl.y {
			continue
		}
		if x1 >= br.x || y1 >= br.y {
			continue
		}
		return [Tile{
			x: x1
			y: y1
		}, Tile{
			x: x2
			y: y2
		}]!
	}
	return none
}

fn main() {
	input_file := os.args[1] or { 'example_input.txt' }
	input := read_input(input_file) or { panic('Failed to read input: ${err}') }

	// Part 1
	// Heuristic solution. In part 2 it turned out we can do much more in brute-force
	// without taking much time. I'll leave this here anyways.

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

	// Part 2
	// Brute-force search for largest square that does not intersect segments of tiles in
	// the input. Takes about 3 seconds.

	// s := find_intersecting_segment(tl, br, input) or { return }
	// println('Found intersecting segment: (${s[0].x}, ${s[0].y}) to (${s[1].x}, ${s[1].y})')
	// s_large := [Tile{
	// 	x: s[0].x - 1000
	// 	y: s[0].y - 1000
	// }, Tile{
	// 	x: s[1].x + 1000
	// 	y: s[1].y + 1000
	// }]!
	// render(input, [[tl, br]!, s_large])

	mut sw := time.new_stopwatch()
	mut max_area2 := i64(0)
	for i1 in 0 .. input.len {
		for i2 in i1 + 1 .. input.len {
			c1 := input[i1]
			c2 := input[i2]
			a := area(c1, c2)
			if a > max_area2 {
				if find_intersecting_segment(c1, c2, input) != none {
					continue
				}
				max_area2 = a
				tl = Tile{
					x: math.min(c1.x, c2.x)
					y: math.min(c1.y, c2.y)
				}
				br = Tile{
					x: math.max(c1.x, c2.x)
					y: math.max(c1.y, c2.y)
				}
			}
		}
		if sw.elapsed().seconds() > 1 {
			sw.restart()
			println('Searching... current max area: ${max_area2}, i1: ${i1}')
		}
	}

	println('Part 2: ${max_area2}')

	render(input, [[tl, br]!])
}
