package main

import "core:fmt"
import "relative"
import "core:mem"
import "core:os"

main :: proc() {
	Node :: struct {
		next : relative.Ptr(^Node, byte)
	}
	NUM_NODES :: 8
	nodes : [NUM_NODES]Node

	for &node, idx in nodes {
		relative.encode(&nodes[idx].next, &nodes[(idx+1) % len(nodes)])
	}

	nodes_copy : [NUM_NODES]Node
	mem.copy(&nodes_copy[0], &nodes[0], size_of(nodes))

	fmt.printf("Base node ptr: {}\n", rawptr(&nodes_copy[0]))
	for &node, idx in nodes_copy {
		ptr := relative.decode(&node.next)
		fmt.printf("node[{}].next decoded to {}\n", idx, rawptr(ptr))
	}
}
