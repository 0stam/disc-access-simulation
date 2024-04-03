extends Strategy
class_name SSTF


func select_request(requests: Array[Request], head_pos: int) -> int:
	var target = -1
	var min_distance = 300
	
	for i in len(requests):
		var curr_distance: int = abs(requests[i].position - head_pos)
		
		if curr_distance < min_distance:
			target = i
			min_distance = curr_distance
	
	return target
