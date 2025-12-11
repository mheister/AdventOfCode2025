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
	input := read_input('input.txt') or { panic('Failed to read input: ${err}') }

	println('${input}')
	solution_part1 := arrays.reduce(input.map(|p| solve_cepha_problem(p)), |l, r| l + r)!

	println('Part 1: solution is ${solution_part1}')
	println('Part 2: ')
}
