class_name EnemyController extends EntityController

var position_player: Vector2 = Vector2.ZERO


# Public functions
func telegraph(player: PlayerController, ray: RayCast2D, navigation: Navigation2D) -> void:
	if self._has_line_of_sight(player, ray):
		self.position_player = player.position

		# update the known player position
		# figure out how it moves there.
	else:
		# if has last position, move there
		pass

	var path: PoolVector2Array = navigation.get_simple_path(
		self.position * 16,
		self.position_player * 16,
		false
	)

	print(path)
	self.emit_signal("debug", path)


func update() -> void:
	var from = self.position
	var offset = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT][randi() % 4]
	var length = randi() % 3

	self.position += offset * length

	self.emit_signal("move", from, self.position)


# Protectecd methods
func _has_line_of_sight(player: PlayerController, ray: RayCast2D) -> bool:
	var position_enemy: Vector2 = w2s(self.position)
	var position_player: Vector2 = w2s(player.position)
	var direction_to_player: Vector2 = position_player - position_enemy

	ray.position = position_enemy
	ray.cast_to = direction_to_player

	return !ray.is_colliding()
