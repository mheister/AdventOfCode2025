module main

import os
import math
import datatypes

type IdSet = datatypes.Set[i64]

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

fn get_invalids(rng IdRange, id_len int, repeats int) IdSet {
	mut res := IdSet{}
	// 121212 -- id_len 6, repeats 3, repeat_len 2
	if repeats <= 1 || id_len % repeats != 0 {
		return res
	}
	repeat_len := id_len / repeats
	if repeat_len < 1 || id_len % repeat_len != 0 {
		return res
	}
	po := math.powi(10, repeat_len)
	pou := math.powi(10, repeat_len * (repeats - 1))
	start := if id_len == rng.start_str.len {
		// try the first repeat_len digits, add one if too small
		upper := rng.start / pou
		mut repeated := i64(0)
		for _ in 0 .. repeats {
			repeated *= po
			repeated += upper
		}
		if rng.start > repeated {
			upper + 1
		} else {
			upper
		}
	} else {
		// first number with repeat_len digits w/o leading 0
		po / 10
	}
	end := if id_len == rng.end_str.len {
		upper := rng.end / pou
		mut repeated := i64(0)
		for _ in 0 .. repeats {
			repeated *= po
			repeated += upper
		}
		if rng.end < repeated {
			upper
		} else {
			upper + 1
		}
	} else {
		po
	}
	for halve_id in start .. end {
		mut id := i64(0)
		for _ in 0 .. repeats {
			id *= po
			id += halve_id
		}
		res.add(id)
	}
	return res
}

fn sum_invalids_part1(rng IdRange) i64 {
	mut ids := IdSet{}
	for id_len in rng.start_str.len .. rng.end_str.len + 1 {
		ids = ids.union(get_invalids(rng, id_len, 2))
	}
	mut res := i64(0)
	for id in ids.array() {
		res += id
	}
	return res
}

const primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

fn sum_invalids_part2(rng IdRange) i64 {
	mut ids := IdSet{}
	for id_len in rng.start_str.len .. rng.end_str.len + 1 {
		for repeats in primes {
			if repeats > id_len {
				break
			}
			ids = ids.union(get_invalids(rng, id_len, repeats))
		}
	}
	mut res := i64(0)
	for id in ids.array() {
		res += id
	}
	return res
}

fn main() {
	input := read_input('input.txt') or { panic('Failed to read input: ${err}') }

	mut p1sum := i64(0)
	mut p2sum := i64(0)
	for rng in input {
		p1sum += sum_invalids_part1(rng)
		p2sum += sum_invalids_part2(rng)
	}

	println('Part 1: ${p1sum}')
	println('Part 2: ${p2sum}')
}
