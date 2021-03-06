class_name EnemyController extends EntityController


func update() -> void:
	var from = self.position
	var offset = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT][randi() % 4]
	var length = randi() % 3

	self.position += offset * length

	self.emit_signal("move", from, self.position)
