extends Strategy
class_name FDSSTF


func select_request(requests: Array[Request], head_pos: int) -> int:
	var target: int = -1
	var min_distance = 300
	var min_deadline = 1000
	
	for i in len(requests):
		if requests[i].real_time:
			if requests[i].deadline < min_deadline:
				target = i
				min_distance = abs(head_pos - requests[i].position)
				min_deadline = requests[i].deadline
			elif requests[i].deadline == min_deadline:
				var curr_distance: int = abs(head_pos - requests[i].position)
				
				if curr_distance < min_distance:
					target = i
					min_distance = curr_distance
	
	return target
