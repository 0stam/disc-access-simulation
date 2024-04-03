extends Strategy
class_name SCAN

var direction: int = 1


func select_request(requests: Array[Request], head_pos: int) -> int:
	var target: int = -1
	var min_distance: int = 300
	
	for i in len(requests):
		if (requests[i].position - head_pos) * direction >= 0:
			var curr_distance: int = abs(requests[i].position - head_pos)
			
			if curr_distance < min_distance:
				target = i
				min_distance = curr_distance
	
	if target == -1:
		direction *= -1
		return select_request(requests, head_pos)
	
	return target
