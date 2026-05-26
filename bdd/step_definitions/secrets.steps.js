const { Then } = require('@cucumber/cucumber');
const { expect } = require('chai');
const { findPlannedResources } = require('./dynamodb.steps');

Then('o plan deve conter um recurso {string} com sufixo {string}', function (type, suffix) {
  const found = findPlannedResources(this.terraformPlan, type);
  const matching = found.filter(r => (r.values.name || '').includes(suffix));
  expect(matching.length, `Nenhum recurso ${type} com sufixo "${suffix}" encontrado`).to.be.greaterThan(0);
  this._lastFoundResources = matching;
});

Then('o secret deve ter recovery_window_in_days igual a {int}', function (days) {
  const secret = this._lastFoundResources[0];
  expect(secret.values.recovery_window_in_days).to.equal(days);
});
