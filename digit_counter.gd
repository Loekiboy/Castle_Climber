extends HBoxContainer

@export var tilesheet: Texture2D
@export var char_width: int = 64
@export var char_height: int = 64
@export var separation: int = -4

var current_frame: int = 0
var animation_timer: float = 0.0
var last_text: String = ""
var last_frame: int = -1

const CHAR_ORDER = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", ".", "m"]
const CHAR_WIDTHS = {
	"1": 40, "2": 42, "3": 42, "4": 42, "5": 48,
	"6": 50, "7": 44, "8": 48, "9": 48, "0": 52,
	".": 18, "m": 58
}

func _ready() -> void:
	add_theme_constant_override("separation", separation)

func _process(delta: float) -> void:
	animation_timer += delta
	if animation_timer >= 0.2:
		animation_timer = 0.0
		current_frame = 1 if current_frame == 0 else 0
		
	var player = %Player if has_node("%Player") else $"../../Player"
	if player:
		var huidige_hoogte = (round(-player.global_position.y) + 406) / 100
		var huidige_text = "%0.2f" % [huidige_hoogte] + "m"
		
		if huidige_text != last_text or current_frame != last_frame:
			last_text = huidige_text
			last_frame = current_frame
			update_counter_display(huidige_text)

func update_counter_display(text: String) -> void:
	for child in get_children():
		child.queue_free()
		
	for char in text:
		var index = CHAR_ORDER.find(char)
		if index == -1:
			continue
			
		var target_width = CHAR_WIDTHS.get(char, char_width)
		var offset_x = (char_width - target_width) / 2
		
		var frame_index = (index * 2) + current_frame
		var pixel_x = (frame_index * char_width) + offset_x
		
		var atlas_tex = AtlasTexture.new()
		atlas_tex.atlas = tilesheet
		atlas_tex.region = Rect2(pixel_x, 0, target_width, char_height)
		
		var tex_rect = TextureRect.new()
		tex_rect.texture = atlas_tex
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		
		add_child(tex_rect)
