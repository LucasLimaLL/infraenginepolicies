const { execSync, spawnSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const TERRAFORM_DIR = path.resolve(__dirname, '../..');

function run(command, args = [], options = {}) {
  const result = spawnSync('terraform', [command, ...args], {
    cwd: TERRAFORM_DIR,
    encoding: 'utf-8',
    env: { ...process.env, TF_IN_AUTOMATION: 'true' },
    ...options
  });
  return {
    stdout: result.stdout || '',
    stderr: result.stderr || '',
    exitCode: result.status,
    success: result.status === 0
  };
}

function init() {
  return run('init', ['-backend=false', '-input=false', '-no-color']);
}

function validate() {
  return run('validate', ['-no-color', '-json']);
}

function plan(vars = {}) {
  const varArgs = Object.entries(vars).flatMap(([k, v]) => ['-var', `${k}=${v}`]);
  return run('plan', ['-no-color', '-input=false', '-detailed-exitcode', ...varArgs]);
}

function planJson(vars = {}) {
  // gera plan binário e converte para JSON estruturado
  const varArgs = Object.entries(vars).flatMap(([k, v]) => ['-var', `${k}=${v}`]);
  const planFile = path.join(TERRAFORM_DIR, '.bdd-tmp.tfplan');
  const planResult = run('plan', ['-no-color', '-input=false', '-out', planFile, ...varArgs]);
  if (!planResult.success) return { ...planResult, planJson: null };

  const showResult = run('show', ['-json', planFile]);
  let parsedPlan = null;
  try { parsedPlan = JSON.parse(showResult.stdout); } catch (_) {}

  try { fs.unlinkSync(planFile); } catch (_) {}

  return { ...planResult, planJson: parsedPlan };
}

module.exports = { run, init, validate, plan, planJson };
