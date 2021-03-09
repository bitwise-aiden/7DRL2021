class_name PickUpController extends EntityController


var type: int = PickUp.Type.MAX


# Public methods
func handle_collision(entity: EntityController) -> bool:
	if entity is PlayerController:
		entity.pick_up(self.type)
		self.alive = false
		return false

	return true


# Protected methods
func _initialize() -> void:
	self.type = randi() % PickUp.Type.MAX