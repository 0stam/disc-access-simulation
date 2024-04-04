extends Control
class_name Disk

signal move_finished

var pointer_destination: int
var pointer_pos: float

@export var pointer_speed: float = 200:
	set(val):
		pointer_speed = val
		
		if disk_circle != null:
			disk_circle.update_speed(pointer_speed)

@onready var disk_circle: DiskCircle = $DiskCircle
@onready var pointer: TextureRect = $Pointer


func _ready() -> void:
	set_process(false)
	await get_tree().process_frame
	if not is_processing():
		teleport(0)


func teleport(pos: int) -> void:
	set_pointer_position(pos)
	pointer_destination = pos
	pointer_pos = pos
	set_process(false)


func begin_move(pos: int) -> void:
	pointer_destination = pos
	set_process(true)


func set_pointer_position(pos: int) -> void:
	var center: Vector2 = size / 2.0
	
	var y: float = (size.y / 2) * (pos / 200.0)
	
	pointer.position = center - Vector2(0, y) - pointer.size / 2


func set_requests(requests: Array[Request], current_request: int) -> void:
	var request_positions: Array[int] = []
	
	for req in requests:
		request_positions.append(req.position)
	
	disk_circle.processing_list = request_positions
	disk_circle.current_request = current_request
	disk_circle.update_speed(pointer_speed)


func _process(delta: float) -> void:
	var velocity: float = pointer_speed * delta
	
	if pointer_destination - pointer_pos < 0:
		velocity *= -1
	
	if abs(pointer_pos - pointer_destination) <= velocity:
		pointer_pos = pointer_destination
	else:
		pointer_pos = clamp(pointer_pos + velocity, 0, 200)
	set_pointer_position(round(pointer_pos))
	
	if round(abs(pointer_pos - pointer_destination) * 100) / 100.0 < 1:
		set_process(false)
		move_finished.emit()
