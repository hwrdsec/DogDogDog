# Dog sprites

Drop replaceable PNG (or WebP) files here using the catalog names:

| File | Level |
| --- | --- |
| `dog_01.png` … `dog_08.png` | merge tiers 1–8 |

Until artwork lands, gameplay uses `DogDefinition.color` + `emoji`. Paths are
already set on each catalog entry via `spriteAsset`; loaders can opt in later
without changing merge or physics code.
