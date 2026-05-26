const { Given, When, Then } = require('@cucumber/cucumber');
const { expect } = require('chai');
const terraform = require('../support/terraform-runner');

Given('que defino a variável {string} como {string}', function (key, value) {
  this.variables[key] = value;
});

Given('que defino o environment como {string}', function (env) {
  this.environment = env;
  this.variables.environment = env;
});

When('executo {string}', async function (commandLabel) {
  // executa init primeiro se necessário
  if (!this._initialized) {
    terraform.init();
    this._initialized = true;
  }
  if (commandLabel.includes('validate')) {
    this.terraformOutput = terraform.validate();
  } else if (commandLabel.includes('plan')) {
    this.terraformOutput = terraform.plan(this.variables);
  }
});

When('executo "terraform plan" em modo JSON', async function () {
  if (!this._initialized) {
    terraform.init();
    this._initialized = true;
  }
  this.terraformOutput = terraform.planJson(this.variables);
  this.terraformPlan = this.terraformOutput.planJson;
});

Then('o comando deve ter sucesso', function () {
  expect(this.terraformOutput.success, `stderr: ${this.terraformOutput.stderr}`).to.be.true;
});

Then('o comando deve falhar', function () {
  expect(this.terraformOutput.success).to.be.false;
});

Then('a saída deve conter {string}', function (substring) {
  const combined = (this.terraformOutput.stdout || '') + '\n' + (this.terraformOutput.stderr || '');
  expect(combined).to.include(substring);
});

Then('a saída deve indicar configuração válida', function () {
  try {
    const parsed = JSON.parse(this.terraformOutput.stdout);
    expect(parsed.valid).to.be.true;
  } catch (_) {
    expect(this.terraformOutput.stdout).to.include('Success');
  }
});

Then('o plan deve ser gerado sem erros de validação', function () {
  expect(this.terraformOutput.success).to.be.true;
});
