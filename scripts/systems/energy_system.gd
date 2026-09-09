extends Node

# ============================================================================
# ENERGY SYSTEM - AS AVENTURAS DE MIKAEL
# ============================================================================
# Gerencia energia do jogador

class_name EnergySystem

signal energy_changed(new_energy, max_energy)
signal energy_depleted
signal energy_recovering
signal energy_full

var current_energy: int = Constants.PLAYER_MAX_ENERGY
var max_energy: int = Constants.PLAYER_MAX_ENERGY
var player_stats: PlayerStats
var is_recovering: bool = false

func _ready():
	pass

func set_player_stats(stats: PlayerStats) -> void:
	player_stats = stats

# ============================================================================
# ENERGY QUERIES
# ============================================================================

func get_current_energy() -> int:
	if player_stats:
		return player_stats.player_energy
	return current_energy

func get_max_energy() -> int:
	return max_energy

func get_energy_percentage() -> float:
	var current = get_current_energy()
	if max_energy == 0:
		return 0.0
	return float(current) / float(max_energy)

func has_enough_energy(amount: int) -> bool:
	return get_current_energy() >= amount

# ============================================================================
# USE ENERGY
# ============================================================================

func use_energy_repair_computer() -> bool:
	return use_energy(Constants.ENERGY_REPAIR_COMPUTER)

func use_energy_repair_phone() -> bool:
	return use_energy(Constants.ENERGY_REPAIR_PHONE)

func use_energy_fight_enemy() -> bool:
	return use_energy(Constants.ENERGY_FIGHT_ENEMY)

func use_energy_solve_puzzle() -> bool:
	return use_energy(Constants.ENERGY_SOLVE_PUZZLE)

func use_energy_run(seconds: float) -> bool:
	var energy_cost = int(Constants.ENERGY_RUN_PER_SECOND * seconds)
	return use_energy(energy_cost)

func use_energy(amount: int) -> bool:
	if not has_enough_energy(amount):
		print("⚠️ Energia insuficiente! (Necessário: %d, Disponível: %d)" % [amount, get_current_energy()])
		return false
	
	if player_stats:
		var used = player_stats.use_energy(amount)
		if used:
			emit_signal("energy_changed", get_current_energy(), max_energy)
			print("⚡ Energia usada: -%d (Restante: %d)" % [amount, get_current_energy()])
		return used
	
	current_energy -= amount
	emit_signal("energy_changed", current_energy, max_energy)
	return true

# ============================================================================
# RECOVER ENERGY
# ============================================================================

func recover_energy_food() -> void:
	recover_energy(Constants.ENERGY_RECOVERY_FOOD)

func recover_energy_drink() -> void:
	recover_energy(Constants.ENERGY_RECOVERY_DRINK)

func recover_energy_special_item() -> void:
	recover_energy(Constants.ENERGY_RECOVERY_SPECIAL_ITEM)

func recover_energy_rest(seconds: float) -> void:
	var recovered = int(Constants.ENERGY_RECOVERY_REST_PER_SECOND * seconds)
	recover_energy(recovered)

func recover_energy(amount: int) -> void:
	if player_stats:
		player_stats.recover_energy(amount)
	else:
		current_energy = min(max_energy, current_energy + amount)
	
	emit_signal("energy_changed", get_current_energy(), max_energy)
	print("💪 Energia recuperada: +%d (Total: %d)" % [amount, get_current_energy()])

func restore_full_energy() -> void:
	if player_stats:
		player_stats.restore_full_energy()
	else:
		current_energy = max_energy
	
	emit_signal("energy_full")
	emit_signal("energy_changed", get_current_energy(), max_energy)
	print("💪 Energia totalmente restaurada!")

# ============================================================================
# ENERGY STATUS
# ============================================================================

func is_energy_full() -> bool:
	return get_current_energy() >= max_energy

func is_energy_low() -> bool:
	return get_energy_percentage() < 0.25

func is_energy_empty() -> bool:
	return get_current_energy() <= 0

func get_energy_status() -> String:
	var percentage = get_energy_percentage()
	
	if percentage >= 0.75:
		return "Excelente"
	elif percentage >= 0.50:
		return "Bom"
	elif percentage >= 0.25:
		return "Baixo"
	else:
		return "Crítico"

# ============================================================================
# ENERGY COSTS QUERIES
# ============================================================================

func get_energy_cost_repair_computer() -> int:
	return Constants.ENERGY_REPAIR_COMPUTER

func get_energy_cost_repair_phone() -> int:
	return Constants.ENERGY_REPAIR_PHONE

func get_energy_cost_fight_enemy() -> int:
	return Constants.ENERGY_FIGHT_ENEMY

func get_energy_cost_solve_puzzle() -> int:
	return Constants.ENERGY_SOLVE_PUZZLE

func get_energy_cost_run_per_second() -> int:
	return Constants.ENERGY_RUN_PER_SECOND

# ============================================================================
# ENERGY RECOVERY QUERIES
# ============================================================================

func get_recovery_amount_food() -> int:
	return Constants.ENERGY_RECOVERY_FOOD

func get_recovery_amount_drink() -> int:
	return Constants.ENERGY_RECOVERY_DRINK

func get_recovery_amount_special() -> int:
	return Constants.ENERGY_RECOVERY_SPECIAL_ITEM

func get_recovery_rate_rest() -> int:
	return Constants.ENERGY_RECOVERY_REST_PER_SECOND

# ============================================================================
# ENERGY EFFICIENCY
# ============================================================================

func can_complete_task_with_current_energy(task_cost: int) -> bool:
	return has_enough_energy(task_cost)

func get_tasks_possible_with_current_energy() -> Dictionary:
	var energy = get_current_energy()
	
	return {
		"can_repair_computer": energy >= get_energy_cost_repair_computer(),
		"can_repair_phone": energy >= get_energy_cost_repair_phone(),
		"can_fight_enemy": energy >= get_energy_cost_fight_enemy(),
		"can_solve_puzzle": energy >= get_energy_cost_solve_puzzle(),
	}

func get_time_until_full_energy() -> float:
	if is_energy_full():
		return 0.0
	
	var energy_needed = max_energy - get_current_energy()
	var recovery_rate = get_recovery_rate_rest()
	
	if recovery_rate <= 0:
		return 0.0
	
	return float(energy_needed) / float(recovery_rate)

# ============================================================================
# DEBUGGING
# ============================================================================

func print_energy_info() -> void:
	print("\n=== ENERGY INFO ===")
	print("Energia: %d/%d (%s)" % [get_current_energy(), max_energy, get_energy_status()])
	print("Percentual: %.1f%%" % (get_energy_percentage() * 100))
	print("\nCustos de Ações:")
	print("  Consertar computador: %d" % get_energy_cost_repair_computer())
	print("  Consertar celular: %d" % get_energy_cost_repair_phone())
	print("  Lutar contra inimigo: %d" % get_energy_cost_fight_enemy())
	print("  Resolver enigma: %d" % get_energy_cost_solve_puzzle())
	print("\nTarefas Possíveis:")
	var tasks = get_tasks_possible_with_current_energy()
	print("  Reparar computador: %s" % ("Sim" if tasks["can_repair_computer"] else "Não"))
	print("  Reparar celular: %s" % ("Sim" if tasks["can_repair_phone"] else "Não"))
	print("  Lutar: %s" % ("Sim" if tasks["can_fight_enemy"] else "Não"))
	print("  Resolver enigma: %s" % ("Sim" if tasks["can_solve_puzzle"] else "Não"))
	print("==================\n")
