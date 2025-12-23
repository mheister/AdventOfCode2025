import arrays
import hash.fnv1a
import math

struct Shape {
	id    int
	data  []bool
	width int
	area  u32
}

struct CombinedShape {
	Shape
	counts []u8
}

fn (s Shape) height() int {
	return s.data.len / s.width
}

fn (s Shape) density() f32 {
	return f32(s.data.count(it)) / s.data.len
}

fn (s Shape) row(idx int) []bool {
	assert idx >= 0
	assert idx < s.height()
	off := idx * s.width
	return s.data[off..off + s.width]
}

fn (inp InputShape) shape(id int) Shape {
	data := arrays.flatten(inp)
	return Shape{
		id:    id
		data:  data
		width: inp.len
		area:  u32(data.count(it))
	}
}

fn (s Shape) str() string {
	mut res := ''
	for i in 0 .. s.height() {
		row := s.row(i)
		for val in row {
			if val {
				res += '#'
			} else {
				res += '.'
			}
		}
		res += '\n'
	}
	return res
}

fn (s CombinedShape) str() string {
	return '${s.Shape}${s.counts}\ndensity: ${s.density()}'
}

fn (s Shape) equals(other Shape) bool {
	if s.width != other.width || s.data.len != other.data.len {
		return false
	}
	for i in 0 .. s.data.len {
		if s.data[i] != other.data[i] {
			return false
		}
	}
	return true
}

fn (s Shape) rot90() Shape {
	h := s.height()
	w := s.width
	mut new_data := []bool{len: s.data.len}
	for i in 0 .. h {
		for j in 0 .. w {
			new_i := j
			new_j := h - 1 - i
			new_data[new_i * h + new_j] = s.data[i * w + j]
		}
	}
	return Shape{
		data:  new_data
		width: h
		area:  s.area
	}
}

fn (s Shape) flip_horiz() Shape {
	h := s.height()
	w := s.width
	mut new_data := []bool{len: s.data.len}
	for i in 0 .. h {
		for j in 0 .. w {
			new_i := i
			new_j := w - 1 - j
			new_data[new_i * w + new_j] = s.data[i * w + j]
		}
	}
	return Shape{
		data:  new_data
		width: w
		area:  s.area
	}
}

fn (s Shape) all_orientations() []Shape {
	mut orientations := []Shape{}
	mut current := s
	for _ in 0 .. 4 {
		orientations << current
		current = current.rot90()
	}
	current = s.flip_horiz()
	for _ in 0 .. 4 {
		orientations << current
		current = current.rot90()
	}
	// Remove duplicates
	mut unique_orientations := []Shape{}
	for o in orientations {
		if !unique_orientations.any(it.equals(o)) {
			unique_orientations << o
		}
	}
	return unique_orientations
}

fn overlaps(s1 Shape, s2 Shape, x_off int, y_off int) bool {
	for y in 0 .. s1.height() {
		for x in 0 .. s1.width {
			s2_x := x - x_off
			s2_y := y - y_off
			if s2_x < 0 || s2_x >= s2.width || s2_y < 0 || s2_y >= s2.height() {
				continue
			}
			s2_idx := s2_y * s2.width + s2_x
			s1_idx := y * s1.width + x
			if s1.data[s1_idx] && s2.data[s2_idx] {
				return true
			}
		}
	}
	return false
}

fn (s Shape) combine(other Shape) []Shape {
	mut combined := []Shape{}
	for x_off in -other.width + 1 .. other.width {
		for y_off in -other.height() + 1 .. other.height() {
			if !overlaps(s, other, x_off, y_off) {
				s_disp_x := if x_off < 0 { -x_off } else { 0 }
				s_disp_y := if y_off < 0 { -y_off } else { 0 }
				other_disp_x := if x_off > 0 { x_off } else { 0 }
				other_disp_y := if y_off > 0 { y_off } else { 0 }
				// Determine new shape dimensions
				new_width := math.max(other.width + other_disp_x, s.width + s_disp_x)
				new_height := math.max(other.height() + other_disp_y, s.height() + s_disp_y)
				new_data_len := new_width * new_height
				mut new_data := []bool{len: new_data_len, cap: new_data_len, init: false}
				// Copy data from s
				for y in 0 .. s.height() {
					for x in 0 .. s.width {
						new_x := x + s_disp_x
						new_y := y + s_disp_y
						new_data[new_x + new_y * new_width] = s.data[x + y * s.width]
					}
				}
				// Copy data from other
				for y in 0 .. other.height() {
					for x in 0 .. other.width {
						new_x := x + other_disp_x
						new_y := y + other_disp_y
						if other.data[x + y * other.width] {
							new_data[new_x + new_y * new_width] = true
						}
					}
				}
				// assert s.area + other.area == u32(new_data.count(it))
				combined << Shape{
					data:  new_data
					width: new_width
					area:  s.area + other.area
				}
			}
		}
	}
	return combined
}

fn (mut s CombinedShape) normalize() {
	mut minhash := max_u32
	all_orients := s.all_orientations()
	for o in all_orients {
		hash := fnv1a.sum32(o.data.map(if it { u8(1) } else { 0 }))
		if hash < minhash {
			minhash = hash
			s.Shape = o
		}
	}
}

fn insert_if_new(mut shapes []CombinedShape, mut shape CombinedShape) {
	shape.normalize()
	for existing in shapes {
		if existing.equals(shape.Shape) && existing.counts == shape.counts {
			return
		}
	}
	shapes << shape
}

fn combine_shapes(shapes []Shape, max_elems int) []CombinedShape {
	mut combined_shapes := []CombinedShape{}
	for shape in shapes {
		mut counts := []u8{len: 6, cap: 6, init: 0}
		counts[shape.id] = 1
		combined_shapes << CombinedShape{
			Shape:  shape
			counts: counts
		}
	}
	mut orig_shape_count := combined_shapes.len
	mut last_depth_start := 0
	mut last_depth_end := combined_shapes.len
	for depth in 0 .. max_elems - 1 {
		for i in 0 .. orig_shape_count {
			shape_a := combined_shapes[i]
			if depth == 0 {
				last_depth_start = i
			}
			for j in last_depth_start .. last_depth_end {
				shape_b := combined_shapes[j]
				counts := arrays.group[u8](shape_a.counts, shape_b.counts)
					.map(arrays.sum(it) or { 0 })
				for shape_a_or in shape_a.all_orientations() {
					combinations := shape_b.combine(shape_a_or)
					for combined in combinations {
						if combined.density() < 0.6 {
							continue
						}
						mut new_shape := CombinedShape{
							Shape:  combined
							counts: counts
						}
						insert_if_new(mut &combined_shapes, mut new_shape)
					}
				}
			}
		}
		last_depth_start = last_depth_end
		last_depth_end = combined_shapes.len
	}
	return combined_shapes
}

fn calculate_tilability_score(shape Shape) f32 {
	mut doubled := combine_shapes([shape], 2)
	mut densest := ?CombinedShape(none)
	for sh in doubled {
		if d := densest {
			if sh.density() > d.density() {
				densest = sh
			}
		} else {
			densest = sh
		}
	}
	mut quadrupled := combine_shapes([densest or { panic('') }.Shape], 2)
	mut quad_density := f32(0.0)
	for sh in quadrupled {
		if sh.density() > quad_density {
			quad_density = sh.density()
		}
	}
	return quad_density
}
