class_name WorldController extends Node2D


onready var __dungeon: Dungeon = $dungeon
onready var __entities: TileMap = $entities
onready var __ray: RayCast2D = $line_of_sight

var __can_update: bool = false
var __enemies: Array = []
var __player: PlayerController = null
var __world_interface: WorldInterface = null


# Lifecycle method
func _ready() -> void:
	randomize()

	self.__dungeon.connect("load_complete", self, "__dungeon_complete")
	self.__dungeon.connect("spawn_enemy", self, "__spawn_enemy")
	self.__dungeon.connect("spawn_player", self, "__spawn_player")

	self.__dungeon.initialize()


func _process(delta: float) -> void:
	if !self.__can_update:
		return

	self.__player.update()


# Private methods
func __dungeon_complete() -> void:
	self.__world_interface = WorldInterface.new(
		$line_of_sight,
		$dungeon.get_traversable()
	)

	self.__can_update = true


func __entity_move(from: Vector2, to: Vector2, entity: EntityController) -> Vector2:
	var last_position: Vector2 = from
	var direction = to - from
	var distance = direction.length()

	for i in distance:
		var offset = direction.normalized() * (1 + i)

		yield(self.get_tree().create_timer(0.1), "timeout")

		if !self.__world_interface.is_traversable(from + offset):
			break

		self.__entities.set_cellv(last_position, TileMap.INVALID_CELL)
		last_position = from + offset
		self.__entities.set_cellv(last_position, 0)

	if last_position != to:
		entity.position = last_position

	return last_position


func __player_move(from: Vector2, to: Vector2, entity: EntityController) -> void:
	self.__can_update = false

	var position_player: Vector2 = yield(
		self.__entity_move(from, to, entity),
		"completed"
	)

	for enemy in self.__enemies:
		enemy.update()
		enemy.telegraph(entity, self.__world_interface)

	self.__can_update = true


func __spawn_enemy(position: Vector2) -> void:
	var enemy = EnemyController.new()
	enemy.initialize(position)
	enemy.connect("move", self, "__entity_move", [enemy])

	self.__entities.set_cellv(position, 0)

	self.__enemies.append(enemy)


func __spawn_player(position: Vector2) -> void:
	print(self.__player, position)

	if self.__player != null:
		Logger.warn("Player already spawned")
		return

	self.__player = PlayerController.new()
	self.__player.initialize(position)
	self.__player.connect("move", self, "__player_move", [self.__player])

	self.__entities.set_cellv(position, 0)
