class_name Dungeon extends Node2D

const ROOM_COUNT = [2, 15, 20, 30, 1] # Amount of rooms

#Used tiles
enum Tile {Wall, Exit, Floor, Corner, Background, Door, Error}


# Var for this level
var level_number = 0
var map = []
var room_buffer = []
var rooms = []
var room_count
var level_size
var walls: Array
var exit: Vector2

# Nodes
onready var tile_map = $TileMap
onready var rooms_script = $Rooms

# Draws the level
func draw_level():
	rooms.clear()
	tile_map.clear()

	room_count = ROOM_COUNT[level_number]
	level_size = Vector2(room_count * 40, room_count * 24) # Fix this so it's not hard coded
	for x in range(level_size.x):
		map.append([])
		for y in range(level_size.y):
			map[x].append(Tile.Background)
			tile_map.set_cell(x, y, Tile.Background)

	var free_regions = [Rect2(Vector2(2, 2), level_size - Vector2(4, 4))]
	for i in range(room_count):
		draw_room(free_regions, i == 0)
		if free_regions.empty():
			break
	draw_exit()
	draw_path()

# Draws all the rooms in the level 18x32-room size 24x38 to have 3 clear rows on each side?
func draw_room(free_regions, spawn_player: bool):
	var region = free_regions[randi() % free_regions.size()]

	room_buffer = rooms_script.get_room_tiles()
	var size_x = room_buffer[0].size()
	var size_y = room_buffer.size()

	var start_x = region.position.x
	if region.size.x > size_x:
		start_x += randi() % int(region.size.x - size_x)

	var start_y = region.position.y
	if region.size.y > size_y:
		start_y += randi() % int(region.size.y - size_y)

	var room = Rect2(start_x, start_y, size_x, size_y)
	rooms.append(room)

	# decide for random door placement
	var door_check = 0
	while(door_check < 1):
		var r_y = randi() % int(room_buffer.size())
		var r_x = randi() % int(room_buffer[0].size())
		if(room_buffer[r_y][r_x] == "N" || room_buffer[r_y][r_x] == "E" || room_buffer[r_y][r_x] == "W" || room_buffer[r_y][r_x] == "S"):
			room_buffer[r_y][r_x] = "D"
			door_check += 1

	# get tile-information from the room_buffer and set the tiles at the right spot.
	for y in range(room_buffer.size()):
		for x in range(room_buffer[y - 1].size()):
			if(room_buffer[y][x] == "N" || room_buffer[y][x] == "E" || room_buffer[y][x] == "W" || room_buffer[y][x] == "S"):
				tile_map.set_cell(start_x + x, start_y + y, Tile.Wall)
			elif(room_buffer[y][x] == "F"):
				tile_map.set_cell(start_x + x, start_y + y, Tile.Floor)
			elif(room_buffer[y][x] == "NE" || room_buffer[y][x] == "NW" || room_buffer[y][x] == "SW" || room_buffer[y][x] == "SE"):
				tile_map.set_cell(start_x + x, start_y + y, Tile.Corner)
			elif(room_buffer[y][x] == "D"):
				tile_map.set_cell(start_x + x, start_y + y, Tile.Door)
			elif(room_buffer[y][x] == "P"):
				if spawn_player:
					self.emit_signal("spawn_player", Vector2(start_x + x, start_y + y))
				tile_map.set_cell(start_x + x, start_y + y, Tile.Floor)
			elif(room_buffer[y][x] == "M"):
				self.emit_signal("spawn_enemy", Vector2(start_x + x, start_y + y))
				tile_map.set_cell(start_x + x, start_y + y, Tile.Floor)
			elif(room_buffer[y][x] == 'G'):
				self.emit_signal("spawn_pick_up", Vector2(start_x + x, start_y + y))
				tile_map.set_cell(start_x + x, start_y + y, Tile.Floor)
			else:
				# error tile so we can figure out if we missed something
				tile_map.set_cell(start_x + x, start_y + y, Tile.Error)

	# split up the remaining free areas
	cut_regions(free_regions, room)

# inspired by https://github.com/Thoughtquake/dungeon-of-recycling/blob/main/Game.gd
# using this just to see if/how it works
func cut_regions(free_regions, region_to_cut):
	var removal_queue = []
	var addition_queue = []

	for region in free_regions:
		if(region.intersects(region_to_cut)):
			removal_queue.append(region)

			var leftover_left = region_to_cut.position.x - region.position.x - 1
			var leftover_right = region.end.x - region_to_cut.end.x - 1
			var leftover_above = region_to_cut.position.y - region.position.y - 1
			var leftover_below = region.end.y - region_to_cut.end.y - 1

			# Check if there is enough room for a new free region around the newly placed room
			if(leftover_left >= room_buffer[1].size()):
				addition_queue.append(Rect2(region.position, Vector2(leftover_left, region.size.y)))
			if(leftover_right >= room_buffer[1].size()):
				addition_queue.append(Rect2(Vector2(region_to_cut.end.x + 1, region.position.y), Vector2(leftover_right, region.size.y)))
			if(leftover_above >= room_buffer[0].size()):
				addition_queue.append(Rect2(region.position, Vector2(region.size.x, leftover_above)))
			if(leftover_below >= room_buffer[0].size()):
				addition_queue.append(Rect2(Vector2(region.position.x, region_to_cut.end.y + 1), Vector2(region.size.x, leftover_below)))

	for region in removal_queue:
		free_regions.erase(region)

	for region in addition_queue:
		free_regions.append(region)

# Draws the exit randomly on any wall in the level
func draw_exit():
	walls = tile_map.get_used_cells_by_id(0)
	if(walls.size() != 0):
		var random = randi() % walls.size()
		exit = walls[random]
		tile_map.set_cellv(exit, Tile.Exit)

func draw_path():
	# graphing all the door tiles
	var door_graph = AStar2D.new()
	var doors = tile_map.get_used_cells_by_id(5)
			# update here so i'm able to get the id directly from the tile
	var i = 1
	for door in doors:
		door_graph.add_point(i, door, 1.0)
		i += 1
	# graping all the ground tiles
	var ground_graph = AStar2D.new()
	var ground = tile_map.get_used_cells_by_id(4)
			# update here so i'm able to get the id directly from the tile
	var j = 1
	for tile in ground:
		ground_graph.add_point(j, tile, 1.0)
		j += 1
		
	connect_points(ground_graph, ground)
	

	for tile in doors:
		var path = connect_path(ground_graph, door_graph, doors)
		if(path != null):
			for position_array in path:
					for position in position_array:
						tile_map.set_cellv(ground_graph.get_point_position(position), Tile.Error)

func connect_points(astar, tile_map_connect):
	var i = 0
	for tile in tile_map_connect:
		# update here so i'm able to get the id directly from the tile
		var point_id = i
		var point_coord = astar.get_point_position(point_id)
		i += 1
		for x in range(-1,1):
			for y in range(-1,1):
				var target_coord = point_coord + Vector2(x, y)
				var target_id = get_id(target_coord, tile_map_connect)
				
				if(point_coord == target_coord or target_id == -1):
					continue
					
				astar.connect_points(point_id, target_id, true)
				
func get_id(point_coord, tile_map_buffer):
	var i = 0
	for tile in tile_map_buffer:
		if(point_coord == tile):
			return i
		i += 1
	return -1
				
func connect_path(astar, tile_map_doors, doors):
	var buffer_path = []
	for door in doors:
		var buffer_start_point = astar.get_closest_point(door)
		var buffer_end_point = tile_map_doors.get_closest_point(door)
		buffer_end_point = astar.get_closest_point(astar.get_point_position(buffer_end_point))
		var buffer_buffer = astar.get_id_path(buffer_start_point, buffer_end_point)
		if(buffer_buffer != null):
			buffer_path.append(buffer_buffer)
	return buffer_path

# Called when the node enters the scene tree for the first time.
func initialize():
	draw_level()
	populate_traversable()

	self.emit_signal("load_complete")


signal load_complete()
signal spawn_enemy(position)
signal spawn_pick_up(position)
signal spawn_player(position)

onready var traversable: TileMap = $traversable

func populate_traversable() -> void:
	for tile in self.tile_map.get_used_cells_by_id(2):
		self.traversable.set_cellv(tile, 0)


func get_traversable() -> TileMap:
	return self.traversable


func get_room_for_entity(entity: EntityController) -> Rect2:
	for room in rooms:
		if room.has_point(entity.position):
			return room

	return Rect2(0.0, 0.0, 0.0, 0.0)

