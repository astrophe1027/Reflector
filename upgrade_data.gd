class_name UpgradeData
extends Resource

enum Tier { COMMON, UNIQUE, LEGENDARY }

@export var id: String = ""
@export var tier: Tier = Tier.COMMON
@export var name: String = ""
@export_multiline var description: String = ""
@export var is_one_time: bool = false # 1회 제한 여부 (중복 등장 방지)
@export var image: CompressedTexture2D = preload("res://assets/1_1.png")
