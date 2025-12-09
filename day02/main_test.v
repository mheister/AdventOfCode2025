module main

fn test_sum_invalids() {
	assert sum_invalids(IdRange{ start: 11, end: 22, start_str: '11', end_str: '22' },
		2, 1) == 33
	assert sum_invalids(IdRange{ start: 11, end: 21, start_str: '11', end_str: '21' },
		2, 1) == 11
	assert sum_invalids(IdRange{ start: 111, end: 222, start_str: '111', end_str: '222' },
		3, 1) == 333
	assert sum_invalids(IdRange{ start: 1212, end: 1221, start_str: '1212', end_str: '1221' },
		4, 2) == 1212
}
