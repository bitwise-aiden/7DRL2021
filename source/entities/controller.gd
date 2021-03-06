class_name EntityController


signal move(from, to)
signal debug(content)


var alive: bool = true
var position: Vector2 = Vector2.ZERO


# Public methods
func initialize(position: Vector2) -> void:
	self.position = position


func is_alive() -> bool:
	return self.alive


func update() -> void:
	pass


# Helper functions

# w2s: Converts the Vector2 from world space to screen space
func s2w(value: Vector2) -> Vector2:
	return (value - Vector2(8.0, 8.0)) / 16.0


func w2s(value: Vector2) -> Vector2:
	return value * 16.0 + Vector2(8.0, 8.0)
