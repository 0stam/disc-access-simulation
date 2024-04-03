extends Control


func _ready() -> void:
	var positions: Array[int] = []
	var delays: Array[int] = []
	
	for i in 1000:
		positions.append(randi_range(0, 199))
		
		if randi_range(0, 15) == 0 and false:
			delays.append(randi_range(200, 1000))
		else:
			delays.append(0)
	
	var requests: Array[Request] = create_requests(positions, delays)
	
	var runner: Runner = Runner.new("CSCAN", CSCAN.new(), $Disks/Disk, requests)
	runner.handle_request()
	
	var requests2 = create_requests(positions, delays)
	var runner2: Runner = Runner.new("SCAN", SCAN.new(), $Disks/Disk2, requests2)
	runner2.handle_request()


func create_requests(positions: Array[int], delays: Array[int]) -> Array[Request]:
	assert(len(positions) == len(delays), "Mismatching array lengths for postions and real time")
	
	var requests: Array[Request] = []
	
	for i in len(positions):
		requests.append(Request.new(positions[i], delays[i] != 0, delays[i]))
	
	return requests
