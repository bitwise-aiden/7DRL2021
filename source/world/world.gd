class_name WorldController extends Node2D


const DAMAGE_ENEMY = 1
const DAMAGE_PLAYER = 1
const HEALTH_ENEMY = 1
const HEALTH_PLAYER = 3

onready var __camera: Camera2D = $camera
onready var __dungeon: Dungeon = $dungeon
onready var __entities_map: TileMap = $entities
onready var __ray: RayCast2D = $line_of_sight

var __can_update: bool = false
var __enemies: Array = []
var __entities: Array = []
var __player: PlayerController = null
var __world_interface: WorldInterface = null


# Lifecycle method
func _ready() -> void:
	randomize()

	self.__dungeon.connect("load_complete", self, "__dungeon_complete")
	self.__dungeon.connect("spawn_enemy", self, "__spawn_enemy")
	self.__dungeon.connect("spawn_pick_up", self, "__spawn_pick_up")
	self.__dungeon.connect("spawn_player", self, "__spawn_player")

	self.__dungeon.initialize()


func _process(_delta: float) -> void:
	if !self.__can_update:
		return

	self.__player.update()


# Private methods
func __center_camera_on_entity(entity: EntityController, pan: bool = false) -> void:
	var room: Rect2 = self.__dungeon.get_room_for_entity(entity)
	if room.size.length() == 0:
		self.__center_camera_on_position(entity.position, pan)
	else:
		self.__center_camera_on_room(room, pan)


func __center_camera_on_position(position: Vector2, pan: bool = false) -> void:
	self.__camera.offset = self.__world_interface.w2s(position)


func __center_camera_on_room(room: Rect2, pan: bool = false) -> void:
	if room.size.length() == 0:
		return

	var room_center = room.position + room.size * 0.5
	self.__center_camera_on_position(room_center, pan)


func __dungeon_complete() -> void:
	self.__world_interface = WorldInterface.new(
		self.__ray,
		self.__dungeon.get_traversable(),
		self.__entities
	)

	self.__can_update = true

	self.__center_camera_on_entity(self.__player, false)


func __entity_move(from: Vector2, to: Vector2, entity: EntityController) -> Vector2:
	var last_position: Vector2 = from
	var direction = to - from
	var distance = direction.length()

	for i in distance:
		var offset = direction.normalized() * (1 + i)

		yield(self.get_tree().create_timer(0.1), "timeout")

		if !self.__world_interface.can_traverse(entity, from + offset):
			break

		self.__entities_map.set_cellv(last_position, TileMap.INVALID_CELL)
		last_position = from + offset
		self.__entities_map.set_cellv(last_position, 0)

	if last_position != to:
		entity.position = last_position

	return last_position


func __player_move(from: Vector2, to: Vector2, entity: EntityController) -> void:
	self.__can_update = false

	var position_player: Vector2 = yield(
		self.__entity_move(from, to, entity),
		"completed"
	)

	self.__center_camera_on_entity(entity)

	for enemy in self.__enemies:
		enemy.update()
		enemy.telegraph(entity, self.__world_interface)

	self.__can_update = true


func __spawn_enemy(position: Vector2) -> void:
	var enemy = EnemyController.new()
	enemy.initialize(position, self.HEALTH_ENEMY, self.DAMAGE_ENEMY)
	enemy.connect("move", self, "__entity_move", [enemy])

	self.__entities_map.set_cellv(position, 0)
	self.__entities.append(enemy)

	self.__enemies.append(enemy)


func __spawn_pick_up(position: Vector2) -> void:
	var pick_up = PickUpController.new()
	pick_up.initialize(position)

	self.__entities_map.set_cellv(position, 1)
	self.__entities.append(pick_up)


func __spawn_player(position: Vector2) -> void:
	if self.__player != null:
		Logger.warn("Player already spawned")
		return

	self.__player = PlayerController.new()
	self.__player.initialize(position, self.HEALTH_PLAYER, self.DAMAGE_PLAYER)
	self.__player.connect("move", self, "__player_move", [self.__player])

	self.__entities_map.set_cellv(position, 0)
	self.__entities.append(self.__player)
