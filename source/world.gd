class_name WorldController extends Node


onready var layer_entities: TileMap = $entities
onready var layer_world: TileMap = $navigation/world
onready var line_of_sight: RayCast2D = $line_of_sight
onready var navigation: Navigation2D = $navigation

var player: PlayerController = null
var enemies: Array = []


# Lifecycle method
func _ready() -> void:
	randomize()

	self.player = PlayerController.new()
	self.player.initialize(Vector2(27.0, 19.0))
	self.player.connect("move", self, "__player_move")

	for i in 1:
		var enemy = EnemyController.new()
#		enemy.position = Vector2(randi() % 1280/16, randi() % 720 / 16)
		enemy.position = Vector2(27.0, 21.0)
		enemy.connect("move", self, "__entity_move", [enemy])
		enemy.connect("debug", $debug_line, "set_points")
		Line2D

		self.enemies.append(enemy)


func _process(delta: float) -> void:
	self.player.update()


# Private methods
func __player_move(from: Vector2, to: Vector2) -> void:
	var position_player: Vector2 = self.__entity_move(from, to, self.player)

	for enemy in self.enemies:
		enemy.update()
		enemy.telegraph(player, self.line_of_sight, self.navigation)


func __entity_move(from: Vector2, to: Vector2, entity: EntityController) -> Vector2:
	var last_position: Vector2 = from
	var direction = to - from
	var distance = direction.length()

	for i in distance:
		var offset = direction.normalized() * (1 + i)

		if self.layer_world.get_cellv(from + offset) != 6:
			break

		last_position = from + offset

	if last_position != to:
		entity.position = last_position

	self.layer_entities.set_cellv(from, 6)
	self.layer_entities.set_cellv(last_position, 0)

	return last_position
