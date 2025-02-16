extends Node

@onready var player: CharacterBody2D = $".."

@onready var coyote_disabled: Sprite2D = $CoyoteDisabled
@onready var coyote_enabled: Sprite2D = $CoyoteEnabled

func _ready():
	player.can_coyote_jump_changed.connect(on_can_coyote_jump_changed)

func on_can_coyote_jump_changed(newValue):
	coyote_enabled.visible = newValue
	coyote_disabled.visible = !newValue
