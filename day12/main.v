module main

import arrays
import os

type InputShape = [][]bool

struct Space {
	width    u8
	height   u8
	presents []u8
}

struct Input {
	shapes []InputShape
	spaces []Space
}

fn (s Space) str() string {
	return '${s.width}x${s.height}: ${s.presents}'
}

fn parse_shape(shape_str string) InputShape {
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

struct ScoredShape {
	CombinedShape
	tilability f32
}

fn space_fits(space Space, shapes []Shape, combined_shapes []ScoredShape) bool {
	area := u32(space.width) * space.height
	three_by_three_area := u32(space.width - space.width % 3) * (space.height - space.height % 3)

	total_shape_bounding_area := u32(9) * arrays.sum(space.presents.map(u32(it))) or { 0 }

	if total_shape_bounding_area <= three_by_three_area {
		println('Space ${space} fits easily, 3x3 shapes next to each other use ${total_shape_bounding_area}, available 3x3 area ${three_by_three_area}')
		return true
	}

	mut total_shape_area := u32(0)
	for i in 0 .. shapes.len {
		total_shape_area += shapes[i].area * space.presents[i]
	}

	if total_shape_area > area {
		println('Space ${space} way too small, need to fit ${total_shape_area}')
		return false
	}

	mut remaining_area := f32(area)
	mut remaining_shape_area := total_shape_area
	mut remaining_presents := space.presents.clone()

	for combi in combined_shapes {
		for arrays.group[u8](remaining_presents, combi.counts).all(it[0] >= it[1]) {
			for i in 0 .. remaining_presents.len {
				remaining_presents[i] -= combi.counts[i]
			}
			// assume 15% of the tilability can be used
			adjusted_tilability := f32(1) - (f32(1) - combi.tilability) * 0.15
			remaining_area -= adjusted_tilability * (combi.width * combi.height())

			assert combi.area <= remaining_shape_area
			remaining_shape_area -= combi.area
			if remaining_area < 0 {
				println('Space ${space} seems too small, need to fit an extra area of ${remaining_shape_area}')
				return false
			}
			if remaining_presents.all(it == 0) {
				println('Space ${space} seems to fit, we are left with extra space of ${remaining_area}')
				return true
			}
		}
	}

	return true
}

fn main() {
	input_file := os.args[1] or { 'example_input.txt' }
	input := read_input(input_file) or { panic('Failed to read input: ${err}') }

	// for sh in input.shapes[0].shape(0).all_orientations() {
	// for sh in input.shapes[0].shape(0).combine(input.shapes[1].shape(1)) {
	// println('${sh}\n')
	// }

	shapes := arrays.map_indexed[InputShape, Shape](input.shapes, |i, s| s.shape(i))

	mut combined := combine_shapes(shapes, 3)

	mut scored_shapes := combined.map(fn (sh CombinedShape) ScoredShape {
		tilability := calculate_tilability_score(sh.Shape)
		return ScoredShape{
			CombinedShape: sh
			tilability:    tilability
		}
	})

	scored_shapes.sort(|a, b| (a.tilability == b.tilability && a.density() > b.density())
		|| a.tilability > b.tilability)

	// for sh in scored_shapes[0..10] {
	// 	println('${sh.CombinedShape}\ntilability: ${sh.tilability}\n')
	// }

	fitting_spaces := arrays.sum(input.spaces.map(if space_fits(it, shapes, scored_shapes) {
		1
	} else {
		0
	})) or { 0 }

	println('Result: ${fitting_spaces} spaces fit')
}
