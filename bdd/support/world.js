const { setWorldConstructor, World } = require('@cucumber/cucumber');

class CustomWorld extends World {
  constructor(options) {
    super(options);
    this.terraformOutput = null;
    this.terraformPlan = null;
    this.terraformExitCode = null;
    this.lastError = null;
    this.environment = 'local';
    this.variables = {};
  }
}

setWorldConstructor(CustomWorld);
