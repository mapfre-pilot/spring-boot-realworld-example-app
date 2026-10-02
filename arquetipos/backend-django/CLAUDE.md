At the start of each session, check the status of the `django-engineer`
skill and communicate the result to the user before doing anything else.

## 1. Check if `clai` is installed

```bash
clai --version
```

- If it returns a version → `clai` is ready. Go to step 2.
- If it returns `command not found` → respond to the user:
  > `clai` is not installed. See README.agents.md (section "Step 1a") to install it.

## 2. Check if the skill is installed

```bash
find .claude/skills -maxdepth 1 -name "django-engineer*" 2>/dev/null | grep -q . && echo "installed" || echo "not installed"
```

- If `installed` → load the skill and continue normally.
- If `not installed` → respond to the user:
  > The `django-engineer` skill is not installed. Run:
  > `clai skill install django-engineer --target claude-code`
