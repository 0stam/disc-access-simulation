extends Label


func _avg_wait_changed(runner_name: String, avg_wait: float) -> void:
	text = runner_name + str(avg_wait)
