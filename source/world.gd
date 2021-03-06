class_name WorldController extends Node


onready var layer_entities: TileMap = $entities
onready var layer_world: TileMap = $world


var player: PlayerController = null
var enemies: Array = []


# Lifecycle method
func _ready() -> void:
	randomize()

	self.player = PlayerController.new()
	self.player.initialize(Vector2(27.0, 19.0))
	self.player.connect("move", self, "__player_move")

	for i in 4:
		var enemy = EnemyController.new()
		enemy.position = Vector2(randi() % 1280/16, randi() % 720 / 16)
		enemy.connect("move", self, "__entity_move", [enemy])

		self.enemies.append(enemy)


func _process(delta: float) -> void:
	self.player.update()


# Private methods
func __player_move(from: Vector2, to: Vector2) -> void:
	self.__entity_move(from, to, self.player)

	for enemy in self.enemies:
		enemy.update()


func __entity_move(from: Vector2, to: Vector2, entity: EntityController) -> void:
	var last_valid: Vector2 = from
	var direction = to - from
	var distance = direction.length()

	for i in distance:
		var offset = direction.normalized() * (1 + i)

		if self.layer_world.get_cellv(from + offset) != TileMap.INVALID_CELL:
			break

		last_valid = from + offset

	if last_valid != to:
		entity.position = last_valid

	self.layer_entities.set_cellv(from, TileMap.INVALID_CELL)
	self.layer_entities.set_cellv(last_valid, 0)
