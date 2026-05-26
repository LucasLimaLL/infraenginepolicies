const { Before, After, BeforeAll, AfterAll } = require('@cucumber/cucumber');
const fs = require('fs');
const path = require('path');

BeforeAll(async function () {
  const reportsDir = path.resolve(__dirname, '../reports');
  if (!fs.existsSync(reportsDir)) fs.mkdirSync(reportsDir, { recursive: true });
});

Before(function (scenario) {
  this.environment = 'local';
  this.variables = {};
  this.terraformOutput = null;
  this.terraformPlan = null;
  this.lastError = null;
});

After(function (scenario) {
  // limpeza de arquivos temporários
  const tmpPlan = path.resolve(__dirname, '../../.bdd-tmp.tfplan');
  if (fs.existsSync(tmpPlan)) {
    try { fs.unlinkSync(tmpPlan); } catch (_) {}
  }
});

AfterAll(function () {
  // não destruímos o state — a infra é mantida para inspeção manual se desejado
});
