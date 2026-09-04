extends Node2D

@export var unit_name: String = "Warden"
@export var strength: int = 3
@export var movement_range: int = 2
@export var owner_faction: String = "White Council"
@export var ability: String = ""  # e.g. "veil", "psychic_drain", "frost_slow"

var current_q: int = 0
var current_r: int = 0
var is_selected: bool = false

func _ready():
    update_visual()

func update_visual():
    var rect = $ColorRect
    if owner_faction == "White Council":
        rect.color = Color(0.2, 0.4, 0.8)
    elif owner_faction == "Grey Council":
        rect.color = Color(0.3, 0.3, 0.5)
    elif owner_faction == "White Court":
        rect.color = Color(0.8, 0.2, 0.5)
    elif owner_faction == "Winter Court":
        rect.color = Color(0.4, 0.7, 0.9)  # Icy blue
    elif owner_faction == "Summer Court":
        rect.color = Color(0.2, 0.7, 0.3)  # Green
    elif owner_faction == "Red Court":
        rect.color = Color(0.7, 0.1, 0.1)  # Blood red
    elif owner_faction == "Denarians":
        rect.color = Color(0.6, 0.6, 0.7)  # Silver-gray
    elif owner_faction == "Knights of the Cross":
        rect.color = Color(0.9, 0.8, 0.2)  # Gold
    else:
        rect.color = Color(0.5, 0.5, 0.5)

func select():
    is_selected = true
    modulate = Color(1.5, 1.5, 1.5)

func deselect():
    is_selected = false
    modulate = Color(1, 1, 1)

func move_to(new_q: int, new_r: int, map):
    current_q = new_q
    current_r = new_r
    position = map.hex_to_pixel(new_q, new_r)