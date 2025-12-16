module main

import os

struct Device {
	ident   string
	outputs []string
mut:
	visited bool
	// total links to 'out' from this device
	links_to_out u64
	// links to 'out' via 'dac' but not 'fft'
	links_to_out_via_dac u64
	// links to 'out' via 'fft' but not 'dac'
	links_to_out_via_fft u64
	// links to 'out' via both 'dac' and 'fft'
	links_to_out_via_dac_and_fft u64
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

fn visit(device_map DeviceMap, ident string) {
	mut device := &device_map[ident]
	if device.visited {
		return
	}

	device.visited = true

	mut new_links := u64(0)
	mut new_links_via_dac := u64(0)
	mut new_links_via_fft := u64(0)
	mut new_links_via_dac_and_fft := u64(0)

	for output in device.outputs {
		if output == 'out' {
			new_links += 1
		} else {
			visit(device_map, output)
			odev := &device_map[output]
			new_links += odev.links_to_out
			new_links_via_dac += odev.links_to_out_via_dac
			new_links_via_fft += odev.links_to_out_via_fft
			new_links_via_dac_and_fft += odev.links_to_out_via_dac_and_fft
		}
	}
	device.links_to_out = new_links
	match ident {
		'dac' {
			device.links_to_out_via_dac_and_fft = new_links_via_dac_and_fft + new_links_via_fft
			assert device.links_to_out_via_dac_and_fft <= new_links
			device.links_to_out_via_dac = new_links - device.links_to_out_via_dac_and_fft
		}
		'fft' {
			device.links_to_out_via_dac_and_fft = new_links_via_dac_and_fft + new_links_via_dac
			assert device.links_to_out_via_dac_and_fft <= new_links
			device.links_to_out_via_fft = new_links - device.links_to_out_via_dac_and_fft
		}
		else {
			device.links_to_out_via_dac = new_links_via_dac
			device.links_to_out_via_fft = new_links_via_fft
			device.links_to_out_via_dac_and_fft = new_links_via_dac_and_fft
		}
	}
}

fn main() {
	input_file := os.args[1] or { 'example_input.txt' }
	links := read_input(input_file) or { panic('Failed to read input: ${err}') }

	device_map_p1 := init_device_map(links)

	visit(device_map_p1, 'you')

	n_links := device_map_p1['you'].links_to_out

	println('Part 1: ${n_links}')

	device_map_p2 := init_device_map(links)
	visit(device_map_p2, 'svr')
	println('${device_map_p2}')
	n_links_via_dac_and_fft := device_map_p2['svr'].links_to_out_via_dac_and_fft

	println('Part 2: ${n_links_via_dac_and_fft}')
}
