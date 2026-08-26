class_name UpgradeManager
extends Node

signal level_up_triggered(upgrades: Array[UpgradeData])

var pick_count: int = 0
var available_pool: Array[UpgradeData] = []
var applied_one_time_upgrades: Array[String] = [] # 이미 적용된 1회성 아이템 ID 목록

var modifiers: Dictionary = {
	# [이동 관련]
	"speed": 1.0,
	
	# [방패/반사 관련]
	"reflect_speed": 1.0, # 반사체 속도 배율
	"shield_max": 1.0, # 최대 게이지
	"shield_regen": 1.0, # 게이지 회복율
	
	# [기타 유틸리티]
	"coin_range": 1.0 # 자석 범위
}

# 2. 특수 트레이트(Bool 플래그) 딕셔너리
var traits: Dictionary = {
	"shield_bash": false,     # 방패 충돌 공격
	"dodging_exp": false,     # 회피 경험치
	"auto_shield": false,    # 자동 반사
	"split_bullet": false,    # 탄막 분열
	"revolving_bullet": false,# 공전 총알
	"dash": false,
	"shield_fast": true,
	"bonus_coin": false
}
func _init() -> void:
	Global.upgrade_manager = self

func _ready() -> void:
	load_all_upgrades()
	if Global.world.hard_mode:
		modifiers.shield_max *= 0.75
		modifiers.shield_regen *= 0.8
	elif Global.world.easy_mode:
		modifiers.speed *= 1.4
		modifiers.shield_max *= 2.4
		modifiers.shield_regen *= 3
		if !Global.is_saved && !Global.world.tutorial:
			await get_tree().create_timer(0.01).timeout
			trigger_level_up()
	else:
		modifiers.shield_max *= 1.25
		modifiers.shield_regen *= 1.2
		
	if Global.is_saved:
		modifiers = Global.save.modifiers
		traits = Global.save.traits
		applied_one_time_upgrades = Global.save.applied_one_time_upgrades

# res://upgrades/ 폴더 내의 모든 .tres 리소스를 로드하거나 직접 배열에 등록
func load_all_upgrades() -> void:
	var folder_path = "res://upgrades/"
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir():
				# 1. 빌드 시 붙는 .remap 및 .import 확장자 제거
				var clean_name = file_name.replace(".remap", "").replace(".import", "")
				
				# 2. .tres 파일만 필터링
				if clean_name.ends_with(".tres"):
					var full_path = folder_path + clean_name
					
					# 3. ResourceLoader를 통해 안전하게 로드 (기존 load() 대신 사용)
					if ResourceLoader.exists(full_path):
						var res = ResourceLoader.load(full_path)
						if res is UpgradeData:
							available_pool.append(res)
							
			file_name = dir.get_next()
			
	print("총 불러온 업그레이드 수: ", available_pool.size())
	# 예시: 직접 데이터 세팅 방식 (또는 .tres 파일로 로드 가능)

# 레벨업 시 호출되는 핵심 함수
func trigger_level_up() -> void:
	pick_count += 1
	
	# 1. 이미 획득한 1회 제한(is_one_time) 아이템 제외 필터링
	var filtered_pool = available_pool.filter(
		func(u): return not (u.is_one_time and u.id in applied_one_time_upgrades)
	)
	if Global.world.hard_mode:
		filtered_pool = filtered_pool.filter(
		func(u): return (u.id != "gambling")
		)
	# 2. 확률에 따라 카드 3장 뽑기
	var selected_upgrades: Array[UpgradeData] = []
	var pool_copy = filtered_pool.duplicate()
	
	while selected_upgrades.size() < 3 and not pool_copy.is_empty():
		var target_tier = _get_random_tier_by_pick_count()
		
		var candidates = pool_copy.filter(func(u): return u.tier == target_tier)
		if candidates.is_empty():
			candidates = pool_copy.filter(func(u): return u.tier == UpgradeData.Tier.COMMON)
		if candidates.is_empty():
			candidates = pool_copy
			
		var chosen = candidates.pick_random()
		selected_upgrades.append(chosen)
		pool_copy.erase(chosen)
		
	# 3. 게임 일시정지 후 UI에 신호 전달
	get_tree().paused = true
	level_up_triggered.emit(selected_upgrades)

func _get_random_tier_by_pick_count() -> UpgradeData.Tier:
	var r = randf()
	if r < 0.06: return UpgradeData.Tier.LEGENDARY
	elif r < 0.20: return UpgradeData.Tier.UNIQUE
	
	#if pick_count <= 3:
		#if r < 0.01: return UpgradeData.Tier.LEGENDARY
		#elif r < 0.06: return UpgradeData.Tier.UNIQUE
	#elif pick_count <= 5:
		#if r < 0.03: return UpgradeData.Tier.LEGENDARY
		#elif r < 0.14: return UpgradeData.Tier.UNIQUE
	#else:
		#if r < 0.06: return UpgradeData.Tier.LEGENDARY
		#elif r < 0.20: return UpgradeData.Tier.UNIQUE
		
	return UpgradeData.Tier.COMMON

# 선택된 업그레이드 적용
func apply_upgrade(upgrade: UpgradeData) -> void:
	if upgrade.is_one_time:
		applied_one_time_upgrades.append(upgrade.id)
		
	# 업그레이드 ID에 따른 효과 적용
	match upgrade.id:
		"speed": modifiers.speed *= 1.2
		"coin_range": modifiers.coin_range *= 1.25
		"reflect_speed": modifiers.reflect_speed *= 1.2
		"shield_max": modifiers.shield_max *= 1.2
		"heal": Global.player.current_health = min(Global.player.max_health, Global.player.max_health/2 + Global.player.current_health)
		"max_health": Global.player.max_health += 20;Global.player.current_health += 10
		"shield_regen": modifiers.shield_regen *= 1.2
		"big_shield": Global.player.find_child("Shield").scale.y+=0.2
		"revolving_bullet": traits.revolving_bullet = true
		"shield_bash": traits.shield_bash = true
		"dash": traits.dash = true
		"split_bullet": traits.split_bullet = true
		"dodging_exp": traits.dodging_exp = true
		"auto_shield": traits.auto_shield = true
		"shield_fast": traits.shield_fast = true
		"gambling":
			await get_tree().create_timer(0.45).timeout;if randf()<0.3:modifiers.speed *= 2;modifiers.coin_range *= 1.5;modifiers.reflect_speed *= 1.3;modifiers.shield_max *= 1.5;modifiers.shield_regen *= 1.5;Global.player.max_health += 50;Global.player.current_health+=50;
			else:Global.player._hit(10000)
		# ... 나머지 ID 매칭
