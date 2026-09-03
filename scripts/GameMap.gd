extends Node2D

@export var map_radius: int = 8
@export var hex_size: float = 32.0

var hex_tile_scene = preload("res://scenes/HexTile.tscn")
var unit_scene = preload("res://scenes/Unit.tscn")
var city_scene = preload("res://scenes/City.tscn")
var tiles = {}
var units = []
var cities = []
var selected_unit = null
var current_turn: int = 1
var is_player_turn: bool = true

signal turn_changed(turn_number)

func _ready():
    generate_map()
    spawn_starting_units()
    print("Phase 2 Factions: All core factions represented")
    turn_changed.emit(current_turn)

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

func spawn_starting_units():
    # White Council
    spawn_unit(0, 0, "Warden", 3, 2, "White Council", "")
    spawn_unit(1, -1, "Wizard", 2, 2, "White Council", "")
    
    # Grey Council
    spawn_unit(3, 0, "Saboteur", 2, 3, "Grey Council", "veil")
    
    # White Court
    spawn_unit(-2, 1, "Psychic Vampire", 2, 2, "White Court", "psychic_drain")
    
    # Winter Court
    spawn_unit(0, 3, "Frost Sidhe", 3, 2, "Winter Court", "frost_slow")
    
    # Summer Court
    spawn_unit(-3, 2, "Dryad", 2, 3, "Summer Court", "nature_growth")
    
    # Red Court
    spawn_unit(4, -1, "Red Court Infected", 4, 1, "Red Court", "blood_drain")

func spawn_unit(q, r, name, strength, movement, faction, ability):
    var unit = unit_scene.instantiate()
    unit.current_q = q
    unit.current_r = r
    unit.position = hex_to_pixel(q, r)
    unit.unit_name = name
    unit.strength = strength
    unit.movement_range = movement
    unit.owner_faction = faction
    unit.ability = ability
    $Units.add_child(unit)
    units.append(unit)

func _input(event):
    if event is InputEventMouseButton and event.pressed:
        var mouse_pos = get_global_mouse_position()
        var closest = get_closest_tile(mouse_pos)
        if closest and is_player_turn:
            if event.button_index == MOUSE_BUTTON_LEFT:
                handle_click_on_tile(closest.q, closest.r)
            elif event.button_index == MOUSE_BUTTON_RIGHT:
                found_city_at(closest.q, closest.r)

func get_closest_tile(mouse_pos: Vector2):
    var closest = null
    var min_dist = 9999
    for tile_pos in tiles.keys():
        var tile = tiles[tile_pos]
        var dist = tile.position.distance_to(mouse_pos)
        if dist < min_dist and dist < hex_size * 0.8:
            min_dist = dist
            closest = tile
    return closest

func handle_click_on_tile(q: int, r: int):
    if selected_unit == null:
        for unit in units:
            if unit.current_q == q and unit.current_r == r:
                select_unit(unit)
                return
    else:
        move_selected_unit(q, r)

func select_unit(unit):
    if selected_unit:
        selected_unit.deselect()
    selected_unit = unit
    unit.select()

func move_selected_unit(target_q: int, target_r: int):
    if selected_unit == null:
        return
    var dist = max(abs(target_q - selected_unit.current_q), abs(target_r - selected_unit.current_r))
    if dist <= selected_unit.movement_range:
        var enemy = get_unit_at(target_q, target_r)
        if enemy:
            resolve_combat(selected_unit, enemy)
        else:
            selected_unit.move_to(target_q, target_r, self)
        selected_unit.deselect()
        selected_unit = null
    else:
        print("Too far to move")

func get_unit_at(q: int, r: int):
    for unit in units:
        if unit.current_q == q and unit.current_r == r:
            return unit
    return null

func resolve_combat(attacker, defender):
    print(attacker.unit_name, " attacks ", defender.unit_name)
    var attack_power = attacker.strength
    
    if attacker.ability == "psychic_drain":
        attack_power += 1
    if attacker.ability == "frost_slow":
        defender.movement_range = max(1, defender.movement_range - 1)
    
    if attack_power > defender.strength:
        defender.queue_free()
        units.erase(defender)
        attacker.move_to(defender.current_q, defender.current_r, self)
        print("Attacker wins!")
    else:
        attacker.queue_free()
        units.erase(attacker)
        print("Defender wins!")

func found_city_at(q: int, r: int):
    if get_unit_at(q, r) or get_city_at(q, r):
        print("Cannot found city here")
        return
    var city = city_scene.instantiate()
    city.current_q = q
    city.current_r = r
    city.position = hex_to_pixel(q, r)
    city.owner_faction = "White Council"
    $Cities.add_child(city)
    cities.append(city)
    print("City founded at ", q, ",", r)

func get_city_at(q: int, r: int):
    for city in cities:
        if city.current_q == q and city.current_r == r:
            return city
    return null

func end_turn():
    if is_player_turn:
        is_player_turn = false
        current_turn += 1
        print("Turn ", current_turn, " started")
        turn_changed.emit(current_turn)
        await get_tree().create_timer(0.8).timeout
        is_player_turn = true
        print("Player turn")