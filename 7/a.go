package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"sort"
	"strconv"
	"strings"
)

type NodeType int

const (
	Folder NodeType = iota + 1
	File
)

type Node struct {
	name     string
	size     int
	kind     NodeType
	parent   *Node
	children []*Node
}

func main() {
	file, err := os.Open("input")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	// Read file line-by-line
	scanner := bufio.NewScanner(file)

	// Build a basic tree
	tree := buildTree(scanner)

	// Calculate directory sizes
	calcDirSizes(&tree)

	// Part A: Find all folders smaller than 100_000
	outputA := []int{}
	filterFlatMapTree(&tree, func(n Node) int {
		// Only count folders and ignore root
		if n.kind == Folder && n.name != "/" {
			return n.size
		} else {
			return 0
		}
	}, func(s int) bool { return s <= 100_000 }, &outputA)

	// Calculate summed size of all folders <= 100000
	total := 0
	for _, i := range outputA {
		total += i
	}

	fmt.Println("Combined size of all directories with size <= 10,000:\n\t" + fmt.Sprint(total))

	// Part B: Find the smallest folder that will free up enough space for the
	// update.
	outputB := []int{}
	unusedSpace := 70_000_000 - tree.size
	filterFlatMapTree(&tree, func(n Node) int {
		if n.kind == Folder {
			return n.size
		} else {
			return 0
		}
	}, func(s int) bool {
		// required unused space - current unused space
		return s >= (30_000_000 - unusedSpace)
	}, &outputB)
	sort.Ints(outputB)

	fmt.Println("Smallest directory to delete has size:\n\t" + fmt.Sprint(outputB[0]))
}

// Map all items in the tree, then filter them and produce an array.
func filterFlatMapTree[T interface{}](tree *Node, mapFunc func(Node) T, filterFunc func(T) bool, output *[]T) {
	result := mapFunc(*tree)
	if filterFunc(result) {
		*output = append(*output, result)
	}
	for _, c := range tree.children {
		filterFlatMapTree(c, mapFunc, filterFunc, output)
	}
}

// Calculates all directory sizes recursively.
func calcDirSizes(tree *Node) {
	// depth-first search
	if tree.kind == Folder {
		for _, c := range tree.children {
			calcDirSizes(c)
			tree.size += c.size
		}
	}
}

// Helper function to pretty-print a tree the same way AoC shows
func printTree(tree *Node, level int) {
	sfx := ""
	if tree.kind == Folder {
		sfx = "dir"
	} else {
		sfx = "file, size=" + fmt.Sprint(tree.size)
	}
	fmt.Println(strings.Repeat("  ", level) + "- " + tree.name + " (" + sfx + ")")
	for _, c := range tree.children {
		printTree(c, level+1)
	}
}

func buildTree(scanner *bufio.Scanner) Node {
	tree := Node{
		name: "/",
		size: 0,
		kind: Folder,
	}
	currentNode := &tree
	for scanner.Scan() {

		command := scanner.Text()
		commandEntries := strings.Split(command, " ")

		if commandEntries[0] == "$" {
			if commandEntries[1] == "cd" {
				if commandEntries[2] == ".." {
					// Move up in tree
					currentNode = currentNode.parent
				} else if commandEntries[2] == "/" {
					continue // we make the root folder manually
				} else {
					// Navigate to folder
					childIndex := 0
					for i := range currentNode.children {
						if currentNode.children[i].name == commandEntries[2] {
							childIndex = i
							break
						}
					}
					currentNode = currentNode.children[childIndex]
				}
			} else {
				// Must be ls
				continue
			}
		} else {
			newChild := Node{}
			if commandEntries[0] == "dir" {
				newChild = Node{
					name:   commandEntries[1],
					size:   0,
					kind:   Folder,
					parent: currentNode,
				}
			} else {
				// Ignore err since we can be p sure the file is well-formed
				size, _ := strconv.ParseInt(commandEntries[0], 10, 0)
				newChild = Node{
					name:   commandEntries[1],
					size:   int(size),
					kind:   File,
					parent: currentNode,
				}
			}

			currentNode.children = append(currentNode.children, &newChild)
		}
	}

	return tree
}
