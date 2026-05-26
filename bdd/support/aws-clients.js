const { DynamoDBClient, DescribeTableCommand } = require('@aws-sdk/client-dynamodb');
const { SecretsManagerClient, DescribeSecretCommand } = require('@aws-sdk/client-secrets-manager');
const { SSMClient, GetParameterCommand } = require('@aws-sdk/client-ssm');

const LOCALSTACK_ENDPOINT = process.env.LOCALSTACK_ENDPOINT || 'http://localhost:4566';
const REGION = process.env.AWS_REGION || 'us-east-1';

const clientConfig = {
  region: REGION,
  endpoint: LOCALSTACK_ENDPOINT,
  credentials: { accessKeyId: 'test', secretAccessKey: 'test' }
};

module.exports = {
  dynamodb: new DynamoDBClient(clientConfig),
  secretsManager: new SecretsManagerClient(clientConfig),
  ssm: new SSMClient(clientConfig),
  DescribeTableCommand,
  DescribeSecretCommand,
  GetParameterCommand
};
