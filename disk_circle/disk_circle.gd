extends ColorRect
class_name DiskCircle

@export var processing_list: Array[int]:
	set(value):
		processing_list = value
		self.current_request = current_request
		update_image()

@export var current_request: int:
	set(value):
		current_request = value
		if processing_list and value:
			processing_list.insert(0, processing_list.pop_at(current_request))
			current_request = 0
		update_image()

var image: Image


func _init(processing_list: Array[int]=[], current_request: int=0) -> void:
	material = material.duplicate()
	
	image = Image.create(200, 1, false, Image.FORMAT_RGB8)
	self.processing_list = processing_list
	self.current_request = current_request
	update_image()


func update_image() -> void:
	for i in 200:
		image.set_pixel(i, 0, Color.BLACK)
	
	var hue: float = 0
	var hue_shift: float = 0.8 / len(processing_list)
	
	
	for i in len(processing_list):
		var color: Color
		if i == 0 or processing_list[0] == processing_list[i]:
			color = Color.from_hsv(0, 1, 1)
		else:
			color = Color.from_hsv(hue, 1, 0.6)
		
		image.set_pixel(processing_list[i], 0, color)
		
		hue += hue_shift
	
	var shader: ShaderMaterial = material
	shader.set_shader_parameter("values", ImageTexture.create_from_image(image))
