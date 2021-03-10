class_name EntityController


signal move(from, to)
signal remove()
signal telegraph(from, to)
signal debug(content)


var alive: bool = true
var damage: int = 1
var health: int = 1
var health_max: int = 1
var position: Vector2 = Vector2.ZERO


# Public methods
func _init(position: Vector2, options: Dictionary = {}) -> void:
	self.damage = options.get('damage', self.damage)
	self.health_max = options.get('health', self.health_max)
	self.health = self.health_max
	self.position = position


func handle_collision(_entity: EntityController) -> bool:
	return true


func is_alive() -> bool:
	return self.alive


func update() -> void:
	pass
