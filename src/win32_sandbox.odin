package main

import "core:log"
import "core:math"
import "core:unicode/utf8"
import "core:slice"
import "core:strings"
import "core:strconv"

day1_input := string(#load("../aoc/day1.txt"))
day2_input := string(#load("../aoc/day2.txt"))
day3_input := string(#load("../aoc/day3.txt"))
day4_input := string(#load("../aoc/day4.txt"))
day5_input := string(#load("../aoc/day5.txt"))
day6_input := string(#load("../aoc/day6.txt"))
day7_input := string(#load("../aoc/day7.txt"))
day8_input := string(#load("../aoc/day8.txt"))
day9_input := string(#load("../aoc/day9.txt"))
day10_input := string(#load("../aoc/day10.txt"))


open_chars : []rune = {'(', '[', '{', '<'}
close_chars : []rune = {')', ']', '}', '>'}
corrupted_vals : []int = {3, 57, 1197, 25137}

day10 :: proc() {
	input := day10_input
	line, ok := strings.split_iterator(&input, "\n")

	corrupt_score := 0
	missing_scores := make([dynamic]int)
	defer delete(missing_scores)
	for ok {
		line = strings.trim_space(line)
		open_chars_stack := make([dynamic]rune)
		defer delete(open_chars_stack)
		corrupt := false
		runes_loop : for r in line {
			if slice.contains(open_chars[:], r) {
				append(&open_chars_stack, r)
			} else {
				for c, idx in close_chars {
					if r == c {
						if open_chars[idx] != open_chars_stack[len(open_chars_stack)-1] {
							corrupt_score += corrupted_vals[idx]
							corrupt = true
							break runes_loop
						} else {
							pop(&open_chars_stack)
						}
					}
				}
			}
		}

		if !corrupt {
			line_missing_score := 0
			num_missing := len(open_chars_stack)
			for _ in 0..<num_missing {
				c := pop(&open_chars_stack)
				for r, idx in open_chars {
					if c == r {
						line_missing_score *= 5
						line_missing_score += idx + 1
					}
				}
			}
			append(&missing_scores, line_missing_score)
		}
		line, ok = strings.split_iterator(&input, "\n")
	}

	slice.sort(missing_scores[:])
	log.info(missing_scores)
	middle_idx := len(missing_scores) / 2

	log.info("Part 1 total corruption score:", corrupt_score)
	log.info("Part 2 middle idx missing score:", missing_scores[middle_idx])
}

Cell :: struct {
	val : int,
	in_basin : bool,
}

expand_basin :: proc(grid : ^[][]Cell, row : int, col : int) -> int {
	val := grid[row][col]
	res := 0
	if val.val < 9 && !val.in_basin {
		grid[row][col].in_basin = true
		res += 1
		if !grid[row][col-1].in_basin do res += expand_basin(grid, row, col-1)
		if !grid[row][col+1].in_basin do res += expand_basin(grid, row, col+1)
		if !grid[row-1][col].in_basin do res += expand_basin(grid, row-1, col)
		if !grid[row+1][col].in_basin do res += expand_basin(grid, row+1, col)
	}
	return res
}

day9 :: proc() {
	input := day9_input
	lines := strings.split(input, "\n")
	num_rows := len(lines) - 1 + 2
	num_cols := len(lines[0]) - 1 + 2
	/*log.info(num_lines)*/
	/*make_grid := make([]int, num_rows*num_cols)*/
	/*make_grid := make([][]Cell, num_rows)*/
	/*grid := make_grid[:num_rows][:num_cols]*/
	/*grid := cast([][]int)make_grid[:num_rows][:num_cols]*/
	grid := make([][]Cell, num_rows)
	defer delete(grid)
    for row in &grid {
        row = make([]Cell, num_cols)
    }
	defer { for row in &grid { delete(row) } }

	for row in &grid {
		for v in &row {
			v.val = max(int)
		}
	}

	str, ok := strings.split_iterator(&input, "\n")
	idx := 0
	for ok {
		str = strings.trim_space(str)
		for r, idx2 in str {
			grid[idx + 1][idx2 + 1] = Cell{val=strconv.atoi(utf8.runes_to_string({r}))}
		}
		str, ok = strings.split_iterator(&input, "\n")
		idx += 1
	}

	risk_level := 0
	rows := len(grid)
	cols := len(grid[0])
	basin_sizes := make([dynamic]int)
	defer delete(basin_sizes)
	for i := 1; i < rows - 1; i += 1 {
		for j := 1; j < cols -1; j += 1 {
			val := grid[i][j].val
			left := grid[i][j-1].val
			right := grid[i][j+1].val
			up := grid[i-1][j].val
			down := grid[i+1][j].val
			if val < left && val < right && val < up && val < down {
				risk_level += val+1
				basin_size := expand_basin(&grid, i, j)
				append(&basin_sizes, basin_size)
			}
		}
	}

	log.info("Part 1 Risk Level:", risk_level)
	
	slice.sort(basin_sizes[:])
	mul_3_large_basins := 1
	for i in 0..<3 {
		mul_3_large_basins *= basin_sizes[len(basin_sizes)-1-i]
	}
	log.info("Part 2- 3 largest baisns mul:", mul_3_large_basins)
}

Signal :: distinct []string
Digits :: distinct []string

day8 :: proc() {
	input := day8_input
	str, ok := strings.split_iterator(&input, "\n")
	signals := make([dynamic]Signal)
	defer delete(signals)
	digits := make([dynamic]Digits)
	defer delete(digits)
	for ok {
		signals_str, signals_ok := strings.split_iterator(&str, "|")
		_ = signals_ok
		signal := strings.split(signals_str, " ")
		display := strings.split(str, " ")
		append(&signals, cast(Signal)signal[:len(signal)-1])
		append(&digits, cast(Digits)display[1:])
		str, ok = strings.split_iterator(&input, "\n")
	}

	count_1478 := 0
	for d in &digits {
		for e in &d {
			e = strings.trim_space(e)
			if len(e) == 2 || len(e) == 3 || len(e) == 4 || len(e) == 7 {
				count_1478 += 1
			}
		}
	}
	log.info("Count of 1,4,7,8:", count_1478)

	a_rune : rune
	len5_sigs : [3]string
	len6_sigs : [3]string
	g_rune : rune
	d_rune : rune
	b_rune : rune
	sigs : [10]string

	total_val : f32 = 0

	for s, line_idx in &signals {
		len5_idx := 0
		len6_idx := 0
		for e in &s {
			e = strings.trim_space(e)
			if len(e) == 2 {
				sigs[1] = e
			} else if len(e) == 3 {
				sigs[7] = e
			} else if len(e) == 4 {
				sigs[4] = e
			} else if len(e) == 7 {
				sigs[8] = e
			} else if len(e) == 6 {
				len6_sigs[len6_idx] = e
				len6_idx += 1
			} else if len(e) == 5 {
				len5_sigs[len5_idx] = e
				len5_idx += 1
			}
		}

		// The rune in sig7 that is not in sig1 is the a_rune
		for r in sigs[7] {
			if strings.contains_rune(sigs[1], r) >= 0 {
				continue
			} else {
				a_rune = r
				break
			}
		}
		/*log.info(a_rune)*/

		// The signal of length 6 for sig9 containing the runes of sig4 and the a_rune has the g_rune as the final element
		sig9_idx := 0
		for s, idx in len6_sigs {
			mismatches := 0
			mismatch : rune
			for r in s {
				if !((strings.contains_rune(sigs[4], r) >= 0) || r == a_rune) {
					mismatches += 1
					mismatch = r
				}
			}

			if mismatches == 1 {
				g_rune = mismatch
				sigs[9] = s
				sig9_idx = idx
			}
		}

		// The signal of length 5 for sig3 containing the runes of sig7 and the g_rune has the d_rune as the final element
		sig3_idx := 0
		for s, idx in len5_sigs {
			mismatches := 0
			mismatch : rune
			for r in s {
				if !((strings.contains_rune(sigs[7], r) >= 0) || r == g_rune) {
					mismatches += 1
					mismatch = r
				}
			}

			if mismatches == 1 {
				d_rune = mismatch
				sigs[3] = s
				sig3_idx = idx
			}
		}

		// The rune in sig9 not in sig3 is the b_rune
		for r in sigs[9] {
			if !(strings.contains_rune(sigs[3], r) >= 0) {
				b_rune = r
			}
		}

		// The len5 string containing a, b, and g runes is sig5
		sig5_idx := 0
		for s, idx in len5_sigs {
			contains_a := strings.contains_rune(s, a_rune) >= 0
			contains_b := strings.contains_rune(s, b_rune) >= 0
			contains_g := strings.contains_rune(s, g_rune) >= 0
			if contains_a && contains_b && contains_g {
				sigs[5] = s
				sig5_idx = idx
				break
			}
		}

		// The len5 string that is not the idx of sig3 and sig5 is sig2
		for s, idx in len5_sigs {
			if (idx != sig3_idx && idx != sig5_idx) {
				sigs[2] = s
				break
			}
		}

		// The len6 string that is not the idx of sig9 and does not have d_rune is sig0
		// The other one is sig6
		for s, idx in len6_sigs {
			if idx == sig9_idx {
				continue
			} else if strings.contains_rune(s, d_rune) >= 0 {
				sigs[6] = s
			} else {
				sigs[0] = s
			}
		}

		// Now decode the digits
		val : f32 = 0
		for d, d_idx in digits[line_idx] {
			for s, s_idx in sigs {
				if len(d) == len(s) {
					match := true
					for r in d {
						if !(strings.contains_rune(s, r) >= 0) {
							match = false
							break
						}
					}
					if match {
						val += math.pow(10, f32(len(digits[line_idx]) - d_idx - 1))*f32(s_idx)
						break
					}
				}
			}
		}
		total_val += val
	}
	log.info("Summed display values:", total_val)
}


sum_range :: proc(x: int) -> int {
	return int(f32(x+1)*f32(x)/2.0)
}

day7_part2 :: proc() {
	input := day7_input

	str, ok := strings.split_iterator(&input, ",")
	locs := make([dynamic]int)
	defer delete(locs)
	for ok {
		str = strings.trim_space(str)
		val := strconv.atoi(str)
		append(&locs, val)
		str, ok = strings.split_iterator(&input, ",")
	}

	max_val := 0
	sum := 0
	for v in locs {
		sum += v
		max_val = max(max_val,v)
	}

	align_costs := make([]int, max_val)
	defer delete(align_costs)

	for x,idx in align_costs {
		for v in locs {
			align_costs[idx] += sum_range(abs(v-idx))
		}
	}

	min_val : int = max(int)
	for x in align_costs {
		min_val = min(min_val, x)
	}
	log.info(min_val)
}

day7_part1 :: proc() {
	input := day7_input

	str, ok := strings.split_iterator(&input, ",")
	locs := make([dynamic]int)
	for ok {
		str = strings.trim_space(str)
		val := strconv.atoi(str)
		append(&locs, val)
		str, ok = strings.split_iterator(&input, ",")
	}

	max_val := 0
	sum := 0
	for v in locs {
		sum += v
		max_val = max(max_val,v)
	}

	align_costs := make([]int, max_val)

	for x,idx in align_costs {
		for v in locs {
			align_costs[idx] += abs(v-idx)
		}
	}

	min_val : int = max(int)
	for x in align_costs {
		min_val = min(min_val, x)
	}
	log.info(min_val)
}

day6 :: proc() {
	input := day6_input

	day_bins : [9]int
	str, ok := strings.split_iterator(&input, ",")
	for ok {
		str = strings.trim_space(str)
		val := strconv.atoi(str)
		day_bins[val] += 1
		str, ok = strings.split_iterator(&input, ",")
	}

	day_bins_swap := day_bins
	num_new_fish := 0
	for i in 1..256 {
		for count,day in day_bins_swap {
			if day == 0 {
				num_new_fish = count
				day_bins[8] = count
			} else {
				day_bins[day-1] = count
			}
		}
		day_bins[6] += num_new_fish
		num_new_fish = 0
		/*log.info(day_bins)*/
		day_bins, day_bins_swap = day_bins_swap, day_bins
	}

	sum := 0
	for count in day_bins_swap {
		sum += count
	}
	log.info(sum)
}

day5_part2 :: proc() {
	input := day5_input
	line, ok := strings.split_iterator(&input, "\n")

	grid := new([999][999]int)
	linear_grid := cast(^[999*999]int)grid
	for val in linear_grid {
		log.info(val)
	}
	defer free(grid)
	for ok {
		fproc := proc(r: rune) -> bool {
			return r == ' ' || r == ',' || r == '\n'
		}
		fields := strings.fields_proc(line, fproc)
		/*log.info(fields)*/
		line, ok = strings.split_iterator(&input, "\n")

		x1 := strconv.atoi(fields[0])
		y1 := strconv.atoi(fields[1])
	// "->" is at fields[2]
		x2 := strconv.atoi(fields[3])
		y2 := strconv.atoi(fields[4])

		if x1 == x2 {
			dist := abs(y2-y1)
			min := min(y1,y2)
			for i in 0..dist {
				/*grid[x1][min+i] += 1*/
				grid[x1][min+i] += 1
			}
		} else if y1 == y2 {
			dist := abs(x2-x1)
			min := min(x1,x2)
			for i in 0..dist {
				grid[min+i][y1] += 1
			}
		} else if abs(y2-y1) == abs(x2-x1) {
			dist := abs(y2-y1)
			x_sign := dist / (x2-x1)
			y_sign := dist / (y2-y1)
			for i in 0..dist {
				grid[x1+i*x_sign][y1+i*y_sign] += 1
			}
		}
	}

	num_overlaps := 0
	for row in grid {
		for val in row {
			if val >= 2 do num_overlaps += 1
		}
	}
	log.info("num overlaps:", num_overlaps)
}

day5_part1 :: proc() {
	input := day5_input
	line, ok := strings.split_iterator(&input, "\n")

	grid := new([999][999]int)
	defer free(grid)
	for ok {
		fproc := proc(r: rune) -> bool {
			return r == ' ' || r == ',' || r == '\n'
		}
		fields := strings.fields_proc(line, fproc)
		/*log.info(fields)*/
		line, ok = strings.split_iterator(&input, "\n")

		x1 := strconv.atoi(fields[0])
		y1 := strconv.atoi(fields[1])
	// "->" is at fields[2]
		x2 := strconv.atoi(fields[3])
		y2 := strconv.atoi(fields[4])

		if x1 == x2 {
			dist := abs(y2-y1)
			min := min(y1,y2)
			for i in 0..dist {
				grid[x1][min+i] += 1
			}
		} else if y1 == y2 {
			dist := abs(x2-x1)
			min := min(x1,x2)
			for i in 0..dist {
				grid[min+i][y1] += 1
			}
		}
	}

	max_val := 0
	num_overlaps := 0
	for column in grid {
		for val in column {
			max_val = max(max_val, val)
			if val >= 2 do num_overlaps += 1
		}
	}
	log.info("num overlaps:", num_overlaps)
}

Board_Space :: struct {
	val : int,
	marked : bool,
}

Board :: struct {
	won : bool,
	unmarked_score : int,
	spaces : [5][5]Board_Space,
}

board_score :: proc(board : Board) -> int {
	sum : int
	for row in board.spaces {
		for space in row {
			if !space.marked {
				sum += space.val
			}
		}
	}
	return sum
}

check_board_win :: proc(board : Board) -> bool {
	col_wins : [len(board.spaces[0])]bool
	for win in &col_wins {
		win = true
	}
	for row, idx in board.spaces {
		row_win := true
		for space, idx2 in row {
			row_win &= space.marked
			col_wins[idx2] &= space.marked
		}
		if row_win {
			return true
		}
	}

	col_won := false
	for win in col_wins {
		col_won |= win
	}
	return col_won
}

day4_part2 :: proc() {
	input := day4_input
	line, ok := strings.split_iterator(&input, "\n")
	val_strs := strings.split(line, ",")
	called_nums := make([]int, len(val_strs))
	defer delete(called_nums)
	for str, idx in val_strs {
		called_nums[idx] = strconv.atoi(str)
	}

	// Consume empty line
	line, ok = strings.split_iterator(&input, "\n")
	boards := make([dynamic]Board)
	defer delete(boards)
	for ok {
		board : Board
		for i := 0; i < 5; i += 1 {
			line, ok = strings.split_iterator(&input, "\n")
			val_strs := strings.fields(line)
			for str, idx in val_strs {
				board.spaces[i][idx].val = strconv.atoi(str)
			}
		}
		append(&boards, board)
		// Consume empty line
		line, ok = strings.split_iterator(&input, "\n")
	}

	latest_call : int
	final_board : Board
	final_board_last_call : int
	call_num : for called in called_nums {
		latest_call = called
		for board in &boards {
			if board.won {
				continue
			}
			for row in &board.spaces {
				for space in &row {
					if space.val == called {
						space.marked = true
						if check_board_win(board) {
							board.won = true
							board.unmarked_score = board_score(board)
							final_board = board
							final_board_last_call = called
						}
					}
				}
			}
		}
	}

	log.info("Day 4 Part 2 (sum of unmarked spaces on final winning board)*(latest_call):", final_board.unmarked_score*final_board_last_call)
}

day4_part1 :: proc() {
	input := day4_input
	line, ok := strings.split_iterator(&input, "\n")
	val_strs := strings.split(line, ",")
	called_nums := make([]int, len(val_strs))
	defer delete(called_nums)
	for str, idx in val_strs {
		called_nums[idx] = strconv.atoi(str)
	}

	// Consume empty line
	line, ok = strings.split_iterator(&input, "\n")
	boards := make([dynamic]Board)
	defer delete(boards)
	for ok {
		board : Board
		for i := 0; i < 5; i += 1 {
			line, ok = strings.split_iterator(&input, "\n")
			val_strs := strings.fields(line)
			for str, idx in val_strs {
				board.spaces[i][idx].val = strconv.atoi(str)
			}
		}
		append(&boards, board)
		// Consume empty line
		line, ok = strings.split_iterator(&input, "\n")
	}

	winning_board : Board
	latest_call : int
	call_num : for called in called_nums {
		latest_call = called
		for board in &boards {
			for row in &board.spaces {
				for space in &row {
					if space.val == called {
						space.marked = true
						if check_board_win(board) {
							log.info("Found winner")
							winning_board = board
							break call_num
						}
					}
				}
			}
		}
	}

	// Sum unmarked spaces of winning board
	sum : int
	for row in winning_board.spaces {
		for space in row {
			if !space.marked {
				sum += space.val
			}
		}
	}
	log.info("Day 4 Part 1 (sum of unmarked spaces on winning board)*(latest_call):", sum*latest_call)
}

select :: proc(input : ^string, place : int, oxygen : bool) -> (string, int) {
	line, ok := strings.split_iterator(input, "\n")
	line = strings.trim_space(line)

	str_builder_0 := strings.make_builder()
	str_builder_1 := strings.make_builder()
	str_builders : []^strings.Builder = {&str_builder_0, &str_builder_1}

	counts : [2]int
	for ok {
		place_bit := line[place:place+1]
		val := strconv.atoi(place_bit)
		counts[val] += 1
		strings.write_string(str_builders[val], line)
		strings.write_string(str_builders[val], "\n")

		line, ok = strings.split_iterator(input, "\n")
		line = strings.trim_space(line)
	}

	idx : int
	if oxygen {
		idx = 0 if counts[0] > counts[1] else 1
	} else {
		idx = 0 if counts[0] <= counts[1] else 1
	}
	return strings.to_string(str_builders[idx]^), counts[idx]
}

get_rating :: proc(oxygen: bool) -> int {
	place := 0
	start := day3_input
	selected, count := select(&start, place, oxygen)
	for count > 1 {
		place += 1
		selected, count = select(&selected, place, oxygen)
	}

	rating_str := strings.trim_space(selected)
	rating := 0
	for r, idx in rating_str {
		str := utf8.runes_to_string({r})
		val := strconv.atoi(str)
		rating += val << (uint(len(rating_str)) - uint(idx) - 1)
	}
	return rating
}

day3_part2 :: proc() {
	input := day3_input

	line, ok := strings.split_iterator(&input, "\n")
	_ = ok
	line = strings.trim_space(line)

	oxygen_generator_rating := get_rating(true)
	co2_scrubber_rating := get_rating(false)
	log.info("Life support rating:", oxygen_generator_rating*co2_scrubber_rating)
}

day3_part1 :: proc() {
	input := day3_input

	line, ok := strings.split_iterator(&input, "\n")
	line = strings.trim_space(line)
	num_bins := len(line)
	bins := make([]int, num_bins)
	defer delete(bins)

	n := 0
	for ok {
		n += 1
		for r, idx in line {
			str := utf8.runes_to_string({r})
			val := strconv.atoi(str)
			bins[idx] += val
		}
		line, ok = strings.split_iterator(&input, "\n")
		line = strings.trim_space(line)
	}

	gamma := 0
	epsilon := 0
	for bin, idx in &bins {
		bin = bin / (n / 2)
		gamma += bin << uint(num_bins - idx - 1)
		epsilon += (1 - bin) << uint(num_bins - idx - 1)
	}

	log.infof("Gamma: {}, %b", gamma, gamma)
	log.infof("Epsilon: {}, %b", epsilon, epsilon)
	log.info("Gamma*Epsilon = Total Power Consumption:", gamma*epsilon)
}

day2_part2 :: proc() {
	input := day2_input

	depth := 0
	horiz := 0
	aim := 0

	line, ok := strings.split_iterator(&input, "\n")
	for ok {
		fields := strings.fields(line)
		defer delete(fields)
		val, conv_ok := strconv.parse_int(strings.trim_space(fields[1]))
		if !conv_ok {
			log.fatal("Error parsing int")
			return
		}
		switch fields[0] {
			case "forward":
				horiz += val
				depth += aim*val
			case "up":
				aim -= val
			case "down":
				aim += val
		}
		line, ok = strings.split_iterator(&input, "\n")
	}
	log.infof("Day2 Part2 horiz {}, depth {}. Product {}", horiz, depth, horiz*depth)
}

day2_part1 :: proc() {
	input := day2_input

	depth := 0
	horiz := 0

	line, ok := strings.split_iterator(&input, "\n")
	for ok {
		fields := strings.fields(line)
		val, conv_ok := strconv.parse_int(strings.trim_space(fields[1]))
		if !conv_ok {
			log.fatal("Error parsing int")
			return
		}
		switch fields[0] {
			case "forward":
				horiz += val
			case "up":
				depth -= val
			case "down":
				depth += val
		}
		line, ok = strings.split_iterator(&input, "\n")
	}
	log.infof("Day2 Part1 horiz {}, depth {}. Product {}", horiz, depth, horiz*depth)
}

day1_part2 :: proc() {
	input := day1_input
	increased_count := 0

	line1, ok_1 := strings.split_iterator(&input, "\n")
	line2, ok_2 := strings.split_iterator(&input, "\n")
	line3, ok_3 := strings.split_iterator(&input, "\n")
	line1 = strings.trim_space(line1)
	line2 = strings.trim_space(line2)
	line3 = strings.trim_space(line3)

	int1, conv_ok_1 := strconv.parse_int(line1)
	int2, conv_ok_2 := strconv.parse_int(line2)
	int3, conv_ok_3 := strconv.parse_int(line3)

	if !(ok_1 && ok_2 && ok_3 && conv_ok_1 && conv_ok_2 && conv_ok_3) {
		log.fatal("Could not parse initial 3 ints for Day1 Part2")
		return
	}

	prev_sum := int1 + int2 + int3

	line : string
	ok := true
	for ok {
		line, ok = strings.split_iterator(&input, "\n")
		if ok {
			line = strings.trim_space(line)
			curr, conv_ok := strconv.parse_int(line)
			if conv_ok {
				new_sum := prev_sum - int1 + curr
				if new_sum > prev_sum {
					increased_count += 1
				}
				prev_sum = new_sum
				int1 = int2
				int2 = int3
				int3 = curr
			}
		}
	}
	log.info("Day1 Part2 Increased Count:", increased_count)
}

day1_part1 :: proc() {
	input := day1_input
	increased_count := 0
	line, ok := strings.split_iterator(&input, "\n")
	line = strings.trim_space(line)
	last, conv_ok := strconv.parse_int(line)
	for ok && conv_ok {
		line, ok = strings.split_iterator(&input, "\n")
		if ok {
			line = strings.trim_space(line)
			curr : int
			curr, conv_ok = strconv.parse_int(line)
			if conv_ok {
				if curr > last {
					increased_count += 1
				}
				last = curr
			}
		}
	}
	log.info("Day1 Part1 Increased Count:", increased_count)
}

main :: proc() {
	context.logger = log.create_console_logger()
	/*day1_part1()*/
	/*day1_part2()*/
	/*day2_part1()*/
	/*day2_part2()*/
	/*day3_part1()*/
	/*day3_part2()*/
	/*day4_part1()*/
	/*day4_part2()*/
	/*day5_part1()*/
	/*day5_part2()*/
	/*day6()*/
	/*day7_part1()*/
	/*day7_part2()*/
	/*day8()*/
	/*day9()*/
	day10()
}
