extends Node

# ============================================================================
# COINS SYSTEM - AS AVENTURAS DE MIKAEL
# ============================================================================
# Gerencia as moedas do jogador

class_name CoinsSystem

signal coins_changed(new_amount)
signal coins_earned(amount, source)
signal coins_spent(amount, item)
signal insufficient_coins

var player_stats: PlayerStats

func _ready():
	pass

func set_player_stats(stats: PlayerStats) -> void:
	player_stats = stats

# ============================================================================
# COIN QUERIES
# ============================================================================

func get_current_coins() -> int:
	if player_stats:
		return player_stats.player_coins
	return 0

func can_afford(cost: int) -> bool:
	return get_current_coins() >= cost

# ============================================================================
# EARNING COINS
# ============================================================================

func earn_coins_mission(mission_id: int) -> void:
	if not Constants.MISSIONS.has(mission_id):
		return
	
	var mission = Constants.MISSIONS[mission_id]
	var coins = mission.get("coins_reward", 0)
	
	if player_stats:
		player_stats.gain_coins(coins)
	
	emit_signal("coins_earned", coins, "mission_%d" % mission_id)

func earn_coins_collection(item_value: int) -> void:
	if player_stats:
		player_stats.gain_coins(item_value)
	
	emit_signal("coins_earned", item_value, "collection")

func earn_coins_challenge(challenge_reward: int) -> void:
	if player_stats:
		player_stats.gain_coins(challenge_reward)
	
	emit_signal("coins_earned", challenge_reward, "challenge")

func earn_coins_minigame(minigame_type: String, difficulty: String) -> void:
	var reward = get_minigame_coin_reward(minigame_type, difficulty)
	
	if player_stats:
		player_stats.gain_coins(reward)
	
	emit_signal("coins_earned", reward, "minigame_%s_%s" % [minigame_type, difficulty])

func earn_coins_discovery(location: String) -> void:
	var reward = randi_range(100, 500)
	
	if player_stats:
		player_stats.gain_coins(reward)
	
	emit_signal("coins_earned", reward, "discovery_%s" % location)

func earn_coins_custom(amount: int, source: String) -> void:
	if amount > 0 and player_stats:
		player_stats.gain_coins(amount)
		emit_signal("coins_earned", amount, source)

func get_minigame_coin_reward(minigame_type: String, difficulty: String) -> int:
	var base_rewards = {
		"formatting": {"easy": 50, "normal": 100, "hard": 150},
		"drivers": {"easy": 30, "normal": 65, "hard": 100},
		"cleaning": {"easy": 40, "normal": 80, "hard": 120},
		"phone": {"easy": 30, "normal": 65, "hard": 100},
		"pc_build": {"easy": 50, "normal": 100, "hard": 150},
	}
	
	if base_rewards.has(minigame_type):
		return base_rewards[minigame_type].get(difficulty, 50)
	
	return 50

# ============================================================================
# SPENDING COINS
# ============================================================================

func buy_item(item_id: String) -> bool:
	if not Constants.ITEM_PRICES.has(item_id):
		return false
	
	var cost = Constants.ITEM_PRICES[item_id]
	
	if not can_afford(cost):
		emit_signal("insufficient_coins")
		print("❌ Moedas insuficientes para comprar %s (Custo: %d)" % [item_id, cost])
		return false
	
	if player_stats:
		player_stats.spend_coins(cost)
		player_stats.add_item(item_id)
	
	emit_signal("coins_spent", cost, item_id)
	print("✅ %s comprado por %d moedas" % [item_id, cost])
	return true

func spend_coins_custom(amount: int, item: String) -> bool:
	if not can_afford(amount):
		emit_signal("insufficient_coins")
		return false
	
	if player_stats:
		player_stats.spend_coins(amount)
	
	emit_signal("coins_spent", amount, item)
	return true

# ============================================================================
# ITEM PRICES
# ============================================================================

func get_item_price(item_id: String) -> int:
	return Constants.ITEM_PRICES.get(item_id, 0)

func can_buy_item(item_id: String) -> bool:
	var price = get_item_price(item_id)
	return can_afford(price)

func get_all_items_for_sale() -> Dictionary:
	var items = {}
	
	for item_id in Constants.ITEM_PRICES.keys():
		items[item_id] = Constants.ITEM_PRICES[item_id]
	
	return items

func get_items_by_category(category: String) -> Dictionary:
	var items = {}
	
	for item_id in Constants.ITEM_PRICES.keys():
		if item_id.begins_with(category):
			items[item_id] = Constants.ITEM_PRICES[item_id]
	
	return items

# ============================================================================
# ECONOMY BALANCE
# ============================================================================

func get_total_coins_earned() -> int:
	if player_stats:
		return player_stats.player_coins
	return 0

func get_average_coins_per_mission() -> int:
	var total = 0
	var count = 0
	
	for mission_id in Constants.MISSIONS.keys():
		total += Constants.MISSIONS[mission_id].get("coins_reward", 0)
		count += 1
	
	if count > 0:
		return total / count
	
	return 0

func calculate_mission_coin_value(mission_id: int) -> int:
	if Constants.MISSIONS.has(mission_id):
		return Constants.MISSIONS[mission_id].get("coins_reward", 0)
	return 0

# ============================================================================
# DEBUGGING
# ============================================================================

func print_coins_info() -> void:
	print("\n=== COINS INFO ===")
	print("Moedas atuais: %d" % get_current_coins())
	print("Total ganho: %d" % get_total_coins_earned())
	print("Média por missão: %d" % get_average_coins_per_mission())
	print("Items à venda: %d" % get_all_items_for_sale().size())
	print("==================\n")

func print_shop() -> void:
	var items = get_all_items_for_sale()
	
	print("\n=== LOJA ===")
	for item_id in items.keys():
		var price = items[item_id]
		var affordable = "✅" if can_afford(price) else "❌"
		print("%s %s - %d moedas" % [affordable, item_id, price])
	print("============\n")
