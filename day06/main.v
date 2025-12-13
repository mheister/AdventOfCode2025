module main

import arrays
import os

enum Operation {
	add
	mul
}

struct CephaProblem {
	op Operation
mut:
	numbers []u64
}

fn fallible_map[T, U](arr []T, f fn (T) !U) ![]U {
	mut result := []U{cap: arr.len}
	for item in arr {
		result << f(item) or { return err }
	}
	return result
}

fn read_input(filename string) ![]CephaProblem {
	data := os.read_file(filename) or { return error('Failed to read file: ${err}') }

	lines[string] := data.split_into_lines()

	n_problems := lines.len - 1

	ops := fallible_map(lines.last().split_by_space(), fn (opstr string) !Operation {
		return match opstr {
			'+' { Operation.add }
			'*' { Operation.mul }
			else { error('invalid operation ${opstr}') }
		}
	})!

	mut result := ops.map(fn [n_problems] (o Operation) CephaProblem {
		return CephaProblem{
			op:      o
			numbers: []u64{len: n_problems}
		}
	})

	for l in 0 .. n_problems {
		numbers := fallible_map[string, u64](lines[l].str().split_by_space(), |x| x.parse_uint(10,
			64)) or { return error('Failed to read line: ${err}') }
		for i in 0 .. numbers.len {
			result[i].numbers[l] = numbers[i]
		}
	}

	return result
}

// part 2 :)
fn read_input_correctly(filename string) ![]CephaProblem {
	data := os.read_file(filename) or { return error('Failed to read file: ${err}') }

	lines[string] := data.split_into_lines()

	ops := fallible_map(lines.last().split_by_space(), fn (opstr string) !Operation {
		return match opstr {
			'+' { Operation.add }
			'*' { Operation.mul }
			else { error('invalid operation ${opstr}') }
		}
	})!

	max_line_len := arrays.fold[string, int](lines[0..lines.len - 1], 0, fn (acc int, elem string) int {
		if elem.len > acc {
			return elem.len
		}
		return acc
	})

	mut lines_transposed := []string{cap: max_line_len}
	mut new_line := ''
	for idx_rev in 1 .. max_line_len  + 1 {
		idx := max_line_len - idx_rev
		mut new_num := ''
		for line in lines[0..lines.len - 1] {
			if idx < line.len {
				new_num += line[idx].ascii_str()
			} else {
				new_num += ' '
			}
		}
		if new_num.trim_space().len == 0 {
			lines_transposed << new_line
			new_line = ''
			continue
		}
		if idx == 0 {
			lines_transposed << new_line + new_num
			continue
		}
		new_line += new_num + ' '
	}

	mut result := []CephaProblem{cap: ops.len}
	for idx in 0 .. ops.len {
		numbers := fallible_map[string, u64](lines_transposed[idx].str().split_by_space(),
			|x| x.parse_uint(10, 64)) or { return error('Failed to read line: ${err}') }
		result << CephaProblem{
			op:      ops.reverse()[idx]
			numbers: numbers
		}
	}

	return result
}

fn solve_cepha_problem(prob &CephaProblem) u64 {
	foldop := match prob.op {
		.add {
			fn (acc u64, elem u64) u64 {
				return acc + elem
			}
		}
		.mul {
			fn (acc u64, elem u64) u64 {
				return acc * elem
			}
		}
	}
	init := match prob.op {
		.add { u64(0) }
		.mul { 1 }
	}
	return arrays.fold[u64, u64](prob.numbers, init, foldop)
}

fn main() {
	input_file := os.args[1] or { 'example_input.txt' }

	input_part1 := read_input(input_file) or { panic('Failed to read input for part 1: ${err}') }

	solution_part1 := arrays.reduce(input_part1.map(|p| solve_cepha_problem(p)), |l, r| l + r)!

	input_part2 := read_input_correctly(input_file) or {
		panic('Failed to read input for part 2: ${err}')
	}

	solution_part2 := arrays.reduce(input_part2.map(|p| solve_cepha_problem(p)), |l, r| l + r)!

	println('Part 1: solution is ${solution_part1}')
	println('Part 2: solution is ${solution_part2}')
}
