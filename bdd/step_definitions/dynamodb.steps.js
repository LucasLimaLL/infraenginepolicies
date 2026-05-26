const { Then } = require('@cucumber/cucumber');
const { expect } = require('chai');

function findPlannedResources(plan, type) {
  const out = [];
  const walk = (mod) => {
    (mod.resources || []).forEach(r => {
      if (r.type === type) out.push(r);
    });
    (mod.child_modules || []).forEach(walk);
  };
  if (plan && plan.planned_values && plan.planned_values.root_module) {
    walk(plan.planned_values.root_module);
  }
  return out;
}

Then('o plan deve conter um recurso {string}', function (type) {
  const found = findPlannedResources(this.terraformPlan, type);
  expect(found.length, `Nenhum recurso ${type} encontrado no plan`).to.be.greaterThan(0);
  this._lastFoundResources = found;
});

Then('a tabela planejada deve ter hash_key {string}', function (key) {
  const tables = findPlannedResources(this.terraformPlan, 'aws_dynamodb_table');
  expect(tables.length).to.be.greaterThan(0);
  expect(tables[0].values.hash_key).to.equal(key);
});

Then('a tabela planejada deve ter range_key {string}', function (key) {
  const tables = findPlannedResources(this.terraformPlan, 'aws_dynamodb_table');
  expect(tables[0].values.range_key).to.equal(key);
});

Then('a tabela planejada deve ter billing_mode {string}', function (mode) {
  const tables = findPlannedResources(this.terraformPlan, 'aws_dynamodb_table');
  expect(tables[0].values.billing_mode).to.equal(mode);
});

Then('a tabela planejada deve ter point-in-time recovery habilitado', function () {
  const tables = findPlannedResources(this.terraformPlan, 'aws_dynamodb_table');
  const pitr = tables[0].values.point_in_time_recovery;
  expect(pitr).to.be.an('array');
  expect(pitr[0].enabled).to.be.true;
});

Then('o plan deve configurar TTL no atributo {string}', function (attr) {
  const tables = findPlannedResources(this.terraformPlan, 'aws_dynamodb_table');
  const ttl = tables[0].values.ttl;
  expect(ttl).to.be.an('array');
  expect(ttl[0].attribute_name).to.equal(attr);
  expect(ttl[0].enabled).to.be.true;
});

module.exports = { findPlannedResources };
