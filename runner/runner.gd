## Class handling the simulation of disk requests. Requires the [member animation]
## field to be assigned to work properly.
extends Object
class_name Runner

## Emitted every time average request wait time changes
signal avg_wait_changed(runner_name: String, avg_wait: float)

## After the head moves this much, new request is spawned
var new_request_period := 20

## Runner name used for displaying statistics
var name: String

var future_requests: Array[Request]
var requests: Array[Request]
var real_time_requests: Array[Request]
var finished_requests: Array[Request]

var real_time_count: int

## Strategy used for selecting requests
var strategy: Strategy
## Strategy used for handling requests if there are real time requests in [member requests]
var real_time_strategy: Strategy
## Reference to the node handling animation
var animation: Disk

## Current position of the head. It's only used for internal calculations, not for updating animation
var head_pos: int

## Current time until next request
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


## Handles next request from [member requests] and and new one from the end of [future_requests]
## if the period elapsed.[br]
## Should be called by an animation once it finishes displaying previous movement.
func handle_request() -> void:
	# True if there was no animation started and the function must call itself to continue
	var recall_required := true
	
	if requests:
		var index: int
		
		# If there are real time requests, prioritize them with a real time strategy
		if real_time_count:
			index = real_time_strategy.select_request(requests, head_pos)
			real_time_count -= 1
		else:
			index = strategy.select_request(requests, head_pos)
		
		# Update displayed request list
		animation.set_requests(requests + real_time_requests, index)
		
		# Get current request
		var curr_request: Request = requests.pop_at(index)
		finished_requests.append(curr_request)
		
		# Make other requests wait
		var wait_time: int = abs(head_pos - curr_request.position)
		
		for r in requests:
			r.wait(wait_time)
		
		# Update parameters
		head_pos = curr_request.position
		new_request_cooldown -= wait_time
		
		# Start animation, it will call the function again once it finishes
		animation.begin_move(curr_request.position)
		recall_required = false
		
		# Notify observers that request stats have changed 
		avg_wait_changed.emit(name, get_avg_wait())
	
	# If there are no requests, skip time to when we are spawning one
	if not requests and new_request_cooldown > 0:
		new_request_cooldown = 0
	
	# Spawn new processes
	while new_request_cooldown <= 0 and future_requests:
		requests.append(future_requests.pop_back())
		new_request_cooldown += new_request_period
		
		if requests[-1].real_time:
			real_time_count += 1
	
	# If no requests were processed
	if recall_required:
		if requests:  # New request was added, re-call the function
			handle_request()
		else:  # We are out of requests, end the execution
			animation.set_requests([], 0)


## Returns average wait time of running and finished requests
func get_avg_wait() -> float:
	var summ: int = 0
	
	for req: Request in requests + finished_requests:
		summ += req.wait_time
	
	return summ / (len(requests) + len(finished_requests))
