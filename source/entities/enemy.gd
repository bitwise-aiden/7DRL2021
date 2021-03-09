class_name EnemyController extends EntityController


# Public functions
func handle_collision(entity: EntityController) -> bool:
	if entity is PlayerController:
		self.emit_signal("remove")

	return true


func telegraph(_player: PlayerController, _world: WorldInterface) -> void:
	pass


func update() -> void:
	pass
