## What changed in each version, newest first. Shown once when the game opens after an update, and from the settings.
## Add an entry for every version you release (a test fails if the current version has none).
class_name Changelog
extends RefCounted

const ENTRIES := [
	{
		"version": "0.43.0",
		"items": [
			"After an update the game shows only what is new in the latest version.",
		],
	},
	{
		"version": "0.42.0",
		"items": [
			"Herpes now wears a grey armour shell while it is immune, with a flash when the shell breaks.",
		],
	},
	{
		"version": "0.41.0",
		"items": [
			"The tower shop lists the towers from the cheapest to the most expensive.",
		],
	},
	{
		"version": "0.40.0",
		"items": [
			"Pinch with two fingers to zoom the map in and out.",
		],
	},
	{
		"version": "0.39.0",
		"items": [
			"The code is organised in one game folder, with no change to how the game plays.",
		],
	},
	{
		"version": "0.38.0",
		"items": [
			"The game speaks seven languages, chosen in Settings, and follows your phone language the first time.",
		],
	},
	{
		"version": "0.37.0",
		"items": [
			"Text in the cards, tower info and bottom bar is bigger and easier to read.",
		],
	},
	{
		"version": "0.36.0",
		"items": [
			"Enemies flash orange, green or lilac when hurt by heat, chemicals or the immune system, and every tower animates when it attacks.",
		],
	},
	{
		"version": "0.35.0",
		"items": [
			"The game runs on Android 7.0 or newer, capped at 60 frames per second and lighter on the battery.",
		],
	},
	{
		"version": "0.34.0",
		"items": [
			"The tissue moves like a living organ, the path beats like a heart, and infection turns it red.",
		],
	},
	{
		"version": "0.33.0",
		"items": [
			"Tap an enemy in the next-wave preview or on the level page to see its card.",
		],
	},
	{
		"version": "0.32.0",
		"items": [
			"The level list on the start screen scrolls with a drag, even over a level card.",
		],
	},
	{
		"version": "0.31.0",
		"items": [
			"The start screen has a six-page HOW TO PLAY tutorial.",
		],
	},
	{
		"version": "0.30.0",
		"items": [
			"Each level has a 3-minute track, and victory and defeat have their own tunes.",
		],
	},
	{
		"version": "0.29.0",
		"items": [
			"Volume controls and a mute switch in the settings.",
		],
	},
	{
		"version": "0.28.0",
		"items": [
			"The hypothalamus sends a red wave with flames and keeps attacking enemies that already burn.",
			"Burning enemies show flames.",
			"Clostridioides difficile dies, lies still and gets up again.",
		],
	},
	{
		"version": "0.27.0",
		"items": [
			"Amino acid orbs fly from the top bar to a new tower; pricier towers get more orbs.",
		],
	},
	{
		"version": "0.26.0",
		"items": [
			"Amino acids are counted only when their orb reaches the top bar.",
			"A new tower appears only when its amino acids arrive.",
		],
	},
	{
		"version": "0.25.0",
		"items": [
			"The build menu lists the towers from the cheapest to the dearest.",
			"The interferon mist only shows while the tower is attacking.",
		],
	},
	{
		"version": "0.24.0",
		"items": [
			"The Lungs level has more room at the top of the map.",
		],
	},
	{
		"version": "0.23.0",
		"items": [
			"The next wave starts within 5 seconds once the field is empty.",
		],
	},
	{
		"version": "0.22.1",
		"items": [
			"The top bar no longer wastes space above the title on phones with a camera cutout.",
		],
	},
	{
		"version": "0.22.0",
		"items": [
			"A changelog of every version, shown after each update and in the settings.",
		],
	},
	{
		"version": "0.21.0",
		"items": [
			"The Apolo Software logo glints with a spark and a chime on the splash screen.",
		],
	},
	{
		"version": "0.20.0",
		"items": [
			"New splash screen with the Apolo Software logo.",
			"How to play: a tutorial explains the goal, amino acids, towers and controls.",
			"Seven languages, chosen on the start screen.",
			"Volume and mute in the settings, and music of more than three minutes in every level.",
			"Victory and defeat tunes.",
			"Zoom the map with two fingers.",
			"The next wave starts 5 seconds after the field is cleared.",
			"Tap the enemies of the next wave to see their attributes.",
			"Amino acids count when their orbs reach the bar, and fly into new towers.",
			"The tissue moves, and turns red with pus as the body gets hurt.",
			"Hypothalamus and interferon animations, and colour flashes for each damage type.",
			"Bigger text, a bigger icon and a smoother start screen scroll.",
		],
	},
	{
		"version": "0.19.0",
		"items": [
			"The Bone Marrow keeps making neutrophils after one dies, each neutrophil holds one enemy, and enemies strike back.",
		],
	},
	{
		"version": "0.18.0",
		"items": [
			"Neutrophils play an attack animation and are drawn above the enemies.",
		],
	},
	{
		"version": "0.17.0",
		"items": [
			"Neutrophils from the Bone Marrow roam, fight and come back every 15 seconds.",
		],
	},
	{
		"version": "0.16.0",
		"items": [
			"Enemies marked by the B lymphocyte change colour.",
			"The game version is shown on the start screen.",
		],
	},
	{
		"version": "0.15.0",
		"items": [
			"The T lymphocyte charges and fires a thick beam with an explosion.",
			"The platelet holds up to 3 enemies.",
		],
	},
	{
		"version": "0.14.0",
		"items": [
			"Area attacks are visible: lysozyme rings, and platelet tendrils that hold enemies.",
		],
	},
	{
		"version": "0.13.0",
		"items": [
			"Hold a build card or a tower to see its attributes and which enemies it is good against.",
		],
	},
	{
		"version": "0.10",
		"items": [
			"A tidier start screen header.",
		],
	},
	{
		"version": "0.9",
		"items": [
			"Three difficulties (easy, medium and hard) and a balance pass on every level.",
		],
	},
	{
		"version": "0.7",
		"items": [
			"Levels 2 to 10 with new enemies, new towers, a level menu and saved progress.",
		],
	},
	{
		"version": "0.5",
		"items": [
			"A music loop for the level and a game icon.",
		],
	},
	{
		"version": "0.1",
		"items": [
			"First playable version: the throat level with its towers, enemies, sounds and music.",
		],
	},
]
