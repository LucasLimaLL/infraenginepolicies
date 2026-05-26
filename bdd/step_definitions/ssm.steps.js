const { Then } = require('@cucumber/cucumber');
const { expect } = require('chai');
const { findPlannedResources } = require('./dynamodb.steps');

Then('o plan deve conter um parâmetro SSM com nome contendo {string}', function (substring) {
  const params = findPlannedResources(this.terraformPlan, 'aws_ssm_parameter');
  const matching = params.filter(p => (p.values.name || '').includes(substring));
  expect(matching.length, `Nenhum parâmetro SSM com "${substring}" no nome`).to.be.greaterThan(0);
  this._lastFoundResources = matching;
});

Then('o valor do parâmetro deve estar entre {int} e {int}', function (min, max) {
  const param = this._lastFoundResources[0];
  const value = parseInt(param.values.value, 10);
  expect(value).to.be.gte(min).and.lte(max);
});
