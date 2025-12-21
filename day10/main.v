module main

import arrays
import os

struct Machine {
	indicators u16
	buttons    []u16
}

pub fn (m Machine) str() string {
	indicators := '[${m.indicators:05b}]'
		.replace_char(`0`, `.`, 1)
		.replace_char(`1`, `#`, 1)
	mut button_strs := []string{cap: m.buttons.len}
	for btn in m.buttons {
		mut btn_str := '('
		mut first := true
		for i := 0; i < 16; i++ {
			if (btn & (1 << u16(i))) != 0 {
				if !first {
					btn_str += ','
				}
				btn_str += i.str()
				first = false
			}
		}
		btn_str += ')'
		button_strs << btn_str
	}
	return '${indicators} ${button_strs.join(' ')}'
}

fn parse_indicators(ind_str string) u16 {
	// [.##..] -> 0b1100
	mut indicators := u16(0)
	for i, ch in ind_str[1..ind_str.len - 1] {
		if ch == `#` {
			indicators |= 1 << u16(i)
		}
	}
	return indicators
}

fn parse_button(button_str string) u16 {
	// (2,3,5) -> 0b10110
	mut buttons := u16(0)
	nums := button_str[1..button_str.len - 1].split(',')
	for num_str in nums {
		num := num_str.int()
		buttons |= 1 << u16(num)
	}
	return buttons
}

fn read_input(filename string) ![]Machine {
	data := os.read_file(filename) or { return error('Failed to read file: ${err}') }

	lines[string] := data.split_into_lines()
	mut result := []Machine{cap: data.len}

	for l in lines {
		ind_str, rest := l.split_once(' ') or { return error('Invalid line format') }
		button_strs := rest.split(' ')#[..-1] // ignore joltage for now
		result << Machine{
			indicators: parse_indicators(ind_str)
			buttons:    button_strs.map(parse_button(it))
		}
	}

	return result
}

fn initialize_machine(m Machine) int {
	// indicator states -> #presses to get there
	mut states := map[u16]int{}
	mut current_min := int(1e9)
	states[0] = 0
	mut going := true
	for going {
		going = false
		for state, presses in states {
			for btn in m.buttons {
				new_state := state ^ btn
				new_presses := presses + 1
				if new_presses >= current_min {
					// we have a route to goal with fewer presses, prune here
					continue
				}
				if new_state == m.indicators {
					current_min = new_presses
				}
				existing := states[new_state] or { int(1e9) }
				if new_presses < existing {
					states[new_state] = new_presses
					going = true
				}
			}
		}
	}
	return states[m.indicators] or { int(1e9) }
}

fn main() {
	input_file := os.args[1] or { 'example_input.txt' }
	input := read_input(input_file) or { panic('Failed to read input: ${err}') }

	println('Read ${input.len} machines from ${input_file}')

	// Part 1
	num_presses_part1 := arrays.sum(input.map(initialize_machine(it))) or { panic('${err}') }

	println('Part 1: ${num_presses_part1}')
	println('Part 2: ')
}
