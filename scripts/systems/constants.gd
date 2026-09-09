extends Node

# ============================================================================
# CONSTANTS - AS AVENTURAS DE MIKAEL
# ============================================================================

# ============================================================================
# GAME CONFIG
# ============================================================================
const GAME_VERSION = "0.1.0"
const GAME_NAME = "As Aventuras de Mikael"
const TARGET_PLATFORM = "Android"
const TARGET_FPS = 60

# ============================================================================
# PLAYER STATS
# ============================================================================
const PLAYER_MAX_HEALTH = 100
const PLAYER_MAX_ENERGY = 100
const PLAYER_START_LEVEL = 1
const PLAYER_START_XP = 0
const PLAYER_START_COINS = 0

# ============================================================================
# LEVEL PROGRESSION
# ============================================================================
const LEVEL_DATA = {
	1: {"xp_required": 0, "reward_coins": 0},
	2: {"xp_required": 500, "reward_coins": 100},
	3: {"xp_required": 1200, "reward_coins": 150},
	4: {"xp_required": 2000, "reward_coins": 200},
	5: {"xp_required": 3500, "reward_coins": 250},
	6: {"xp_required": 5000, "reward_coins": 300},
	7: {"xp_required": 7000, "reward_coins": 350},
	8: {"xp_required": 10000, "reward_coins": 400},
	9: {"xp_required": 14000, "reward_coins": 450},
	10: {"xp_required": 20000, "reward_coins": 500},
}

const MAX_LEVEL = 100

# ============================================================================
# ENERGY COSTS
# ============================================================================
const ENERGY_REPAIR_COMPUTER = 30
const ENERGY_REPAIR_PHONE = 15
const ENERGY_FIGHT_ENEMY = 30
const ENERGY_SOLVE_PUZZLE = 10
const ENERGY_RUN_PER_SECOND = 5

# ============================================================================
# ENERGY RECOVERY
# ============================================================================
const ENERGY_RECOVERY_REST_PER_SECOND = 20
const ENERGY_RECOVERY_FOOD = 50
const ENERGY_RECOVERY_DRINK = 30
const ENERGY_RECOVERY_SPECIAL_ITEM = 100

# ============================================================================
# MISSIONS DATA
# ============================================================================
const MISSIONS = {
	1: {
		"name": "O Começo",
		"description": "Conhecer a Praça Central",
		"chapter": 1,
		"xp_reward": 100,
		"coins_reward": 50,
		"type": "exploration",
		"location": "praca"
	},
	2: {
		"name": "O Celular Perdido",
		"description": "Encontrar celular perdido",
		"chapter": 1,
		"xp_reward": 150,
		"coins_reward": 75,
		"type": "collection",
		"location": "praca"
	},
	3: {
		"name": "Cinco Objetos",
		"description": "Encontrar 5 objetos espalhados",
		"chapter": 1,
		"xp_reward": 200,
		"coins_reward": 100,
		"type": "collection",
		"location": "praca"
	},
	4: {
		"name": "Celular com Problema",
		"description": "Consertar celular com minijogo",
		"chapter": 1,
		"xp_reward": 250,
		"coins_reward": 150,
		"type": "minigame",
		"minigame": "phone_repair",
		"location": "praca",
		"energy_cost": 15
	},
	5: {
		"name": "O Primeiro Computador",
		"description": "Manutenção completa de computador",
		"chapter": 1,
		"xp_reward": 300,
		"coins_reward": 200,
		"type": "minigame",
		"minigame": "computer_maintenance",
		"location": "praca",
		"energy_cost": 30,
		"unlocks": {"level": 2}
	},
}

# ============================================================================
# MINIGAME CONFIGS
# ============================================================================
const MINIGAME_FORMATTING = {
	"difficulty_levels": 3,
	"time_limit": {"easy": 90, "normal": 75, "hard": 60},
	"xp_reward": {"easy": 50, "normal": 100, "hard": 150}
}

const MINIGAME_DRIVERS = {
	"difficulty_levels": 3,
	"time_limit": {"easy": 60, "normal": 45, "hard": 30},
	"xp_reward": {"easy": 30, "normal": 65, "hard": 100}
}

const MINIGAME_CLEANING = {
	"difficulty_levels": 3,
	"time_limit": {"easy": 75, "normal": 60, "hard": 45},
	"xp_reward": {"easy": 40, "normal": 80, "hard": 120}
}

const MINIGAME_PHONE = {
	"difficulty_levels": 3,
	"time_limit": {"easy": 70, "normal": 50, "hard": 40},
	"xp_reward": {"easy": 30, "normal": 65, "hard": 100}
}

const MINIGAME_PC_BUILD = {
	"difficulty_levels": 3,
	"time_limit": {"easy": 120, "normal": 90, "hard": 60},
	"xp_reward": {"easy": 50, "normal": 100, "hard": 150}
}

# ============================================================================
# ITEMS PRICES
# ============================================================================
const ITEM_PRICES = {
	# Roupas
	"shirt_red": 100,
	"shirt_blue": 100,
	"shirt_black": 100,
	"uniform_mikael": 200,
	"outfit_gamer": 150,
	"outfit_adventure": 300,
	
	# Acessórios
	"glasses_normal": 75,
	"glasses_dark": 150,
	"cap": 80,
	"backpack": 200,
	"watch": 120,
	"headphones": 180,
	
	# Calçados
	"flip_flops": 50,
	"sneakers": 100,
	"special_sneakers": 250,
	"boots": 200,
	
	# Veículos
	"skateboard": 500,
	"bicycle": 800,
	"motorcycle": 2000,
	"car": 5000,
}

# ============================================================================
# VEHICLE STATS
# ============================================================================
const VEHICLES = {
	"skateboard": {"level": 5, "speed_multiplier": 1.5},
	"bicycle": {"level": 10, "speed_multiplier": 2.0},
	"motorcycle": {"level": 20, "speed_multiplier": 3.0},
	"car": {"level": 30, "speed_multiplier": 2.5},
}

# ============================================================================
# ENEMY STATS
# ============================================================================
const ENEMY_STATS = {
	"virus_bot": {
		"health": 30,
		"attack_damage": 10,
		"xp_reward": 50,
		"coins_reward": 25,
		"speed": 1.0
	},
	"guardian_nexus": {
		"health": 80,
		"attack_damage": 20,
		"xp_reward": 150,
		"coins_reward": 75,
		"speed": 1.2
	},
	"drone": {
		"health": 40,
		"attack_damage": 15,
		"xp_reward": 100,
		"coins_reward": 50,
		"speed": 2.5
	},
	"malware": {
		"health": 50,
		"attack_damage": 8,
		"xp_reward": 80,
		"coins_reward": 40,
		"speed": 0.8
	},
	"nexus_01": {
		"health": 200,
		"attack_damage": 40,
		"xp_reward": 1000,
		"coins_reward": 500,
		"phases": 3,
		"speed": 1.5
	},
	"nexus_master": {
		"health": 500,
		"attack_damage": 60,
		"xp_reward": 5000,
		"coins_reward": 2000,
		"phases": 5,
		"speed": 1.8
	},
}

# ============================================================================
# REGIONS
# ============================================================================
const REGIONS = {
	"praca": {
		"name": "Praça Central",
		"icon": "🌳",
		"unlocked_at_level": 1
	},
	"informatica": {
		"name": "Centro de Informática",
		"icon": "💻",
		"unlocked_at_level": 3
	},
	"shopping": {
		"name": "Shopping",
		"icon": "🛍️",
		"unlocked_at_level": 5
	},
	"cidade": {
		"name": "Centro da Cidade",
		"icon": "🏙️",
		"unlocked_at_level": 10
	},
	"nexus": {
		"name": "Fábrica NEXUS",
		"icon": "🏭",
		"unlocked_at_level": 15
	},
	"laboratorio": {
		"name": "Laboratório",
		"icon": "🧪",
		"unlocked_at_level": 18
	},
}

# ============================================================================
# ACHIEVEMENTS
# ============================================================================
const ACHIEVEMENTS = {
	"first_step": {
		"name": "Primeiro Passo",
		"description": "Complete a primeira missão",
		"icon": "🏆",
		"reward_coins": 100
	},
	"technician": {
		"name": "Técnico",
		"description": "Conserte 10 computadores",
		"icon": "🔧",
		"reward_coins": 200
	},
	"specialist": {
		"name": "Especialista",
		"description": "Complete 50 serviços",
		"icon": "👨‍💼",
		"reward_coins": 500
	},
	"explorer": {
		"name": "Explorador",
		"description": "Visite todas as regiões",
		"icon": "🌍",
		"reward_coins": 300
	},
	"collector": {
		"name": "Colecionador",
		"description": "Encontre 100 objetos",
		"icon": "🎁",
		"reward_coins": 400
	},
	"it_master": {
		"name": "Mestre da Informática",
		"description": "Complete todas as missões de informática",
		"icon": "💻",
		"reward_coins": 600
	},
	"digital_warrior": {
		"name": "Guerreiro Digital",
		"description": "Derrote 100 inimigos",
		"icon": "⚡",
		"reward_coins": 500
	},
	"arcade_champion": {
		"name": "Campeão de Arcade",
		"description": "Atinja 10.000 pontos",
		"icon": "🎮",
		"reward_coins": 300
	},
	"millionaire": {
		"name": "Milionário",
		"description": "Acumule 1.000.000 moedas",
		"icon": "💎",
		"reward_coins": 1000
	},
	"city_hero": {
		"name": "Herói da Cidade",
		"description": "Derrote NEXUS MASTER",
		"icon": "🎖️",
		"reward_coins": 2000
	},
}

# ============================================================================
# SAVE SYSTEM
# ============================================================================
const SAVE_PATH = "user://mikael_save/"
const SAVE_FILE_NAME = "game_progress.save"
const AUTO_SAVE_INTERVAL = 300.0  # 5 minutes in seconds

# ============================================================================
# AUDIO
# ============================================================================
const AUDIO_ENABLED = true
const MASTER_VOLUME = 1.0
const MUSIC_VOLUME = 0.8
const SFX_VOLUME = 1.0

# ============================================================================
# UI
# ============================================================================
const UI_SCALE = 1.0
const TEXT_SPEED = 0.05  # seconds per character
