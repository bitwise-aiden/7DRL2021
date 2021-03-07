class_name WorldController extends Node


onready var layer_entities: TileMap = $entities
onready var layer_world: TileMap = $world
onready var line_of_sight: RayCast2D = $line_of_sight


var can_update: bool = true
var enemies: Array = []
var player: PlayerController = null


# Lifecycle method
func _ready() -> void:
	randomize()

	self.player = PlayerController.new()
	self.player.initialize(Vector2(27.0, 19.0))
	self.player.connect("move", self, "__player_move")

	var positions = [Vector2(32.0, 21.0), Vector2(23.0, 16.0)]
	for i in 2:
		var enemy = EnemyController.new()
#		enemy.position = Vector2(randi() % 1280/16, randi() % 720 / 16)
		enemy.position = Vector2(27.0, 21.0)
		enemy.connect("move", self, "__entity_move", [enemy])
		enemy.connect("debug", $debug_line, "set_points")
		Line2D

		self.enemies.append(enemy)


func _process(delta: float) -> void:
	if !self.can_update:
		return

	self.player.update()


# Private methods
func __player_move(from: Vector2, to: Vector2) -> void:
	self.can_update = false

	var position_player: Vector2 = yield(
		self.__entity_move(from, to, self.player),
		"completed"
	)

	for enemy in self.enemies:
		enemy.update()
		enemy.telegraph(player, self.line_of_sight)

	self.can_update = true

func __entity_move(from: Vector2, to: Vector2, entity: EntityController) -> Vector2:
	var last_position: Vector2 = from
	var direction = to - from
	var distance = direction.length()

	for i in distance:
		var offset = direction.normalized() * (1 + i)

		yield(self.get_tree().create_timer(0.1), "timeout")

		if self.layer_world.get_cellv(from + offset) != TileMap.INVALID_CELL:
			break

		self.layer_entities.set_cellv(last_position, TileMap.INVALID_CELL)
		last_position = from + offset
		self.layer_entities.set_cellv(last_position, 0)


	if last_position != to:
		entity.position = last_position

	return last_position
