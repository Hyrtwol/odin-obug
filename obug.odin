package obug

import "core:fmt"
import "core:mem"
import "core:os"
import "core:encoding/ansi"

exit :: os.exit

RESET_COLOR :: ansi.CSI + ansi.RESET + ansi.SGR
NO_LEAKS_COLOR :: ansi.CSI + ansi.BG_BLUE + ";" + ansi.FG_WHITE + ansi.SGR
LEAKS_COLOR :: ansi.CSI + ansi.BG_RED + ";" + ansi.FG_WHITE + ansi.SGR
LEAK_COLOR :: ansi.CSI + ansi.BG_DEFAULT + ";" + ansi.FG_YELLOW + ansi.SGR

tracked_run :: proc(run: #type proc()) -> int {
	fmt.print(NO_LEAKS_COLOR)
	fmt.print(" -= using tracking allocator =- ")
	fmt.print(RESET_COLOR)
	fmt.println(" \U0001F50D")

	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	defer mem.tracking_allocator_destroy(&track)
	context.allocator = mem.tracking_allocator(&track)

	run()

	errors := 0
	if len(track.allocation_map) > 0 || len(track.bad_free_array) > 0 {
		fmt.print(LEAKS_COLOR)
		fmt.print(" -= leaks detected =- ")
		fmt.print(RESET_COLOR)
		fmt.println(" \U0001F4A6")

		for _, leak in track.allocation_map {
			fmt.print(LEAK_COLOR)
			fmt.printf("%v leaked %m", leak.location, leak.size)
			fmt.println(RESET_COLOR)
			errors += 1
		}
		for bad_free in track.bad_free_array {
			fmt.print(LEAK_COLOR)
			fmt.printf("%v allocation %p was freed badly", bad_free.location, bad_free.memory)
			fmt.println(RESET_COLOR)
			errors += 1
		}
	} else {
		fmt.print(NO_LEAKS_COLOR)
		fmt.print(" -= no leaks =- ")
		fmt.print(RESET_COLOR)
		fmt.println(" \U0001F37B")
	}
	return errors
}
