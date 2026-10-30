## Decisions

- **A shader, not `modulate`.** Multiplying the sprite by purple turned green and blue enemies dull grey (tried and rejected, seen in the screenshots). The shader mixes 80% of the lymphocyte color, scaled by the brightness of each pixel, so eyes and outlines stay readable.
- **The status owns the color.** `EnemyStatus.apply_mark` receives the color of the tower, so a second marking tower would dye in its own color and the enemy needs no knowledge of towers. A new mark refreshes the color together with the duration.
- **The material is created the first time an enemy is marked**, so unmarked enemies keep the plain default material.
