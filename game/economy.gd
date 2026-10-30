## Owns the currency balances. Registered as the `Economy` autoload.
extends Node

signal balance_changed(currency: String, value: int)

const AMINO_ACIDS := "amino_acids"
const CONFIG_PATH := "res://data/economy.tres"

var config: EconomyConfig
var _balances: Dictionary = {AMINO_ACIDS: 0}


func _ready() -> void:
	_load_config()


func _load_config() -> void:
	if config == null:
		config = load(CONFIG_PATH) as EconomyConfig
	if config == null:
		config = EconomyConfig.new()


func reset(starting_amino_acids: int) -> void:
	_load_config()
	_balances = {AMINO_ACIDS: maxi(0, starting_amino_acids)}
	balance_changed.emit(AMINO_ACIDS, starting_amino_acids)


func balance(currency: String = AMINO_ACIDS) -> int:
	return int(_balances.get(currency, 0))


func add(amount: int, currency: String = AMINO_ACIDS) -> void:
	if amount <= 0:
		return
	_balances[currency] = balance(currency) + amount
	balance_changed.emit(currency, balance(currency))


## Spends `amount` only if the whole cost is covered. Returns whether it worked.
func try_spend(amount: int, currency: String = AMINO_ACIDS) -> bool:
	if amount < 0 or balance(currency) < amount:
		return false
	_balances[currency] = balance(currency) - amount
	balance_changed.emit(currency, balance(currency))
	return true


## Amino acids returned when selling a tower that cost `total_spent` in total.
func refund_for(total_spent: int) -> int:
	_load_config()
	return floori(total_spent * config.refund_fraction + 0.0001)
