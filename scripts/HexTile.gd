extends Node2D

@export var terrain_type: String = "forest"  # forest, caves, urban
@export var q: int = 0
@export var r: int = 0

func _ready():
    update_appearance()

func update_appearance():
    var rect = $ColorRect
    match terrain_type:
        "forest":
            rect.color = Color(0.2, 0.6, 0.3, 1)
        "caves":
            rect.color = Color(0.4, 0.3, 0.2, 1)
        "urban":
            rect.color = Color(0.5, 0.5, 0.6, 1)
        _:
            rect.color = Color(0.3, 0.3, 0.3, 1)