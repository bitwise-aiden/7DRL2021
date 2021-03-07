class_name EnemyController extends EntityController


const OFFSETS = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT
]


var next_offset: Vector2 = Vector2.ZERO


# Public functions
func telegraph(player: PlayerController, ray: RayCast2D) -> void:
	if self._has_line_of_sight(player, ray):
		var direction: Vector2 = self.position.direction_to(player.position)
		if direction in self.OFFSETS:
			self.next_offset = direction * 3.0
			var next_position: Vector2 = self.position + self.next_offset
			self.emit_signal("telegraph", self.position, self.next_offset)

		# update the known player position
		# figure out how it moves there.
	else:
		# if has last position, move there
		pass


func update() -> void:
	var from = self.position

	if self.next_offset.length():
		self.position += self.next_offset
		self.next_offset = Vector2.ZERO
	else:
		self.position += self.OFFSETS[randi() % 4]

	self.emit_signal("move", from, self.position)


# Protectecd methods
func _has_line_of_sight(player: PlayerController, ray: RayCast2D) -> bool:
	var position_enemy: Vector2 = w2s(self.position)
	var position_player: Vector2 = w2s(player.position)
	var direction_to_player: Vector2 = position_player - position_enemy

	ray.position = position_enemy
	ray.cast_to = direction_to_player

	return !ray.is_colliding()
