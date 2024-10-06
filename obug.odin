package obug

import "core:fmt"
import "core:mem"

tracked_run :: proc(run: #type proc()) -> int {
	fmt.println("tracking allocator")
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	defer mem.tracking_allocator_destroy(&track)
	context.allocator = mem.tracking_allocator(&track)

	run()

	errors := 0
	for _, leak in track.allocation_map {
		fmt.printf("%v leaked %m\n", leak.location, leak.size)
		errors += 1
	}
	for bad_free in track.bad_free_array {
		fmt.printf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
		errors += 1
	}
	return errors
}

