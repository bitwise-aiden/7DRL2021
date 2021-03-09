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
func initialize(position: Vector2, health_max: int = 1, damage: int = 1) -> void:
	self.damage = damage
	self.health_max = health_max
	self.health = health_max
	self.position = position

	self._initialize()


func handle_collision(_entity: EntityController) -> bool:
	return true


func is_alive() -> bool:
	return self.alive


func update() -> void:
	pass


# Protected methods
func _initialize() -> void:
	pass
