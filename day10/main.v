module main

import os

struct Device {
	ident   string
	outputs []string
mut:
	visited      bool
	links_to_out int
}

type DeviceMap = map[string]Device

fn read_input(filename string) !map[string][]string {
	data := os.read_file(filename) or { return error('Failed to read file: ${err}') }

	mut result := map[string][]string{}

	for l in data.split_into_lines() {
		ident, outputs := l.split_once(': ') or { return error('Invalid line format: ${l}') }
		result[ident] = outputs.split(' ')
	}

	return result
}

fn init_device_map(links map[string][]string) DeviceMap {
	mut device_map := DeviceMap{}

	for ident, outputs in links {
		device_map[ident] = Device{
			ident:        ident
			outputs:      outputs
			visited:      false
			links_to_out: 0
		}
	}

	return device_map
}

fn part1_visit(device_map DeviceMap, ident string) {
	mut device := &device_map[ident]
	if device.visited {
		return
	}

	device.visited = true

	mut new_links := 0
	for output in device.outputs {
		if output == 'out' {
			new_links += 1
		} else {
			part1_visit(device_map, output)
			new_links += device_map[output].links_to_out
		}
	}
	device.links_to_out = new_links
}

fn main() {
	input_file := os.args[1] or { 'example_input.txt' }
	links := read_input(input_file) or { panic('Failed to read input: ${err}') }

	device_map := init_device_map(links)

	part1_visit(device_map, 'you')

	n_links := device_map['you'].links_to_out

	println('${device_map}')

	println('Part 1: ${n_links}')
	println('Part 2: ')
}
