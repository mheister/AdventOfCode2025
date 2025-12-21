import arrays

#flag -llpsolve55
#flag -lm
#flag -lcolamd
#include "lpsolve/lp_lib.h"

struct C._lprec {}

@[c: 'make_lp']
fn C.make_lp(rows int, cols int) &C._lprec

@[c: 'set_obj_fn']
fn C.set_obj_fn(lp &C._lprec, row &f64) u8

@[c: 'add_constraint']
fn C.add_constraint(lp &C._lprec, row &u8, constr_type int, rh f64) u8

@[c: 'set_int']
fn C.set_int(lp &C._lprec, colnr int, must_be_int u8) u8

fn C.solve(lp &C._lprec) int

@[c: 'get_variables']
fn C.get_variables(lp &C._lprec, var &f64) u8

@[c: 'delete_lp']
fn C.delete_lp(lp &C._lprec)

fn ilp_solve(a [][]int, b []int) []int {
	assert a.len == b.len
	num_vars := a[0].len
	lp := C.make_lp(0, num_vars)

	// Objective: x1 + x2 + x3 + ...; 0 for idx 0
	obj := arrays.append([0.0], [1.0].repeat(num_vars))
	C.set_obj_fn(lp, &obj[0])

	for i in 0 .. a.len {
		mut row := []f64{len: num_vars + 1}
		row[0] = 0.0
		for j in 0 .. num_vars {
			row[j + 1] = f64(a[i][j])
		}
		unsafe {
			C.add_constraint(lp, &row[0], C.EQ, f64(b[i]))
		}
	}

	// Integer variables
	for i in 1 .. num_vars + 1 {
		C.set_int(lp, i, 1)
	}

	C.solve(lp)

	mut vars := []f64{len: num_vars}
	unsafe {
		C.get_variables(lp, &vars[0])
	}

	assert vars.all(it >= 0)

	C.delete_lp(lp)

	return vars.map(int(it))
}
