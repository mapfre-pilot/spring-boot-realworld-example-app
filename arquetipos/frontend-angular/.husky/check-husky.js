const { execSync } = require('child_process');
const fs = require('fs');

// Check if .git exists
if (!fs.existsSync('.git')) {
  console.log('Git is not initialized. Skipping Husky initialization.');
  process.exit(0);
}

// Check if .husky/_ directory exists
if (!fs.existsSync('.husky/_')) {
  console.log('Husky is not configured. Installing Husky...');
  try {
    execSync('pnpm exec husky install', { stdio: 'inherit' });
  } catch (error) {
    console.error('Failed to install Husky:', error);
    process.exit(1);
  }
} else {
  console.log('Husky is already configured. Skipping installation.');
}
