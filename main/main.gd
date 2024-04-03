extends Control

var real_time_allowed: bool = false
var pointer_speed: int = 200
var process_count: int = 1000
var rt_probability: int = 5
var spawn_period: int = 20

var runner_config: Array[Array] = []

var runners: Array[Runner] = []
var disks: Array[Disk] = []

var disk_scene: PackedScene = preload("res://disk/disk.tscn")
var result_display_scene = preload("res://ui/result_display.tscn")

@onready var disks_grid := $Disks
@onready var ui := $UI
@onready var config_panel := $ConfigPanel
@onready var settings_node := $ConfigPanel/Settings
@onready var abort_button := $UI/Abort


func _ready() -> void:
	return
	prepare_simulation()
	start_runners()


func reset():
	for child in ui.get_children():
		if child is ResultDisplay:
			ui.remove_child(child)
	
	for child in disks_grid.get_children():
		disks_grid.remove_child(child)
	
	abort_button.hide()
	
	runners = []
	disks = []


func prepare_simulation():
	var positions: Array[int] = []
	var delays: Array[int] = []
	
	for i in process_count:
		positions.append(randi_range(0, 199))
		
		if randi_range(1, 100) <= rt_probability and real_time_allowed:
			delays.append(randi_range(200, 1000))
		else:
			delays.append(0)
	
	# Visual setup
	disks_grid.columns = clamp(len(runner_config), 1, 2)
	abort_button.show()
	
	for config in runner_config:
		var requests: Array[Request] = create_requests(positions, delays)
		
		create_runner(config[0], config[1], requests)


func create_requests(positions: Array[int], delays: Array[int]) -> Array[Request]:
	assert(len(positions) == len(delays), "Mismatching array lengths for postions and real time")
	
	var requests: Array[Request] = []
	
	for i in len(positions):
		requests.append(Request.new(positions[i], delays[i] != 0, delays[i]))
	
	return requests


func create_runner(name: String, strategy: Strategy, requests: Array[Request]) -> void:
	var disk: Disk = disk_scene.instantiate()
	disk.pointer_speed = pointer_speed
	disks.append(disk)
	
	var container := AspectRatioContainer.new()
	container.add_child(disk)
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	disks_grid.add_child(container)
	
	var runner: Runner = Runner.new(name, strategy, disk, requests)
	runner.new_request_period = spawn_period
	runners.append(runner)
	
	var result_display: ResultDisplay = result_display_scene.instantiate()
	runner.avg_wait_changed.connect(result_display._avg_wait_changed)
	
	ui.add_child(result_display)
	ui.move_child(result_display, len(runners) - 1)


func start_runners() -> void:
	for runner in runners:
		runner.handle_request()


func _on_spin_box_value_changed(value: float) -> void:
	pointer_speed = value
	
	for disk in disks:
		disk.pointer_speed = value


func _on_start_pressed() -> void:
	real_time_allowed = settings_node.get_node("RTProcesses").button_pressed
	
	runner_config = []
	
	if settings_node.get_node("FCFS").button_pressed:
		runner_config.append(["FCFS", FCFS.new()])
	if settings_node.get_node("SSTF").button_pressed:
		runner_config.append(["SSTF", SSTF.new()])
	if settings_node.get_node("SCAN").button_pressed:
		runner_config.append(["SCAN", SCAN.new()])
	if settings_node.get_node("CSCAN").button_pressed:
		runner_config.append(["C-SCAN", CSCAN.new()])
	
	config_panel.hide()
	prepare_simulation()
	start_runners()


func _on_abort_pressed() -> void:
	reset()
	config_panel.show()


func _on_process_count_value_changed(value: float) -> void:
	process_count = value


func _on_spawn_period_value_changed(value: float) -> void:
	spawn_period = value


func _on_rt_probability_value_changed(value: float) -> void:
	rt_probability = value
