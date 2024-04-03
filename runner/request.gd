extends Object
class_name Request

var wait_time: int = 0
var position: int = 0

var real_time: bool
var deadline: int


func _init(position: int, real_time:=false, deadline:=0) -> void:
	self.position = position
	self.real_time = real_time
	self.deadline = deadline


func wait(time: int) -> void:
	wait_time += time
	
	if real_time:
		deadline -= time
