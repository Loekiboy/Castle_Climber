extends Node2D

var current_height = 0
var chunk_size = 20
var tile_size = 128

@onready var player = $Player
@onready var tilemap_layer = $TileMapLayer
@onready var decorations = $Decorations
@onready var fans_container = $Fans

var fan_scene = preload("res://fan.tscn")

func _ready():
	generate_next_chunk()

func generate_next_chunk():
	for i in range(chunk_size):
		var y = current_height - i

		# 1. kasteel
		for x in range(-10, 11):
			tilemap_layer.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))

		# 2. ramen en fakels
		var decor_pool = [2, 2, 2, 3, 3, 3, 4, 5]
		var number_of_windows = randi_range(3, 6)
		for j in range(number_of_windows):
			var decoration_index = decor_pool.pick_random()
			var random_x = randi_range(-10, 10)
			decorations.set_cell(Vector2i(random_x, y), 0, Vector2i(decoration_index, 0))

		# 3. ventilators
		if randf() < 0.15:
			var fan = fan_scene.instantiate()
			fan.position = Vector2(randi_range(-10, 10) * tile_size, y * tile_size)
			var rotator = fan.get_node("Rotator")
			if rotator:
				rotator.rotation_degrees = randf_range(-180, 0)
			fans_container.add_child(fan)

	current_height -= chunk_size

func _process(_delta):
	var player_tile_y = player.position.y / tile_size
	if player_tile_y < current_height + 15:
		generate_next_chunk()
