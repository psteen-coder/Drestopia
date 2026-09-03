extends Node2D

@export var city_name: String = "New Haven"
@export var energy_production: int = 2
@export var knowledge_production: int = 1
@export var owner_faction: String = "White Council"

var current_q: int = 0
var current_r: int = 0

func _ready():
    update_label()

func update_label():
    if has_node("Label"):
        $Label.text = city_name + "\nE:" + str(energy_production) + " K:" + str(knowledge_production)