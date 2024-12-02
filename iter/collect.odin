package iter

collect :: proc {
	collect_as,
	collect_array,
	collect_into,
}

collect_as :: proc(
	$Arr: typeid,
	iterator: ^Iterator($Item, $Context),
	allocator := context.allocator,
) -> Arr {
	result := make(Arr)

	for value in next(iterator) {
		append(&result, value)
	}

	return result
}

collect_array :: proc(
	iterator: ^Iterator($Item, $Context),
	allocator := context.allocator,
) -> [dynamic]Item {
	return collect_as([dynamic]Item, iterator, allocator = allocator)
}

collect_into :: proc(iterator: ^Iterator($Item, $Context), target: ^[dynamic]Item) {
	for value in next(iterator) {
		append(target, value)
	}
}
