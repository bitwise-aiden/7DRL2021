class_name EntityController


signal move(from, to)


var alive: bool = true
var position: Vector2 = Vector2.ZERO


# Public methods
func initialize(position: Vector2) -> void:
	self.position = position


func is_alive() -> bool:
	return self.alive


func update() -> void:
	pass
