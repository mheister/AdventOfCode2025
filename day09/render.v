import arrays
import gg
import math

pub fn render(tiles []Tile, rects [][2]Tile) {
	max_x := arrays.max(tiles.map(it.x)) or { 0 }
	max_y := arrays.max(tiles.map(it.y)) or { 0 }
	tilemax := math.max(f32(max_x), f32(max_y))
	window_size := 800
	scale := f32(window_size - 10) / tilemax
	gg.start(
		width:    window_size
		height:   window_size
		frame_fn: fn [tiles, rects, scale] (c &gg.Context) {
			c.begin()
			for ts in arrays.window(tiles, size: 2) {
				x1 := f32(ts[0].x) * scale
				y1 := f32(ts[0].y) * scale
				x2 := f32(ts[1].x) * scale
				y2 := f32(ts[1].y) * scale
				c.draw_line(x1, y1, x2, y2, gg.Color{
					r: 255
					g: 255
					b: 255
					a: 255
				})
			}
			mut green := u8(0)
			for rect in rects {
				x1 := f32(rect[0].x) * scale
				y1 := f32(rect[0].y) * scale
				x2 := f32(rect[1].x) * scale
				y2 := f32(rect[1].y) * scale
				c.draw_rect_filled(x1, y1, x2 - x1, y2 - y1, gg.Color{
					r: 255
					g: green
					b: 0
					a: 100
				})
				green += 128
			}
			c.end()
		}
	)
}
