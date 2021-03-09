class_name BaseTask


var _completed: bool = false


# Public methods
func is_completed() -> bool:
	return self._completed


func update(_delta: float) -> void:
	self._completed = true
