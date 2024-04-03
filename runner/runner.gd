extends Object
class_name Runner

signal avg_wait_changed(runner_name: String, avg_wait: float)

const new_request_period := 20

var name: String

var future_requests: Array[Request]
var requests: Array[Request]
var real_time_requests: Array[Request]
var finished_requests: Array[Request]

var real_time_count: int

var strategy: Strategy
var real_time_strategy: Strategy
var animation: Disk

var head_pos: int

var new_request_cooldown: int = new_request_period

func _init(name: String, strategy: Strategy, animation: Disk, future_requests: Array[Request]) -> void:
	self.name = name
	self.strategy = strategy
	self.animation = animation
	self.future_requests = future_requests
	
	self.requests = []
	self.finished_requests = []
	self.head_pos = 0
	self.real_time_count = 0
	
	real_time_strategy = FDSSTF.new()
	
	animation.move_finished.connect(handle_request)


func handle_request() -> void:
	var recall_required := true
	
	if requests:
		var index: int
		
		if real_time_count:
			index = real_time_strategy.select_request(requests, head_pos)
			real_time_count -= 1
		else:
			index = strategy.select_request(requests, head_pos)
		
		animation.set_requests(requests + real_time_requests, index)
		
		var curr_request: Request = requests.pop_at(index)
		
		var wait_time: int = abs(head_pos - curr_request.position)
		
		for r in requests:
			r.wait(wait_time)
		
		head_pos = curr_request.position
		finished_requests.append(curr_request)
		new_request_cooldown -= wait_time
		
		animation.begin_move(curr_request.position)
		recall_required = false
		
		avg_wait_changed.emit(name, get_avg_wait())
	
	if not requests and new_request_cooldown > 0:
		new_request_cooldown = 0
	
	while new_request_cooldown <= 0 and future_requests:
		requests.append(future_requests.pop_back())
		new_request_cooldown += new_request_period
		
		if requests[-1].real_time:
			real_time_count += 1
	
	if recall_required:
		if requests:
			handle_request()
		else:
			animation.set_requests([], 0)


func get_avg_wait() -> float:
	var summ: int = 0
	
	for req: Request in requests + finished_requests:
		summ += req.wait_time
	
	return summ / (len(requests) + len(finished_requests))
