module main

import os
import math

struct IdRange {
	start     i64
	end       i64
	start_str string
	end_str   string
}

fn read_input(filename string) ![]IdRange {
	data := os.read_file(filename) or { return error('Failed to read file: ${err}') }

	ranges[string] := data.trim_right('\n').split(',')
	mut result := []IdRange{cap: data.len}

	for r in ranges {
		start_str, end_str := r.str().split_once('-') or { return error('Invalid range: ${err}') }
		start := start_str.parse_uint(10, 64) or {
			return error('Invalid start: `${start_str}` (${err})')
		}
		end := end_str.parse_uint(10, 64) or { return error('Invalid end: `${end_str}` (${err})') }
		result << IdRange{start, end, start_str, end_str}
	}

	return result
}

fn sum_invalids(rng IdRange) i64 {
	mut res := i64(0)
	println(' -- ${rng.start_str}-${rng.end_str}')
	for id_len in rng.start_str.len .. rng.end_str.len + 1 {
		if id_len % 2 == 1 {
			continue
		}
		// 1-100 -- (1-9)|(1-9)
		// 2-100 -- (1-9)|(1-9)
		// 12-100 -- 1|(2-9) plus (2-9)|(1-9)
		// 10-95 -- (1-8)|(1-9) plus 9|(1-5)
		// for each even id length len, there are
		//   10^(len/2) - 1 possible repeating halves (including leading zero)
		//   minus (10^(len/2) - 1) / 9 for numbers with leading zeros
		//   minus those creating ids below range start, if len == start_str.len
		//     - start / 10^(len/2) [-1 if start - start/10^(len/2)*10^(len/2) < start/10^(len/2)]
		//   minus those creating ids above range end, if len == end_str.len
		po := math.powi(10, id_len / 2)
		start := if id_len == rng.start_str.len {
			upper := rng.start / po
			lower := rng.start - upper * po
			if lower > upper {
				upper + 1
			} else {
				upper
			}
		} else {
			// first number with id_len/2 digits w/o leading 0
			po / 10
		}
		end := if id_len == rng.end_str.len {
			upper := rng.end / po
			lower := rng.end - upper * po
			if lower < upper {
				upper
			} else {
				upper + 1
			}
		} else {
			po
		}
		println('    -- ${start}-${end - 1}')
		for halve_id in start .. end {
			println('    - ${halve_id}${halve_id}')
			res += halve_id * (po + 1)
		}
	}
	return res
}

fn main() {
	input := read_input('input.txt') or { panic('Failed to read input: ${err}') }

	mut p1sum := i64(0)
	for rng in input {
		p1sum += sum_invalids(rng)
	}

	println('Part 1: ${p1sum}')
	println('Part 2: ')
}
