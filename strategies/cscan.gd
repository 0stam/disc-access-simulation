extends Strategy
class_name CSCAN


func select_request(requests: Array[Request], head_pos: int) -> int:
	var sorted_requests: Array[Request] = requests.duplicate(true)
	sorted_requests.sort_custom(func(a, b): return a.position < b.position)
	
	if sorted_requests[-1].position < head_pos:
		return requests.find(sorted_requests[0])
	
	for req: Request in sorted_requests:
		if req.position >= head_pos:
			return requests.find(req)
	
	assert(false, "Invalid code or function input")
	return 0
