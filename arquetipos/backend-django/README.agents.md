# AI Agents — Setup

## Required skill: `django-engineer`

This repository requires the `django-engineer` skill to generate or modify
code correctly. The skill contains the conventions, patterns, and best practices
for the MAPFRE Container Django archetype (Django 5.x · DRF · Poetry · Mapfre base images · OpenAPI · JWT).

---

## Step 1 — Check if `clai` is installed

Run in your terminal:

```bash
clai --version
```

- If you see a version number → **`clai` is installed**. Go to [Step 2](#step-2--install-the-skill).
- If you see `command not found` → **you need to install `clai`**. Follow [Step 1a](#step-1a--install-clai).

---

## Step 1a — Install `clai`

> If you already work with MAPFRE reference architectures that use Azure Artifacts
> for npm dependencies, you may already have the registry configured. In that case,
> skip to step 4.

### 1. Add the MAPFRE npm registry

**macOS / Linux:**
```bash
cat >> ~/.npmrc << 'NPMEOF'
@mapfre-tech:registry=https://pkgs.dev.azure.com/devopsmapfre/devopsmapfre/_packaging/releases/npm/registry/
always-auth=true
//pkgs.dev.azure.com/devopsmapfre/devopsmapfre/_packaging/releases/npm/registry/:username=mapfre
//pkgs.dev.azure.com/devopsmapfre/devopsmapfre/_packaging/releases/npm/registry/:_password=AZURE_TOKEN_BASE64_VALUE
//pkgs.dev.azure.com/devopsmapfre/devopsmapfre/_packaging/releases/npm/registry/:email=npm requires email to be set but does not use the value
NPMEOF
```

**Windows (PowerShell):**
```powershell
Add-Content -Path "$env:USERPROFILE\.npmrc" -Value @"
@mapfre-tech:registry=https://pkgs.dev.azure.com/devopsmapfre/devopsmapfre/_packaging/releases/npm/registry/
always-auth=true
//pkgs.dev.azure.com/devopsmapfre/devopsmapfre/_packaging/releases/npm/registry/:username=mapfre
//pkgs.dev.azure.com/devopsmapfre/devopsmapfre/_packaging/releases/npm/registry/:_password=AZURE_TOKEN_BASE64_VALUE
//pkgs.dev.azure.com/devopsmapfre/devopsmapfre/_packaging/releases/npm/registry/:email=npm requires email to be set but does not use the value
"@
```

### 2. Authenticate with Azure Artifacts

Generate a Personal Access Token (PAT) in Azure DevOps with **Packaging (Read)** permissions,
then encode it in Base64:

**macOS / Linux:**
```bash
export AZURE_TOKEN_BASE64=$(echo -n ":YOUR_PAT_HERE" | base64)
```

**Windows (PowerShell):**
```powershell
$env:AZURE_TOKEN_BASE64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(":YOUR_PAT_HERE"))
```

### 3. Authenticate GitHub CLI

```bash
gh auth login
```

### 4. Install `clai`

```bash
npm install -g @mapfre-tech/clai
```

### Verification

```bash
clai --version
```

---

## Step 2 — Install the skill

Once `clai` is installed, run the command for your tool:

```bash
# GitHub Copilot
clai skill install django-engineer

# Claude Code
clai skill install django-engineer --target claude-code

# OpenCode
clai skill install django-engineer --target opencode
```

Once installed, load the skill before responding to any code task in this repository.
