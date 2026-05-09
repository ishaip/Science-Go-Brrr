# Factorio Mod Creation Guide

> **Rule: every time you update a mod, bump the version in `info.json` and add an entry to `changelog.txt`.**

---

## 1. Folder Structure

```
my-mod-name/
├── info.json                     <- mod
├── changelog.txt                 <- mod
├── data.lua                      <- mod
├── data-updates.lua              <- mod
├── data-final-fixes.lua          <- mod
├── control.lua                   <- mod
├── settings.lua                  <- mod
├── README.md                     <- mod
├── mod-portal-description.md     <- mod
├── LICENSE                       <- mod
├── locale/
│   └── en/
│       └── locale.cfg            <- mod
├── mod-deployment-script.bat     <- dev launcher (NOT shipped to Factorio)
└── .github/
    └── new-mod-guide.md          <- dev docs (NOT shipped to Factorio)
```

> Files marked **dev launcher** live in the repo but are excluded by the deployment script and never end up in the zip sent to Factorio.

---

## 2. `info.json` Template

```json
{
  "name": "mod-internal-name",
  "version": "1.0.0",
  "title": "Mod Display Title",
  "author": "ishaip",
  "homepage": "https://github.com/ishaip/REPO-NAME",
  "description": "One-line description of what the mod does.",
  "factorio_version": "2.0",
  "quality_required": false,
  "space_travel_required": false,
  "spoiling_required": false,
  "freezing_required": false,
  "segmented_units_required": false
}
```

- `name` must be lowercase, hyphens allowed, no spaces — this is also the zip folder name.
- `version` must match the top entry in `changelog.txt`.

---

## 3. `changelog.txt` Format

Factorio requires a strict format. Always add a new block at the **top**:

```
---------------------------------------------------------------------------------------------------
Version: 1.0.0
Date: DD. MM. YYYY
  Features:
    - Initial release
---------------------------------------------------------------------------------------------------
```

Accepted section headers: `Features`, `Bugfixes`, `Info`, `Changes`, `Optimizations`, `Graphics`, `Scripting`.

---

## 4. File Responsibilities

| File | Stage | Purpose |
|---|---|---|
| `data.lua` | Data | Prototype definitions (usually empty if only modifying existing) |
| `data-updates.lua` | Data-updates | Modifications that depend on other mods loading first |
| `data-final-fixes.lua` | Data-final-fixes | Last-pass modifications; use for overriding base-game values |
| `control.lua` | Runtime | Event handlers, commands, on_init/on_load logic |
| `settings.lua` | Settings | `data:extend` calls adding mod settings |
| `locale/en/locale.cfg` | — | Localisation strings |

If a stage is not needed, leave the file with a comment explaining why — do not delete it (Factorio expects them to exist if listed in the load order via `require`).

---

## 5. `locale/en/locale.cfg` Template

```ini
[mod-name]
mod-internal-name=Mod Display Title

[mod-description]
mod-internal-name=One-line description of what the mod does.

[mod-setting-name]
setting-key=Setting Display Name

[mod-setting-description]
setting-key=What this setting controls.
```

---

## 6. Settings Template (`settings.lua`)

```lua
data:extend({
  {
    type = "bool-setting",        -- or "int-setting", "double-setting", "string-setting"
    name = "mod-internal-name-setting-key",
    setting_type = "startup",     -- "startup" | "runtime-global" | "runtime-per-user"
    default_value = true,
  },
})
```

---

## 7. Git Setup

```bash
git init
git remote add origin https://github.com/ishaip/REPO-NAME.git
git add .
git commit -m "Initial release v1.0.0"
git push -u origin main
```

After renaming a GitHub repo, update `.git/config`:
```
[remote "origin"]
    url = https://github.com/ishaip/NEW-REPO-NAME.git
```

---

## 8. Deployment Script

Copy `mod-deployment-script.bat` from an existing mod. It:
1. Reads the version from the top of `changelog.txt`
2. Reads `name` from `info.json`
3. **Syncs the `version` field in `info.json`** to match `changelog.txt` automatically
4. Creates `modname_version/` folder, copies all mod files (skips `.git`, `.github`, `.vscode`, `mod-deployment-script.bat`)
5. **Removes all previous versions** of this mod from `%APPDATA%\Factorio\mods\` before installing
6. Zips it and copies the new version to `%APPDATA%\Factorio\mods\`

Run it from inside the mod folder.

> **Workflow:** just bump the version in `changelog.txt`, run the script — `info.json` and the mods folder are handled automatically.

---

## 9. Update Checklist

Before every commit that changes mod behaviour:

- [ ] Bump `version` in `info.json` (this is the source of truth)
- [ ] Add entry at top of `changelog.txt` with the **same** version and today's date
- [ ] Run `mod-deployment-script.bat` — it will error if the two versions don't match
- [ ] Commit and push
- [ ] Upload zip to Factorio mod portal if publishing
