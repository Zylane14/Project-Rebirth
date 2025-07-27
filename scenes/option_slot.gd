extends TextureButton

var stat_suffixes = {
	"crit": "%", "crit_damage": "x", "armor": "%",
	"luck": "%", "dodge": "%", "growth": " exp/rate",
	"recovery": " hp/sec", "movement_speed": "", "max_health": "",
	"damage": "", "amplify": "%", "area": "", "magnet": "",
	"cooldown": "s", "amount": "", "angular_speed": ""
}

@export var item: Item:
	set(value):
		item = value
		if item == null:
			return

		# Icon and Title
		$HeaderBar/Icon.texture = item.icon
		$Title.text = item.title

		# Type label
		if item is Weapon:
			$Type.text = "Weapon"
			$Type.add_theme_color_override("font_color", Color(1, 0.7, 0.4))
		elif item is PassiveItem:
			$Type.text = "Passive"
			$Type.add_theme_color_override("font_color", Color(0.5, 0.8, 1))
		else:
			$Type.text = ""
			$Type.clear_theme_color_override("font_color")

		# Description box setup
		var desc_box := $Frame/Description
		desc_box.bbcode_enabled = true
		desc_box.clear()

		var has_upgrades: bool = item.upgrades.size() > 0
		var has_evolution: bool = item is Weapon and item.evolution != null

		# Stat display rules: false = higher is better, true = lower is better
		var custom_stat_fields = {
			"max_health": false, "recovery": false, "armor": false,
			"movement_speed": false, "damage": false, "amplify": false,
			"area": false, "magnet": false, "growth": false, "luck": false,
			"dodge": false, "crit": false, "crit_damage": false, "cooldown": true,
			"amount": false, "angular_speed": false, "radius": false
		}

		if has_upgrades and item.level < item.upgrades.size():
			# Show upgrade preview
			var next_upgrade = item.upgrades[item.level]
			var next_level = item.level + 1
			if next_level >= item.upgrades.size():
				$Frame/Level.text = "Level " + str(item.level) + " → MAX"
			else:
				$Frame/Level.text = "Level " + str(item.level) + " → " + str(next_level)

			var stat_text := ""

			for stat_name in custom_stat_fields.keys():
				var invert = custom_stat_fields[stat_name]

				if item.has_method("get") and _has_property(next_upgrade, stat_name):
					var current_value := 0.0
					if _has_property(item, stat_name):
						current_value = item.get(stat_name)

					var upgrade_value = next_upgrade.get(stat_name)
					var new_value = current_value + upgrade_value

					if abs(upgrade_value) > 0.001:
						var label = stat_name.capitalize().replace("_", " ")
						var suffix = stat_suffixes.get(stat_name, "")
						stat_text += format_stat_change(label, current_value, new_value, invert, suffix)

			if next_upgrade.description != "":
				stat_text += "\n" + next_upgrade.description

			desc_box.append_text(stat_text)

		elif has_evolution and item.level >= item.upgrades.size() and item.evolution != null:
			# Show evolution preview
			$HeaderBar/Icon.texture = item.evolution.icon
			$Frame/Level.text = "EVOLUTION"

			var evolution_stat_text := ""

			for stat_name in custom_stat_fields.keys():
				var invert = custom_stat_fields[stat_name]

				if item.has_method("get") and _has_property(item.evolution, stat_name):
					var current_value := 0.0
					if _has_property(item, stat_name):
						current_value = item.get(stat_name)

					var evolved_value = item.evolution.get(stat_name)

					if abs(evolved_value - current_value) > 0.001:
						var label = stat_name.capitalize().replace("_", " ")
						var suffix = stat_suffixes.get(stat_name, "")
						evolution_stat_text += format_stat_change(label, current_value, evolved_value, invert, suffix)

			if item.evolution.description != "":
				evolution_stat_text += "\n" + item.evolution.description

			desc_box.append_text(evolution_stat_text)

		else:
			# No upgrade and no evolution
			$Frame/Level.text = "MAX LEVEL"
			desc_box.append_text(item.description)

		# Rarity label
		$Frame/Rarity.text = get_rarity_name(item.rarity)
		match item.rarity:
			Item.Rarity.COMMON:
				$Frame/Rarity.add_theme_color_override("font_color", Color(1, 1, 1))
			Item.Rarity.RARE:
				$Frame/Rarity.add_theme_color_override("font_color", Color(0.2, 0.6, 1))
			Item.Rarity.EPIC:
				$Frame/Rarity.add_theme_color_override("font_color", Color(0.7, 0.3, 1))
			Item.Rarity.SPECIAL:
				$Frame/Rarity.add_theme_color_override("font_color", Color(1, 0.5, 0.1))
			Item.Rarity.LEGENDARY:
				$Frame/Rarity.add_theme_color_override("font_color", Color(1, 0.9, 0.2))

func get_rarity_name(rarity_value: int) -> String:
	match rarity_value:
		Item.Rarity.COMMON: return "Common"
		Item.Rarity.RARE: return "Rare"
		Item.Rarity.EPIC: return "Epic"
		Item.Rarity.SPECIAL: return "Special"
		Item.Rarity.LEGENDARY: return "Legendary"
		_: return "Unknown"

func format_stat_change(label: String, current: float, next: float, invert := false, suffix := "") -> String:
	var color := "white"
	if next > current:
		color = "red" if invert else "green"
	elif next < current:
		color = "green" if invert else "red"
	else:
		color = "gray"

	return "[color=gray]" + label + ":[/color] " + round1(current) + suffix + " → [color=" + color + "]" + round1(next) + suffix + "[/color]\n"

func round1(value: float) -> String:
	var rounded: float = round(value * 10.0) / 10.0
	if int(rounded) == rounded:
		return str(int(rounded))
	return str(rounded)

func _has_property(obj: Object, property_name: String) -> bool:
	for prop in obj.get_property_list():
		if prop.name == property_name:
			return true
	return false

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and item:
		print(item.title)
		SoundManager.play_sfx(load("res://music & sfx/Be Not Afraid UI/--Unholy/Souls/Unholy UI - Souls (13).wav"))
		get_parent().check_item(item)
		item.upgrade_item()
		get_parent().close_option()
