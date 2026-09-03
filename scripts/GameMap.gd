extends Node2D

@export var map_radius: int = 8
@export var hex_size: float = 32.0

var hex_tile_scene = preload("res://scenes/HexTile.tscn")
var tiles = {}

func _ready():
    generate_map()
    print("Phase 1 Kernel: Hex map generated with ", tiles.size(), " tiles")

func generate_map():
    for q in range(-map_radius, map_radius + 1):
        for r in range(max(-map_radius, -q - map_radius), min(map_radius, -q + map_radius) + 1):
            var tile = hex_tile_scene.instantiate()
            tile.q = q
            tile.r = r
            tile.position = hex_to_pixel(q, r)
            tile.terrain_type = get_terrain_type(q, r)
            $Tiles.add_child(tile)
            tiles[Vector2i(q, r)] = tile

func hex_to_pixel(q: int, r: int) -> Vector2:
    var x = hex_size * (3.0/2.0 * q)
    var y = hex_size * (sqrt(3.0)/2.0 * q + sqrt(3.0) * r)
    return Vector2(x, y)

func get_terrain_type(q: int, r: int) -> String:
    var dist = max(abs(q), abs(r), abs(-q-r))
    if dist > map_radius - 2:
        return "caves"
    elif (q + r) % 3 == 0:
        return "urban"
    else:
        return "forest"

func get_tile(q: int, r: int):
    return tiles.get(Vector2i(q, r))