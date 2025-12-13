module main

import arrays
import datatypes
import math
import os

struct JBox {
	x u32
	y u32
	z u32
mut:
	circuit_id int
	links      datatypes.Set[int]
}

fn read_input(filename string) ![]JBox {
	data := os.read_file(filename) or { return error('Failed to read file: ${err}') }

	lines[string] := data.split_into_lines()
	mut result := []JBox{cap: lines.len}

	for l in lines {
		x_str, yz_str := l.str().split_once(',') or { return error('Failed to read line: ${err}') }
		y_str, z_str := yz_str.split_once(',') or { return error('Failed to read line: ${err}') }
		x := x_str.parse_uint(10, 32) or { return error('Failed to parse x: ${err}') }
		y := y_str.parse_uint(10, 32) or { return error('Failed to parse y: ${err}') }
		z := z_str.parse_uint(10, 32) or { return error('Failed to parse z: ${err}') }
		result << JBox{
			x:          u32(x)
			y:          u32(y)
			z:          u32(z)
			circuit_id: -1
			links:      datatypes.Set[int]{}
		}
	}

	return result
}

fn dist_sq(a JBox, b JBox) u64 {
	dx := u64(a.x) - u64(b.x)
	dy := u64(a.y) - u64(b.y)
	dz := u64(a.z) - u64(b.z)
	return dx * dx + dy * dy + dz * dz
}

fn find_closest_pair(boxes []JBox, separate_circuits bool) (int, int) {
	mut min_dist := u64(0xFFFFFFFFFFFFFFFF)
	mut min_i := -1
	mut min_j := -1
	for i in 0 .. boxes.len {
		for j in i + 1 .. boxes.len {
			if separate_circuits && boxes[i].circuit_id != -1
				&& boxes[i].circuit_id == boxes[j].circuit_id {
				continue
			}
			if boxes[i].links.exists(j) {
				continue
			}
			d := dist_sq(boxes[i], boxes[j])
			if d < min_dist {
				min_dist = d
				min_i = i
				min_j = j
			}
		}
	}
	return min_i, min_j
}

fn join_circuits(mut boxes []JBox, id1 int, id2 int) {
	min_id := math.min(id1, id2)
	max_id := math.max(id1, id2)
	for mut box in boxes {
		if box.circuit_id == max_id {
			box.circuit_id = min_id
		}
	}
}

fn connect_pair(mut boxes []JBox, idx1 int, idx2 int, next_circuit_id int) int {
	mut next_id := next_circuit_id
	id1 := boxes[idx1].circuit_id
	id2 := boxes[idx2].circuit_id
	boxes[idx1].links.add(idx2)
	boxes[idx2].links.add(idx1)
	if id1 == -1 && id2 == -1 {
		boxes[idx1].circuit_id = next_id
		boxes[idx2].circuit_id = next_id
		next_id += 1
	} else if id1 != -1 && id2 == -1 {
		boxes[idx2].circuit_id = id1
	} else if id1 == -1 && id2 != -1 {
		boxes[idx1].circuit_id = id2
	} else if id1 != id2 {
		join_circuits(mut boxes, id1, id2)
	}
	return next_id
}

fn main() {
	input_file := os.args[1] or { 'example_input.txt' }
	mut input := read_input(input_file) or { panic('Failed to read input: ${err}') }

	mut next_circuit_id := 0

	num_iterations := if input_file.contains('example') { 10 } else { 1000 }
	for _ in 0 .. num_iterations {
		idx1, idx2 := find_closest_pair(input, false)
		assert idx1 != -1 && idx2 != -1
		next_circuit_id = connect_pair(mut input, idx1, idx2, next_circuit_id)
	}

	println('Total circuits after ${num_iterations} iterations: ${next_circuit_id}')

	mut circuit_sizes := []u32{len: next_circuit_id, cap: next_circuit_id, init: 0}
	for box in input {
		if box.circuit_id != -1 {
			circuit_sizes[box.circuit_id] += 1
		}
	}

	circuit_sizes.sort(b < a)

	println('Circuit sizes: ${circuit_sizes}')

	part1_solution := arrays.fold(circuit_sizes[0..3], u64(1), |acc, el| if el > 0 {
		acc * el
	} else {
		acc
	})

	println('Part 1: ${part1_solution}')

	mut part2_solution := u64(0)

	for {
		idx1, idx2 := find_closest_pair(input, true)
		assert idx1 != -1 && idx2 != -1
		next_circuit_id = connect_pair(mut input, idx1, idx2, next_circuit_id)
		if input[idx1].circuit_id == 0 && input.all(|b| b.circuit_id == 0) {
			println('All boxes connected into a single circuit after connecting boxes ${idx1} and ${idx2}.')
			part2_solution = u64(input[idx1].x) * u64(input[idx2].x)
			break
		}
	}

	println('Part 2: ${part2_solution}')
}
