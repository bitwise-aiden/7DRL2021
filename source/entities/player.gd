class_name PlayerController extends EntityController


const INPUT_MAP = {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
}


# Public methods
func update() -> void:
	for input in self.INPUT_MAP.keys():
		if Input.is_action_just_pressed(input):
			var from = self.position
			self.position += self.INPUT_MAP[input]

			self.emit_signal("move", from, self.position)
			break
