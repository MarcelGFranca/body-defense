## Decisions

Flames are polygons drawn in code (a red teardrop with a yellow core), so no new art and no particles. They update only while an enemy burns.

The burn was already refreshed every step while an enemy stays in range; the tower only animated on a new ignition. A FEVER_INTERVAL (1 s) clock now repeats the attack effects, so damage and balance are unchanged.
