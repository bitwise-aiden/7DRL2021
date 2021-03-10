class_name ProjectileController extends EntityController

var direction: Vector2 = Vector2.ZERO
var speed: int = 1


func _init(position: Vector2, options: Dictionary = {}).(position, options) -> void:
	self.direction = options.get('direction', self.direction)
	self.speed = options.get('speed', self.speed)


func update() -> void:
	var from: Vector2 = self.position
	self.position += self.direction * self.speed

	self.emit_signal("move", from, self.position)
