package main

import "core:log"
import "core:strings"
import "core:strconv"

day1_input := string(#load("../aoc/day1.txt"))
day2_input := string(#load("../aoc/day2.txt"))

day2_part2 :: proc() {
	input := day2_input

	depth := 0
	horiz := 0
	aim := 0

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
			curr, conv_ok := strconv.parse_int(line)
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
	day2_part1()
	day2_part2()
}
