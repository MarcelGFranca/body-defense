## Decisions

- English text is the CSV key, so a missing row falls back to English and Labels translate themselves.
- Tutorial paragraphs are separate keys (no newlines in keys).
- Verified on the emulator: Spanish, and Chinese and Japanese glyphs through the system font.
- Known cosmetic issue: accented capitals (Ó, Á) come from the system font because the pixel font lacks them, so they look slightly different.
