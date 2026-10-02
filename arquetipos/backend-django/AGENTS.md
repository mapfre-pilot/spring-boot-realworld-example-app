Before generating or modifying any code in this repository, check if the
`django-engineer` skill is installed and load it.

## 1. Check if `clai` is installed

```bash
clai --version
```

- If it returns a version → `clai` is ready. Go to step 2.
- If it returns `command not found` → install `clai` following the instructions
  in [README.agents.md](README.agents.md) (section "Step 1a — Install clai").

## 2. Install the skill

```bash
clai skill install django-engineer --target opencode
```

## 3. Load the skill

Once installed, the skill will be available in `.opencode/skills/`. Load it
automatically at the start of each session in this repository.
