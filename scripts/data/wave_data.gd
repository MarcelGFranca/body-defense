class_name WaveData
extends Resource

## Seconds on the level clock at which the wave starts.
@export var start_time: float = 0.0
@export var spawn_interval: float = 1.0
## Each entry is {"enemy": id, "count": n}; entries spawn one after the other.
@export var entries: Array = []
