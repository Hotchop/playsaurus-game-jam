extends Control

# Game state
var faith: int = 1000  # Main currency for everything
var reputation: float = 2.5
var god_slots: int = 5
var mission_success_bonus: float = 0.0  # Increases min multiplier
var faith_multiplier: float = 1.0

# Collections
var all_gods: Array = []
var active_missions: Array = []
var available_missions: Array = []

# Random generation lists
var god_names: Array = [
	"God of Socks", "God of Beans", "God of Paperclips", "God of Mondays",
	"God of Lost Keys", "God of Burnt Toast", "God of Traffic Lights", "God of Hiccups",
	"God of Sneezes", "God of Typos", "God of Buffering", "God of Crumbs",
	"God of Lint", "God of Potholes", "God of Mosquitoes", "God of Static",
	"God of Splinters", "God of Hangnails", "God of Tangles", "God of Stubbed Toes",
	"God of Cold Calls", "God of Spam", "God of Autocorrect", "God of Loading Screens",
	"God of Wet Socks", "God of Brain Freeze", "God of Paper Cuts", "God of Elevator Music",
	"God of Crumpled Receipts", "God of Expired Coupons", "God of Tangled Cords", "God of Sticky Keyboards",
	"God of Flat Tires", "God of Dead Batteries", "God of Forgotten Passwords", "God of Broken Shoelaces",
	"God of Dusty Shelves", "God of Squeaky Hinges", "God of Leaky Faucets", "God of Burnt Popcorn",
	"God of Stubborn Jars", "God of Crooked Pictures", "God of Wrinkled Shirts", "God of Squeaky Floors",
	"God of Foggy Mirrors", "God of Tangled Earbuds", "God of Warm Pillows", "God of Lukewarm Coffee",
	"God of Stale Chips", "God of Wobbly Tables", "God of Creaky Chairs", "God of Dried Pens",
	"God of Stuck Zippers", "God of Missing Socks", "God of Cracked Screens", "God of Low Battery",
	"God of Bad WiFi", "God of Slow Downloads", "God of Frozen Apps", "God of Blue Screens",
	"God of 404 Errors", "God of Caps Lock", "God of Num Lock", "God of Scroll Lock",
	"God of Printer Jams", "God of Out of Ink", "God of Paper Jams", "God of Toner Low",
	"God of Copy Errors", "God of Scan Failures", "God of Fax Machines", "God of Busy Signals",
	"God of Voicemail", "God of Hold Music", "God of Wrong Numbers", "God of Pocket Dials",
	"God of Butt Dials", "God of Group Chats", "God of Read Receipts", "God of Typing Bubbles",
	"God of Left on Read", "God of Seen Notifications", "God of Unread Emails", "God of Spam Folders",
	"God of Reply All", "God of CC Everyone", "God of BCC Secrets", "God of Email Chains",
	"God of Attachment Limits", "God of File Size Errors", "God of Format Issues", "God of Compatibility",
	"God of Updates", "God of Restarts", "God of Forced Updates", "God of Terms and Conditions",
	"God of Cookie Popups", "God of Captchas", "God of Password Requirements", "God of Two Factor Auth"
]

var mission_names: Array = [
	"Get cat down from tree", "Pass my drivers exam", "Find lost remote control",
	"Make it stop raining at picnic", "Help find matching sock", "Unclog the toilet",
	"Fix squeaky door", "Remove gum from hair", "Get WiFi to work", "Find car keys",
	"Make toast not burn", "Stop dog from barking", "Find phone in couch", "Fix leaky faucet",
	"Get lid off jar", "Untangle Christmas lights", "Remove wine stain", "Fix flat tire",
	"Get ring out of drain", "Stop baby from crying", "Find TV remote", "Fix broken zipper",
	"Get gum off shoe", "Remove splinter", "Fix creaky floorboard", "Get marker off wall",
	"Unclog printer", "Fix broken shoelace", "Get pen to work", "Find missing earring",
	"Fix wobbly table", "Get stain out of shirt", "Fix sticky door", "Remove crayon from wall",
	"Get bird out of house", "Fix broken glasses", "Find lost wallet", "Get ketchup stain out",
	"Fix computer that won't start", "Get raccoon out of attic", "Find lost homework",
	"Make computer faster", "Get better cell signal", "Find parking spot", "Make traffic go away",
	"Help win lottery", "Make crush like me back", "Get promotion at work", "Pass math test",
	"Win argument with spouse", "Get good hair day", "Make it not Monday", "Skip the line at DMV",
	"Get extra fries in order", "Make elevator come faster", "Get green lights all the way",
	"Make printer work for once", "Get package delivered on time", "Make meeting be cancelled",
	"Get out of jury duty", "Make dentist appointment disappear", "Skip family reunion",
	"Get good parking spot at mall", "Make internet faster", "Get waiter's attention",
	"Make phone battery last", "Get upgrade to first class", "Make rain stop for wedding",
	"Get snow day from school", "Make hangover go away", "Get reservation at full restaurant",
	"Make acne disappear", "Get date to text back", "Make Monday feel like Friday",
	"Get free shipping", "Make traffic light turn green", "Get good grade without studying",
	"Make boss not notice I'm late", "Get printer to work before meeting", "Make queue move faster",
	"Get good RNG in video game", "Make gacha pull be legendary", "Get critical hit",
	"Make enemy miss attack", "Get shiny Pokemon", "Make loot drop be rare",
	"Get perfect roll on stats", "Make matchmaking be fair", "Get good teammates",
	"Make lag go away", "Get server to not crash", "Make update download faster",
	"Get banned player unbanned", "Make nerf not happen", "Get buff for favorite character",
	"Make event not be grindy", "Get free premium currency", "Make dailies complete themselves",
	"Scare neighbors roommate", "Make plants grow faster", "Get better weather tomorrow",
	"Make coffee taste good", "Get motivation to exercise", "Make alarm not go off"
]

# UI References
@onready var faith_label = $MarginContainer/VBoxContainer/TopBar/FaithLabel
@onready var reputation_label = $MarginContainer/VBoxContainer/TopBar/ReputationLabel
@onready var missions_container = $MarginContainer/VBoxContainer/MainContent/MissionsPanel/ScrollContainer/VBoxContainer
@onready var gods_container = $MarginContainer/VBoxContainer/GodsPanel/ScrollContainer/HBoxContainer
@onready var upgrades_container = $MarginContainer/VBoxContainer/MainContent/UpgradesPanel/ScrollContainer/VBoxContainer

# Timers
var mission_spawn_timer: float = 0.0
var mission_spawn_interval: float = 8.0  # Spawn missions every 8 seconds

# Selected items
var selected_mission = null
var selected_god = null

func _ready():
	randomize()
	# Start with 3 random gods
	for i in range(3):
		add_random_god()

	update_ui()
	setup_upgrades()

func _process(delta):
	# Spawn missions randomly
	mission_spawn_timer += delta
	if mission_spawn_timer >= mission_spawn_interval:
		mission_spawn_timer = 0.0
		spawn_mission()

	# Update mission timers
	for mission in available_missions:
		mission.update_timer(delta)

	for mission in active_missions:
		mission.update_progress(delta)

	update_ui()

func spawn_mission():
	if available_missions.size() >= 10:  # Max 10 available missions
		return

	var mission = create_random_mission()
	available_missions.append(mission)
	missions_container.add_child(mission)

func create_random_mission():
	var mission_scene = preload("res://Mission.tscn")
	var mission = mission_scene.instantiate()

	var mission_name = mission_names[randi() % mission_names.size()]
	var difficulty = randi() % 5 + 1  # 1-5
	var recommended_stat = ["strength", "speed", "intelligence"][randi() % 3]
	var reward = difficulty * 100 * randf_range(0.8, 1.5)
	var completion_time = difficulty * 5.0 + randf_range(2.0, 8.0)
	var threshold = difficulty * 50 + randf_range(20, 80)

	mission.setup(mission_name, difficulty, recommended_stat, int(reward), completion_time, threshold)
	mission.mission_clicked.connect(_on_mission_clicked)
	mission.mission_expired.connect(_on_mission_expired)
	mission.mission_completed.connect(_on_mission_completed)

	return mission

func add_random_god():
	if all_gods.size() >= god_slots:
		return false

	var god_scene = preload("res://God.tscn")
	var god = god_scene.instantiate()

	var god_name = god_names[randi() % god_names.size()]
	var strength = randi() % 101
	var speed = randi() % 101
	var intelligence = randi() % 101

	god.setup(god_name, strength, speed, intelligence)
	god.god_clicked.connect(_on_god_clicked)

	all_gods.append(god)
	gods_container.add_child(god)

	return true

func _on_mission_clicked(mission):
	# Deselect previous mission
	if selected_mission and selected_mission != mission:
		selected_mission.deselect()

	selected_mission = mission

	# If we have both mission and god selected, assign it
	if selected_god and selected_mission:
		assign_mission()

func _on_god_clicked(god):
	# Can't select gods that are busy
	if god.is_busy:
		return

	# Deselect previous god
	if selected_god and selected_god != god:
		selected_god.deselect()

	selected_god = god

	# If we have both mission and god selected, assign it
	if selected_god and selected_mission:
		assign_mission()

func assign_mission():
	if not selected_mission or not selected_god:
		return

	# Remove from available missions
	available_missions.erase(selected_mission)
	active_missions.append(selected_mission)

	# Mark god as busy
	selected_god.set_busy(true)

	# Start mission
	selected_mission.start_mission(selected_god)

	# Clear selections
	selected_mission = null
	selected_god.deselect()
	selected_god = null

func _on_mission_expired(mission):
	# Mission disappeared without being completed
	available_missions.erase(mission)
	mission.queue_free()

	# Decrease reputation
	reputation = max(0.0, reputation - 0.1)

func _on_mission_completed(mission, god, success):
	active_missions.erase(mission)

	if success:
		var actual_reward = int(mission.reward * faith_multiplier)
		faith += actual_reward
		reputation = min(5.0, reputation + 0.05)
	else:
		reputation = max(0.0, reputation - 0.05)

	# Free the god
	god.set_busy(false)

	# Remove mission
	mission.queue_free()

func update_ui():
	faith_label.text = "Faith: %d" % faith
	reputation_label.text = "Reputation: %.1f/5.0" % reputation

func setup_upgrades():
	add_upgrade("Buy Random God", 500, func(): return buy_random_god())
	add_upgrade("Buy God Slot", 1000, func(): return buy_god_slot())
	add_upgrade("Mission Success Bonus", 750, func(): return buy_success_bonus())
	add_upgrade("Faith Multiplier", 1000, func(): return buy_faith_multiplier())

func add_upgrade(upgrade_name: String, cost: int, callback: Callable):
	var upgrade = Button.new()
	upgrade.text = "%s (%d Faith)" % [upgrade_name, cost]
	upgrade.pressed.connect(func():
		if faith >= cost:
			if callback.call():
				faith -= cost
	)
	upgrades_container.add_child(upgrade)

func buy_random_god() -> bool:
	return add_random_god()

func buy_god_slot() -> bool:
	god_slots += 1
	return true

func buy_success_bonus() -> bool:
	if mission_success_bonus >= 0.5:
		return false
	mission_success_bonus += 0.01
	return true

func buy_faith_multiplier() -> bool:
	faith_multiplier += 0.1
	return true
