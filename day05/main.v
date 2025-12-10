module main

import os
import math

struct IdRange {
	start i64
	end   i64
}

struct Input {
	fresh_ranges []IdRange
	ids          []i64
}

fn (rng IdRange) contains(id i64) bool {
	return id >= rng.start && id <= rng.end
}

fn binary_search_ranges(ranges []IdRange, id i64) ?IdRange {
	mut low := 0
	mut high := ranges.len - 1

	for low <= high {
		mid := (low + high) / 2
		mid_range := ranges[mid]

		if mid_range.contains(id) {
			return mid_range
		} else if id < mid_range.start {
			high = mid - 1
		} else {
			low = mid + 1
		}
	}
	return none
}

fn fallible_map[T, U](arr []T, f fn (T) !U) ![]U {
	mut result := []U{cap: arr.len}
	for item in arr {
		result << f(item) or { return err }
	}
	return result
}

fn parse_range(range_str string) !IdRange {
	parts := range_str.split('-')
	if parts.len != 2 {
		return error('Invalid range format: ${range_str}')
	}
	start := parts[0].trim_space().parse_int(10, 64) or {
		return error('Failed to parse start of range: ${err}')
	}
	end := parts[1].trim_space().parse_int(10, 64) or {
		return error('Failed to parse end of range: ${err}')
	}
	return IdRange{start, end}
}

fn read_input(filename string) !Input {
	data := os.read_file(filename) or { return error('Failed to read file: ${err}') }

	ranges_str, ids_str := data.split_once('\n\n') or {
		return error('Failed to split ranges and ids')
	}

	ranges := fallible_map[string, IdRange](ranges_str.split_into_lines(), |l| parse_range(l))!
	ids := fallible_map[string, i64](ids_str.split_into_lines(), |l| l.parse_int(10, 64))!

	return Input{
		fresh_ranges: ranges
		ids:          ids
	}
}

fn main() {
	// input := read_input('example_input.txt') or { panic('Failed to read input: ${err}') }
	input := read_input('input.txt') or { panic('Failed to read input: ${err}') }

	mut ranges_sorted := input.fresh_ranges.clone()
	ranges_sorted.sort_with_compare(fn (a &IdRange, b &IdRange) int {
		if a.start == b.start {
			if a.end == b.end {
				return 0
			}
			if a.end < b.end { return -1 } else { return 1 }
		}
		if a.start < b.start { return -1 } else { return 1 }
	})
	mut ranges_merged := []IdRange{}
	for r in ranges_sorted {
		if ranges_merged.len == 0 || r.start > ranges_merged.last().end + 1 {
			ranges_merged << r
		} else {
			ranges_merged[ranges_merged.len - 1] = IdRange{
				start: ranges_merged.last().start
				end:   math.max(ranges_merged.last().end, r.end)
			}
		}
	}

	mut good_id_count := 0
	for id in input.ids {
		found_range := binary_search_ranges(ranges_merged, id)
		if found_range != none {
			good_id_count += 1
		}
	}

	mut good_ids_in_ranges := i64(0)
	for r in ranges_merged {
		good_ids_in_ranges += r.end - r.start + 1
	}

	println('Part 1: ${good_id_count}')
	println('Part 2: ${good_ids_in_ranges}')
}
