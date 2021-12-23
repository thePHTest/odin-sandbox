package main

import "core:fmt"
import "core:log"
import "core:math"
import "core:unicode"
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
day11_input := string(#load("../aoc/day11.txt"))
day12_input := string(#load("../aoc/day12.txt"))
day13_input := string(#load("../aoc/day13.txt"))
day14_input := string(#load("../aoc/day14.txt"))
day15_input := string(#load("../aoc/day15.txt"))
day16_input := string(#load("../aoc/day16.txt"))
/*day17_input := string(#load("../aoc/day17.txt"))*/ // Just hardcoded the input for this one. It was minimal
day18_input := string(#load("../aoc/day18.txt"))

Node :: struct {
	left : ^Node,
	right : ^Node,
	parent : ^Node,
	is_left : bool,
	is_right : bool,
	leaf : bool,
	val : int,
}

print_tree :: proc(using node : ^Node, level : int) {
	fmt.println()
	for i in 0..<level {
		_ = i
		fmt.print(".")
	}
	if leaf {
		fmt.print(val)
	} else {
		fmt.print(".")
		fmt.print("[")
		print_tree(left, level + 1)
		fmt.print(",")
		print_tree(right, level + 1)
		fmt.println()
		for i in 0..<level {
			_ = i
			fmt.print(".")
		}
		fmt.print(".")
		fmt.print("]")
	}
}

reduce :: proc(node : ^Node, level : int) -> bool {
	using node
	if leaf {
		return false
	} else {
		if level + 1 == 4 {
			log.info("Exploding:", node)
			log.info("Search left")
			parent_left_leaf := parent.left
			
			for parent_left_leaf != nil && !parent_left_leaf.leaf {
				if parent_left_leaf.is_left && parent_left_leaf.parent != nil {
					parent_left_leaf = parent_left_leaf.parent.parent
				} else {
					parent_left_leaf = parent_left_leaf.parent.left
				}
			}
			if parent_left_leaf != nil && parent_left_leaf.leaf {
				log.infof("Adding exploded left val of {} to {}", left.val, parent_left_leaf.val)
				parent_left_leaf.val += left.val
			}

			log.info("Search right")
			parent_right_leaf := parent.right
			for parent_right_leaf != nil && !parent_right_leaf.leaf {
				fmt.println("")
				fmt.println("iter")
				print_tree(parent_right_leaf, level)
				if parent_right_leaf.is_right && parent_right_leaf.parent != nil {
					parent_right_leaf = parent_right_leaf.parent.parent
				} else {
					parent_right_leaf = parent_right_leaf.parent.right
				}
			}
			if parent_right_leaf != nil && parent_right_leaf.leaf {
				log.infof("Adding exploded right val of {} to {}", right.val, parent_right_leaf.val)
				parent_right_leaf.val += right.val
			}
			
			left = nil
			right = nil
			val = 0
			leaf = true
			log.info("Explode finished")
			return true
		}
		left_reduced := reduce(left, level+1)
		if left_reduced do return true
		right_reduced := reduce(right, level+1)
		return right_reduced
	}
}

parse_tree :: proc(input : string, node : ^Node) { 
	curr := node
	for r,idx in input {
		log.info(r)
		switch r {
			case '[':
			curr.left = new(Node)
			curr.left.is_left = true
			curr.left.parent = curr
			curr = curr.left
			case ']':
			curr = curr.parent
			case ',':
			curr.right = new(Node)
			curr.right.is_right = true
			curr.right.parent = curr
			curr = curr.right
			case '0'..'9':
			curr.leaf = true
			curr.val = strconv.atoi(input[idx:idx+1])
			curr = curr.parent
		}
	}
}

day18 :: proc() {
	input := day18_input

	line, ok := strings.split_iterator(&input, "\n")
	root : Node
	/*for ok {*/
		line = strings.trim_space(line)
		log.info(line)

		parse_tree(line[0:len(line)], &root)
		print_tree(&root, 0)
		line, ok = strings.split_iterator(&input, "\n")
	/*}*/
	reduce(&root, 0)
	print_tree(&root, 0)
}

day17 :: proc() { 
	target_min_x := 138
	target_max_x := 184
	target_min_y := -125
	target_max_y := -71

	initial_pos := [2]int{0, 0}

	highest_y_found := min(int)
	highest_start_vel : [2]int
	distinct_initial_vels := 0
	for x_vel := 0; x_vel <= target_max_x; x_vel += 1 {
		for y_vel := target_min_y; y_vel <= 3000; y_vel += 1 {
			start_vel := [2]int{x_vel, y_vel}

			highest_y := min(int)

			pos := initial_pos
			vel := start_vel
			iter := 0
			for iter <= 1000 {
				pos = pos + vel
				if pos.y >= highest_y {
					highest_y = pos.y
				}
				if pos.y < target_min_y || pos.x > target_max_x {
					break
				}
				if pos.x >= target_min_x && pos.x <= target_max_x &&
					pos.y >= target_min_y && pos.y <= target_max_y {
					if highest_y >= highest_y_found {
						highest_y_found = highest_y
						highest_start_vel = start_vel
					}
					distinct_initial_vels += 1
					break
				}
				if vel.x > 0 do vel.x -= 1
				if vel.x < 0 do vel.x += 1
				vel.y -= 1
			}
		}
	}
	log.info("Part 1 highest Y Found:", highest_y_found)
	log.info("Part 2 distinct initial vels:", distinct_initial_vels)
}

sum_bits :: proc(bits : []u8) -> uint {
	res : uint = 0
	for b, idx in bits {
		add : uint = uint(b)
		for i in (idx+1)..<len(bits) {
			_ = i
			add = add << 1
		}
		res += add
	}
	return res
}

day16_version_sum := 0
consume_packet :: proc(bits: []u8) -> ([]u8, int, int) {
	curr := bits
	header_version_slice := curr[0:3]
	header_type_slice := curr[3:6]

	header_version := sum_bits(header_version_slice)
	header_type := sum_bits(header_type_slice)
	log.info(header_version)
	log.info(header_type)
	day16_version_sum += int(header_version)

	value := 0
	packet_vals := make([dynamic]int)

	if header_type == 4 {
		curr = curr[6:]

		packet_bits := make([dynamic]u8)
		for true {
			five := curr[0:5]
			curr = curr[5:]
			for b in five[1:] {
				append(&packet_bits, b)
			}
			if five[0] == 0 {
				break
			}
		}
		value = int(sum_bits(packet_bits[:]))
		log.info("Literal:", value)
	}
	else {
		curr = curr[6:]
		length_type := curr[0]
		curr = curr[1:]

		if length_type == 0 {
			num_bits_in_sub_packets_slice := curr[0:15]
			num_bits_in_sub_packets := sum_bits(num_bits_in_sub_packets_slice)
			log.info("Num bits in sub packets:", num_bits_in_sub_packets)
			curr = curr[15:]
			num_bits_consumed := 0
			for num_bits_consumed < int(num_bits_in_sub_packets) {
				new, n_consumed, val := consume_packet(curr)
				append(&packet_vals, val)
				num_bits_consumed += n_consumed
				curr = new
			}
			log.info("Num bits consumed vs num bits in sub packets", num_bits_consumed, num_bits_in_sub_packets)
		} else {
			num_sub_packets_slice := curr[0:11]
			num_sub_packets := sum_bits(num_sub_packets_slice)
			log.info("Num sub packets:", num_sub_packets)
			curr = curr[11:]
			n_consumed : int
			for i in  0..<num_sub_packets {
				_ = i
				val : int
				curr, n_consumed, val = consume_packet(curr)
				append(&packet_vals, val)
			}
		}
	}

	if header_type == 0 {
		for v in packet_vals {
			value += v
		}
	} else if header_type == 1 {
		value = 1
		for v in packet_vals {
			value *= v
		}
	} else if header_type == 2 {
		min_val := max(int)
		for v in packet_vals {
			min_val = min(v, min_val)
		}
		value = min_val
	} else if header_type == 3 {
		max_val := min(int)
		for v in packet_vals {
			max_val = max(v, max_val)
		}
		value = max_val
	} else if header_type == 5 {
		value = 1 if packet_vals[0] > packet_vals[1] else 0
	} else if header_type == 6 {
		value = 1 if packet_vals[0] < packet_vals[1] else 0
	} else if header_type == 7 {
		value = 1 if packet_vals[0] == packet_vals[1] else 0
	}

	log.info("Curr version sum:", day16_version_sum)
	return curr, (len(bits) - len(curr)), value
}

all_zero :: proc(buf : []u8) -> bool {
	for b in buf {
		if b != 0 do return false
	}
	return true
}

day16 :: proc() {
	input := strings.trim_space(day16_input)
	num_bits := 4*len(input)
	log.info("Num bits:", num_bits)

	bits := make([]u8, num_bits)
	hex_to_int :: proc(c: byte) -> u8 {
		switch c {
		case '0'..='9': return u8(c-'0')
		case 'a'..='f': return u8(c-'a')+10
		case 'A'..='F': return u8(c-'A')+10
		}
		return 0
	}

	for r, idx in input {
		v := hex_to_int(u8(r))
		_ = v
		/*strconv.append_bits(bits[:], u64(v), 2, false, 8, strconv.digits, nil)*/
		bits[idx*4 + 3] = u8(v % 2)
		v = v >> 1
		bits[idx*4 + 2] = u8(v % 2)
		v = v >> 1
		bits[idx*4 + 1] = u8(v % 2)
		v = v >> 1
		bits[idx*4] = u8(v % 2)
		v = v >> 1
	}
	/*log.info(bits)*/


	total_bits_consumed := 0
	value : int
	for len(bits) > 6 {
		log.info("BITS", bits)
		bits_consumed : int
		bits, bits_consumed, value = consume_packet(bits)
		total_bits_consumed += bits_consumed
		log.info("outer value:", value)
		
		if all_zero(bits) {
			break
		}
	}
	log.info("Total value:", value)
}

day15_part2 :: proc() {
	input := day15_input
	lines := strings.split(input, "\n")
	nrows := len(lines) - 1
	ncols := len(strings.trim_space(lines[0]))

	og_nrows := nrows
	og_ncols := ncols
	nrows *= 5
	ncols *= 5

	grid := make_2d_slice(nrows, ncols, int)
	defer delete_2d_slice(grid)
	for ridx in 0..<og_nrows {
		for cidx in 0..<og_ncols  {
			parsed_val := strconv.atoi(lines[ridx][cidx:cidx+1])
			for i := 0; i < 5; i += 1 {
				for j := 0; j < 5; j += 1 {
					val := ((parsed_val+i+j-1) % 9) + 1
					grid[ridx + i*og_nrows][cidx + j*og_ncols] = val
				}
			}
		}
	}

	g_scores : map[[2]int]int
	defer delete(g_scores)
	for y in 0..<nrows {
		for x in 0..<ncols {
			g_scores[{y,x}] = max(int)
		}
	}
	g_scores[{0,0}] = 0

	f_scores : map[[2]int]int
	defer delete(f_scores)
	f_scores[{0,0}] = nrows + ncols - 2

	nodes : map[[2]int]bool
	defer delete(nodes)
	nodes[[2]int{0,0}] = true

	/*came_from : map[[2]int][2]int*/

	end := [2]int{nrows-1, ncols-1}
	for len(nodes) > 0 {
		min_node : [2]int
		min_val := max(int)
		for key, val in nodes {
			_ = val
			if key in f_scores && f_scores[key] < min_val {
				min_node = key
				min_val = f_scores[key]
			}
		}

		if min_node == end {
			log.info("Found min score of:", f_scores[min_node])
			break
		}
		delete_key(&nodes, min_node)
		for i := -1; i <= 1; i += 1 {
			for j := -1; j <=1; j += 1 {
				if i == 0 && j == 0 do continue
				if abs(i) + abs(j) > 1 do continue
				if i + min_node[0] < 0 || i + min_node[0] >= nrows do continue
				if j + min_node[1] < 0 || j + min_node[1] >= ncols do continue

				neighbor := min_node + [2]int{i,j}
				tentative_gscore := g_scores[min_node] + grid[neighbor[0]][neighbor[1]]
				if tentative_gscore < g_scores[neighbor] {
					/*came_from[neighbor] = min_node*/
					g_scores[neighbor] = tentative_gscore
					f_scores[neighbor] = tentative_gscore + ncols + nrows - 2 - neighbor[0] - neighbor[1] 
					if neighbor not_in nodes {
						nodes[neighbor] = true
					}
				}
			}
		}
	}
}

day15_part1 :: proc() {
	input := day15_input
	lines := strings.split(input, "\n")
	nrows := len(lines) - 1
	ncols := len(strings.trim_space(lines[0]))

	grid := make_2d_slice(nrows, ncols, int)
	defer delete_2d_slice(grid)
	for row, ridx in &grid {
		for val, cidx in &row  {
			val = strconv.atoi(lines[ridx][cidx:cidx+1])
		}
	}

	g_scores : map[[2]int]int
	defer delete(g_scores)
	for y in 0..<nrows {
		for x in 0..<ncols {
			g_scores[{y,x}] = max(int)
		}
	}
	g_scores[{0,0}] = 0

	f_scores : map[[2]int]int
	defer delete(f_scores)
	f_scores[{0,0}] = nrows + ncols - 2

	nodes : map[[2]int]bool
	defer delete(nodes)
	nodes[[2]int{0,0}] = true

	/*came_from : map[[2]int][2]int*/

	end := [2]int{nrows-1, ncols-1}
	for len(nodes) > 0 {
		min_node : [2]int
		min_val := max(int)
		for key, val in nodes {
			_ = val
			if key in f_scores && f_scores[key] < min_val {
				min_node = key
				min_val = f_scores[key]
			}
		}

		if min_node == end {
			log.info("Found min score of:", f_scores[min_node])
			break
		}
		delete_key(&nodes, min_node)
		for i := -1; i <= 1; i += 1 {
			for j := -1; j <=1; j += 1 {
				if i == 0 && j == 0 do continue
				if abs(i) + abs(j) > 1 do continue
				if i + min_node[0] < 0 || i + min_node[0] >= nrows do continue
				if j + min_node[1] < 0 || j + min_node[1] >= ncols do continue

				neighbor := min_node + [2]int{i,j}
				tentative_gscore := g_scores[min_node] + grid[neighbor[0]][neighbor[1]]
				if tentative_gscore < g_scores[neighbor] {
					/*came_from[neighbor] = min_node*/
					g_scores[neighbor] = tentative_gscore
					f_scores[neighbor] = tentative_gscore + ncols + nrows - 2 - neighbor[0] - neighbor[1] 
					if neighbor not_in nodes {
						nodes[neighbor] = true
					}
				}
			}
		}
	}
}

day14_part2 :: proc() {
	input := day14_input
	line, ok := strings.split_iterator(&input, "\n")

	template := strings.trim_space(line)

	line, ok = strings.split_iterator(&input, "\n")
	pair_rules : map[string]rune
	defer delete(pair_rules)
	for ok {
		fields := strings.fields(line)
		pair_rules[fields[0]] = rune(fields[2][0])
		line, ok = strings.split_iterator(&input, "\n")
	}

	pair_counts : map[string]int
	pairs := len(template) - 1
	for i in 0..<pairs {
		pair := template[i:i+2]
		insert, rule_ok := pair_rules[pair]
		if rule_ok {
			pair_counts[pair] += 1
		}
	}
	log.info("Initial rules:", pair_rules)
	log.info("Initial pair counts:", pair_counts)

	for iter in 0..<40 {
		pair_counts_swap : map[string]int
		for pk in pair_counts {
			pair_counts_swap[pk] = 0
		}
		for pk, pv in pair_rules {
			count := pair_counts[pk]
			first_pair : strings.Builder
			second_pair : strings.Builder 
			strings.init_builder(&first_pair)
			strings.init_builder(&second_pair)
			strings.write_string(&first_pair, pk[0:1])
			strings.write_string(&first_pair, utf8.runes_to_string({pv}))
			strings.write_string(&second_pair, utf8.runes_to_string({pv}))
			strings.write_string(&second_pair, pk[1:2])
			pair_counts_swap[strings.to_string(first_pair)] += count
			pair_counts_swap[strings.to_string(second_pair)] += count
		}
		temp := pair_counts
		pair_counts = pair_counts_swap
		delete(temp)
	}

	freqs : map[u8]int
	for pk, pv in pair_counts {
		freqs[pk[0]] += pv
		freqs[pk[1]] += pv
	}

	map_vals := slice.map_values(freqs)
	defer delete(map_vals)
	slice.sort(map_vals)
	most := map_vals[len(map_vals)-1]
	least := map_vals[0]
	log.infof("40 iters (most freq count) - (least freq count) = {}", (most - least)/2)
	delete(pair_counts)
}

day14_part1 :: proc() {
	input := day14_input
	line, ok := strings.split_iterator(&input, "\n")

	template := strings.trim_space(line)
	_ = template

	line, ok = strings.split_iterator(&input, "\n")
	pair_rules : map[string]string
	for ok {
		fields := strings.fields(line)
		pair_rules[fields[0]] = fields[2] 
		line, ok = strings.split_iterator(&input, "\n")
	}
	log.info(pair_rules)

	for iter in 0..<10 {
		_ = iter
		pairs := len(template) - 1
		builder := strings.make_builder()
		strings.write_string(&builder, template[0:1])
		defer strings.destroy_builder(&builder)
		for i in 0..<pairs {
			pair := template[i:i+2]
			insert, rule_ok := pair_rules[pair]
			if rule_ok {
				strings.write_string(&builder, insert)

			}
			strings.write_string(&builder, pair[1:2])
		}
		temp := template
		template = strings.clone(strings.to_string(builder))
		if iter > 0 do delete(temp)
	}

	freqs : map[rune]int

	for r in template {
		freqs[r] += 1
	}

	map_vals := slice.map_values(freqs)
	defer delete(map_vals)
	slice.sort(map_vals)
	most := map_vals[len(map_vals)-1]
	least := map_vals[0]
	log.info(map_vals)
	log.info(freqs)
	log.infof("Part 1. 10 iters (most freq count) - (least freq count) -> {} - {} = {}", most, least, most - least)

}

Fold :: struct {
	y_fold : bool,
	idx : int,
}

day13 :: proc() {
	input := day13_input
	line, ok := strings.split_iterator(&input, "\n")

	backing := make_2d_slice(1311, 1311, int)
	defer delete_2d_slice(backing)
	for ok {
		line = strings.trim_space(line)
		if len(line) == 0 {
			break
		}

		fproc := proc(r: rune) -> bool {
			return r == ' ' || r == ',' || r == '\n'
		}
		dot := strings.fields_proc(line, fproc)
		x := strconv.atoi(dot[0])
		y := strconv.atoi(dot[1])
		backing[y][x] = 1

		line, ok = strings.split_iterator(&input, "\n")
	}

	line, ok = strings.split_iterator(&input, "\n")
	folds := make([dynamic]Fold)
	for ok {
		line = strings.trim_space(line)
		fproc := proc(r: rune) -> bool {
			return r == ' ' || r == '=' || r == '\n'
		}
		fields := strings.fields_proc(line, fproc)
		y_fold := fields[2] == "y"
		val := strconv.atoi(fields[3])
		fold := Fold{y_fold, val}
		append(&folds, fold)
		line, ok = strings.split_iterator(&input, "\n")
	}

	grid := make_2d_sub_slice(len(backing), len(backing[0]), backing)
	for fold, idx in folds {
		if fold.y_fold {
			new_grid := make_2d_sub_slice(fold.idx, len(grid[0]), grid)
			other_half := make_2d_sub_slice(fold.idx+1, 0, fold.idx, len(grid[0]), grid)
			for i in 0..<fold.idx {
				for j in 0..<len(grid[0]) {
					new_grid[i][j] |= other_half[len(other_half) - i - 1][j]
				}
			}

			if idx == 0 {
				dot_count := 0
				for row in new_grid {
					for val in row {
						dot_count += int(val)
					}
				}
				log.info("Part 1 dot count after first fold:", dot_count)
			}
			grid = new_grid
		} else if !fold.y_fold {
			new_grid := make_2d_sub_slice(len(grid), fold.idx, grid)
			other_half := make_2d_sub_slice(0, fold.idx+1, len(grid), fold.idx, grid)
			for i in 0..<len(new_grid) {
				for j in 0..<fold.idx {
					new_grid[i][j] |= other_half[i][len(other_half[0]) - 1 - j]
				}
			}

			if idx == 0 {
				dot_count := 0
				for row in new_grid {
					for val in row {
						dot_count += int(val)
					}
				}
				log.info("Part 1 dot count after first fold:", dot_count)
			}
			temp := grid
			grid = new_grid
			delete_2d_sub_slice(temp)
		}
	}

	for row in grid {
		vals := make([]string, len(row))
		defer delete(vals)
		for v, vi in row {
			pr := "X" if v == 1 else "O"
			vals[vi] = pr
		}
		log.info(vals)
	}
}

day12_part2 :: proc() {
	input := day12_input
	line, ok := strings.split_iterator(&input, "\n")

	system := make(map[string][dynamic]string)
	defer delete(system)
	defer for k,v in system do delete(v)
	for ok {
		line = strings.trim_space(line)

		fproc := proc(r: rune) -> bool {
			return r == ' ' || r == '-' || r == '\n'
		}
		caves := strings.fields_proc(line, fproc)
		log.info(caves)

		cave1_ok := caves[0] in system
		if !cave1_ok {
			system[caves[0]] = make([dynamic]string)
		}
		append(&system[caves[0]], caves[1])

		cave2_ok := caves[1] in system
		if !cave2_ok {
			system[caves[1]] = make([dynamic]string)
		}
		append(&system[caves[1]], caves[0])


		line, ok = strings.split_iterator(&input, "\n")
	}

	log.info(system)

	start := system["start"]

	paths := make([dynamic][dynamic]string) 
	double_visited := make([dynamic]bool)
	for cave in start {
		path := make([dynamic]string)
		append(&path, "start")
		append(&path, cave)
		append(&paths, path)
		append(&double_visited, false)
	}

	final_paths := make([dynamic][dynamic]string)
	for len(paths) > 0 {
		new_paths := make([dynamic][dynamic]string)
		new_double_visited := make([dynamic]bool)
		for path, idx in paths {
			choices := system[path[len(path)-1]]

			for choice in choices {
				if choice == "start" {
					continue
				}
				contains_choice := false
				if unicode.is_lower(rune(choice[0])) {
					contains_choice = slice.contains(path[:], choice)
					if contains_choice && double_visited[idx] {
						continue
					}
				}

				path_copy := make([dynamic]string)
				for val in path {
					append(&path_copy, val)
				}
				append(&path_copy, choice)
				if choice == "end" {
					append(&final_paths, path_copy)
				} else {
					append(&new_paths, path_copy)
					append(&new_double_visited, contains_choice || double_visited[idx])
				}
			}
		}
		/*log.info(new_paths)*/
		paths, new_paths = new_paths, paths
		double_visited, new_double_visited = new_double_visited, double_visited
		delete(new_paths)
		delete(new_double_visited)
	}
	/*log.info(final_paths)*/
	log.info("Part 2 num of unique paths:", len(final_paths))
}

day12_part1 :: proc() {
	input := day12_input
	line, ok := strings.split_iterator(&input, "\n")

	system := make(map[string][dynamic]string)
	defer delete(system)
	defer for k,v in system do delete(v)
	for ok {
		line = strings.trim_space(line)

		fproc := proc(r: rune) -> bool {
			return r == ' ' || r == '-' || r == '\n'
		}
		caves := strings.fields_proc(line, fproc)
		log.info(caves)

		cave1_ok := caves[0] in system
		if !cave1_ok {
			system[caves[0]] = make([dynamic]string)
		}
		append(&system[caves[0]], caves[1])

		cave2_ok := caves[1] in system
		if !cave2_ok {
			system[caves[1]] = make([dynamic]string)
		}
		append(&system[caves[1]], caves[0])

		line, ok = strings.split_iterator(&input, "\n")
	}

	log.info(system)

	start := system["start"]

	paths := make([dynamic][dynamic]string) 
	for cave in start {
		path := make([dynamic]string)
		append(&path, "start")
		append(&path, cave)
		append(&paths, path)
	}

	final_paths := make([dynamic][dynamic]string)
	defer delete(final_paths)
	for len(paths) > 0 {
		new_paths := make([dynamic][dynamic]string)
		for path in paths {
			choices := system[path[len(path)-1]]

			for choice in choices {
				if unicode.is_lower(rune(choice[0])) {
					if slice.contains(path[:], choice) {
						continue
					}
				}
				path_copy := make([dynamic]string)
				for val in path {
					append(&path_copy, val)
				}
				append(&path_copy, choice)
				if choice == "end" {
					append(&final_paths, path_copy)
				} else {
					append(&new_paths, path_copy)
				}
			}
		}
		/*log.info(new_paths)*/
		paths, new_paths = new_paths, paths
		for v in new_paths do delete(v)
		delete(new_paths)
	}
	/*log.info(final_paths)*/
	log.info("Part 1 num of unique paths:", len(final_paths))
	for v in paths do delete(v)
	delete(paths)
}


make_2d_sub_slice :: proc {
	make_2d_sub_slice_from_begin,
	make_2d_sub_slice_from_coord,
}

make_2d_sub_slice_from_begin :: proc(height, width: int, backing: [][]$T, allocator := context.allocator) -> (res: [][]T) {
	return make_2d_sub_slice_from_coord(0, 0, height, width, backing, allocator)
}

make_2d_sub_slice_from_coord :: proc(y, x, height, width: int, backing: [][]$T, allocator := context.allocator) -> (res: [][]T) {
	assert (x >= 0 && y >= 0 && width > 0 && height > 0)
	assert(y < len(backing))
	assert(x < len(backing[0]))
	assert(y+height <= len(backing))
	assert(x+width <= len(backing[0]))
	context.allocator = allocator

	res = make([][]T, height)

	for i in 0..<height {
		res[i] = backing[y+i][x:][:width]
	}
	return
}

delete_2d_sub_slice :: proc(slice: [][]$T, allocator := context.allocator) {
	delete(slice, allocator)
}

make_2d_slice :: proc(y, x: int, $T: typeid, allocator := context.allocator) -> (res: [][]T) {
    assert(x > 0 && y > 0)
    context.allocator = allocator

    backing := make([]T, x * y)
    res      = make([][]T, y)

    for i in 0..<y {
        res[i] = backing[x * i:][:x]
    }
    return
}

delete_2d_slice :: proc(slice: [][]$T, allocator := context.allocator) {
    delete(slice[0], allocator)
    delete(slice,    allocator)
}

test_slicing :: proc() {
    slices := make_2d_slice(8, 7, int)

    for _, y in slices {
        for _, x in slices[y] {
            slices[y][x] = y
        }
    }

    log.info(slices)


	sub_slice := make_2d_sub_slice(1, 2, 6, 4, slices)
	log.info(sub_slice)

    delete_2d_slice(slices)
	delete_2d_sub_slice(sub_slice)
    log.info("Done.")
}

Octo :: struct {
	val : int,
	flashed : bool,
}

octos_pitch := 0
index_octos :: #force_inline proc(row,col : int) -> int {
	return (row*octos_pitch + col)
}

set_edges :: proc(octos : ^[]Octo, nrows, ncols : int) {
	for row in 0..<nrows {
		if row == 0 || row == nrows-1 {
			for col in 0..<ncols {
				octos[index_octos(row, col)].val = min(int)
			}
		}
		octos[index_octos(row, 0)].val = min(int)
		octos[index_octos(row, ncols-1)].val = min(int)
	}
}

day11 :: proc() {
	input := day11_input
	/*line, ok := strings.split_iterator(&input, "\n")*/
	lines := strings.split(input, "\n")
	nrows := len(lines) - 1
	ncols := len(strings.trim_space(lines[0]))
	octos_pitch = ncols+2
	log.info(nrows)
	log.info(ncols)
	octos := make([]Octo, (nrows+2)*(ncols+2))

	for line, row in &lines {
		line = strings.trim_space(line)
		for r, col in line {
			octos[index_octos((row+1), (col+1))].val = strconv.atoi(utf8.runes_to_string({r}))
		}
	}

	set_edges(&octos, nrows+2, ncols+2)
	log.info(octos)

	flash_count := 0
	step := 0
	all_flashed := false
	for !all_flashed {
		defer {step += 1}
		/*log.info("Step", step)*/
		step_flash_count := 0
		// Increment all by 1
		for row in 1..nrows {
			for col in 1..ncols {
				octos[index_octos(row, col)].val += 1
			}
		}

		flash_occured := true
		for flash_occured {
			flash_occured = false
			for row in 1..nrows {
				for col in 1..ncols {
					octo := &octos[index_octos(row, col)]
					if octo.val > 9 {
						if !octo.flashed {
							/*log.info("flash at", row, col)*/
							flash_occured = true
							octo.flashed = true
							flash_count += 1
							step_flash_count += 1
							for i in -1..1 {
								for j in -1..1 {
									if i == 0 && j == 0 {
										continue
									}
									octos[index_octos((row+i), (col+j))].val += 1
								}
							}
						}
					}
				}
			}

			/*set_edges(&octos)*/
		}

		if step_flash_count == nrows*ncols {
			all_flashed = true
			log.info("All flashed at step", step+1)
		}

		if (step+1) == 100 {
			log.info("Step 100 flash_count:", flash_count)
		}

		for row in 1..11 {
			for col in 1..11 {
				octo := &octos[index_octos(row, col)]
				if octo.val > 9 {
					octo.flashed = false
					octo.val = 0
				}
			}
		}
	}
}

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
	/*day10()*/
	/*day11()*/
	/*test_slicing()*/
	/*day12_part1()*/
	/*day12_part2()*/
	/*day13()*/
	/*day14_part1()*/
	/*day14_part2()*/
	/*day15_part1()*/
	/*day15_part2()*/
	/*day16()*/
	/*day17()*/
	day18()
}
