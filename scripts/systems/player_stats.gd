extends Node

# ============================================================================
# PLAYER STATS SYSTEM - AS AVENTURAS DE MIKAEL
# ============================================================================
# Gerencia toda as estatísticas do jogador

class_name PlayerStats

signal health_changed(new_health, max_health)
signal energy_changed(new_energy, max_energy)
signal level_up(new_level)
signal xp_gained(amount, total_xp)
signal coins_gained(amount, total_coins)
signal stats_updated

# Player Data
var player_level: int = Constants.PLAYER_START_LEVEL
var player_xp: int = Constants.PLAYER_START_XP
var player_coins: int = Constants.PLAYER_START_COINS
var player_health: int = Constants.PLAYER_MAX_HEALTH
var player_energy: int = Constants.PLAYER_MAX_ENERGY

# Stats Tracking
var total_computers_repaired: int = 0
var total_phones_repaired: int = 0
var total_enemies_defeated: int = 0
var total_items_collected: int = 0
var regions_visited: Array = []
var completed_missions: Array = []
var unlocked_items: Array = []
var unlocked_achievements: Array = []

# Inventory
var inventory: Dictionary = {}

func _ready():
	load_player_data()

# ============================================================================
# XP SYSTEM
# ============================================================================

func gain_xp(amount: int) -> void:
	player_xp += amount
	emit_signal("xp_gained", amount, player_xp)
	
	# Check for level up
	var next_level_xp = get_xp_for_level(player_level + 1)
	if player_xp >= next_level_xp and player_level < Constants.MAX_LEVEL:
		level_up()

func level_up() -> void:
	player_level += 1
	emit_signal("level_up", player_level)
	
	# Grant level up reward
	if Constants.LEVEL_DATA.has(player_level):
		var reward = Constants.LEVEL_DATA[player_level]["reward_coins"]
		gain_coins(reward)
	
	# Check if new areas should be unlocked
	check_region_unlocks()
	check_vehicle_unlocks()
	
	print("⭐ NÍVEL AUMENTOU! Nível %d" % player_level)

func get_xp_for_level(level: int) -> int:
	if Constants.LEVEL_DATA.has(level):
		return Constants.LEVEL_DATA[level]["xp_required"]
	return 999999

func get_xp_progress() -> float:
	var current_level_xp = get_xp_for_level(player_level)
	var next_level_xp = get_xp_for_level(player_level + 1)
	
	if next_level_xp <= current_level_xp:
		return 1.0
	
	var xp_in_level = player_xp - current_level_xp
	var xp_required = next_level_xp - current_level_xp
	
	return float(xp_in_level) / float(xp_required)

# ============================================================================
# COINS SYSTEM
# ============================================================================

func gain_coins(amount: int) -> void:
	player_coins += amount
	emit_signal("coins_gained", amount, player_coins)
	emit_signal("stats_updated")

func spend_coins(amount: int) -> bool:
	if player_coins >= amount:
		player_coins -= amount
		emit_signal("coins_gained", -amount, player_coins)
		emit_signal("stats_updated")
		return true
	return false

# ============================================================================
# HEALTH SYSTEM
# ============================================================================

func take_damage(damage: int) -> void:
	player_health = max(0, player_health - damage)
	emit_signal("health_changed", player_health, Constants.PLAYER_MAX_HEALTH)
	
	if player_health <= 0:
		on_player_defeated()

func heal(amount: int) -> void:
	player_health = min(Constants.PLAYER_MAX_HEALTH, player_health + amount)
	emit_signal("health_changed", player_health, Constants.PLAYER_MAX_HEALTH)

func restore_full_health() -> void:
	player_health = Constants.PLAYER_MAX_HEALTH
	emit_signal("health_changed", player_health, Constants.PLAYER_MAX_HEALTH)

func is_alive() -> bool:
	return player_health > 0

# ============================================================================
# ENERGY SYSTEM
# ============================================================================

func use_energy(amount: int) -> bool:
	if player_energy >= amount:
		player_energy -= amount
		emit_signal("energy_changed", player_energy, Constants.PLAYER_MAX_ENERGY)
		return true
	return false

func recover_energy(amount: int) -> void:
	player_energy = min(Constants.PLAYER_MAX_ENERGY, player_energy + amount)
	emit_signal("energy_changed", player_energy, Constants.PLAYER_MAX_ENERGY)

func restore_full_energy() -> void:
	player_energy = Constants.PLAYER_MAX_ENERGY
	emit_signal("energy_changed", player_energy, Constants.PLAYER_MAX_ENERGY)

# ============================================================================
# MISSION TRACKING
# ============================================================================

func complete_mission(mission_id: int) -> void:
	if not completed_missions.has(mission_id):
		completed_missions.append(mission_id)
		
		if Constants.MISSIONS.has(mission_id):
			var mission = Constants.MISSIONS[mission_id]
			gain_xp(mission["xp_reward"])
			gain_coins(mission["coins_reward"])
			
			print("✅ Missão %d concluída: %s" % [mission_id, mission["name"]])

func is_mission_completed(mission_id: int) -> bool:
	return completed_missions.has(mission_id)

func get_completed_missions_count() -> int:
	return completed_missions.size()

# ============================================================================
# INVENTORY SYSTEM
# ============================================================================

func add_item(item_id: String, quantity: int = 1) -> void:
	if inventory.has(item_id):
		inventory[item_id] += quantity
	else:
		inventory[item_id] = quantity
	emit_signal("stats_updated")

func remove_item(item_id: String, quantity: int = 1) -> bool:
	if inventory.has(item_id) and inventory[item_id] >= quantity:
		inventory[item_id] -= quantity
		if inventory[item_id] <= 0:
			inventory.erase(item_id)
		emit_signal("stats_updated")
		return true
	return false

func has_item(item_id: String, quantity: int = 1) -> bool:
	return inventory.has(item_id) and inventory[item_id] >= quantity

func get_item_count(item_id: String) -> int:
	return inventory.get(item_id, 0)

# ============================================================================
# REGION TRACKING
# ============================================================================

func visit_region(region_id: String) -> void:
	if not regions_visited.has(region_id):
		regions_visited.append(region_id)
		print("🗺️ Região desbloqueada: %s" % region_id)

func is_region_unlocked(region_id: String) -> bool:
	if not Constants.REGIONS.has(region_id):
		return false
	
	var required_level = Constants.REGIONS[region_id]["unlocked_at_level"]
	return player_level >= required_level

func has_visited_region(region_id: String) -> bool:
	return regions_visited.has(region_id)

func check_region_unlocks() -> void:
	for region_id in Constants.REGIONS.keys():
		var required_level = Constants.REGIONS[region_id]["unlocked_at_level"]
		if player_level >= required_level:
			visit_region(region_id)

# ============================================================================
# VEHICLES
# ============================================================================

var current_vehicle: String = ""
var unlocked_vehicles: Array = []

func unlock_vehicle(vehicle_id: String) -> void:
	if not unlocked_vehicles.has(vehicle_id):
		unlocked_vehicles.append(vehicle_id)
		print("🏍️ Veículo desbloqueado: %s" % vehicle_id)

func equip_vehicle(vehicle_id: String) -> bool:
	if unlocked_vehicles.has(vehicle_id):
		current_vehicle = vehicle_id
		return true
	return false

func get_speed_multiplier() -> float:
	if current_vehicle and Constants.VEHICLES.has(current_vehicle):
		return Constants.VEHICLES[current_vehicle]["speed_multiplier"]
	return 1.0

func check_vehicle_unlocks() -> void:
	for vehicle_id in Constants.VEHICLES.keys():
		var required_level = Constants.VEHICLES[vehicle_id]["level"]
		if player_level >= required_level:
			unlock_vehicle(vehicle_id)

# ============================================================================
# ACHIEVEMENTS
# ============================================================================

func unlock_achievement(achievement_id: String) -> void:
	if not unlocked_achievements.has(achievement_id):
		unlocked_achievements.append(achievement_id)
		
		if Constants.ACHIEVEMENTS.has(achievement_id):
			var achievement = Constants.ACHIEVEMENTS[achievement_id]
			gain_coins(achievement["reward_coins"])
			print("🏆 Conquista desbloqueada: %s" % achievement["name"])

func has_achievement(achievement_id: String) -> bool:
	return unlocked_achievements.has(achievement_id)

# ============================================================================
# STATISTICS
# ============================================================================

func add_computer_repaired() -> void:
	total_computers_repaired += 1
	if total_computers_repaired == 10:
		unlock_achievement("technician")
	if total_computers_repaired == 50:
		unlock_achievement("specialist")

func add_phone_repaired() -> void:
	total_phones_repaired += 1

func add_enemy_defeated() -> void:
	total_enemies_defeated += 1
	if total_enemies_defeated == 100:
		unlock_achievement("digital_warrior")

func add_item_collected() -> void:
	total_items_collected += 1
	if total_items_collected == 100:
		unlock_achievement("collector")

# ============================================================================
# SAVE/LOAD SYSTEM
# ============================================================================

func save_player_data() -> void:
	var save_dict = {
		"level": player_level,
		"xp": player_xp,
		"coins": player_coins,
		"health": player_health,
		"energy": player_energy,
		"computers_repaired": total_computers_repaired,
		"phones_repaired": total_phones_repaired,
		"enemies_defeated": total_enemies_defeated,
		"items_collected": total_items_collected,
		"regions_visited": regions_visited,
		"completed_missions": completed_missions,
		"unlocked_vehicles": unlocked_vehicles,
		"current_vehicle": current_vehicle,
		"unlocked_achievements": unlocked_achievements,
		"inventory": inventory,
	}
	
	var save_file = FileAccess.open(Constants.SAVE_PATH + Constants.SAVE_FILE_NAME, FileAccess.WRITE)
	save_file.store_var(save_dict)
	print("💾 Progresso salvo!")

func load_player_data() -> void:
	var path = Constants.SAVE_PATH + Constants.SAVE_FILE_NAME
	
	if ResourceLoader.exists(path):
		var save_file = FileAccess.open(path, FileAccess.READ)
		if save_file:
			var save_dict = save_file.get_var()
			
			player_level = save_dict.get("level", Constants.PLAYER_START_LEVEL)
			player_xp = save_dict.get("xp", Constants.PLAYER_START_XP)
			player_coins = save_dict.get("coins", Constants.PLAYER_START_COINS)
			player_health = save_dict.get("health", Constants.PLAYER_MAX_HEALTH)
			player_energy = save_dict.get("energy", Constants.PLAYER_MAX_ENERGY)
			total_computers_repaired = save_dict.get("computers_repaired", 0)
			total_phones_repaired = save_dict.get("phones_repaired", 0)
			total_enemies_defeated = save_dict.get("enemies_defeated", 0)
			total_items_collected = save_dict.get("items_collected", 0)
			regions_visited = save_dict.get("regions_visited", [])
			completed_missions = save_dict.get("completed_missions", [])
			unlocked_vehicles = save_dict.get("unlocked_vehicles", [])
			current_vehicle = save_dict.get("current_vehicle", "")
			unlocked_achievements = save_dict.get("unlocked_achievements", [])
			inventory = save_dict.get("inventory", {})
			
			print("📂 Progresso carregado!")
	else:
		print("⚠️ Nenhum arquivo de salvamento encontrado. Iniciando novo jogo.")
		DirAccess.make_abs_absolute(Constants.SAVE_PATH)

func on_player_defeated() -> void:
	print("💀 Mikael foi derrotado! Reiniciando...")
	# Aqui você pode implementar a lógica de morte do jogador
