const AWS = require('aws-sdk');
const crypto = require('crypto');
const fs = require('fs-extra');
const path = require('path');
const { execSync } = require('child_process');
const version = require('../package.json').version;
const logger = require('../src/util/logger');

if (process.argv[2] === undefined) {
  throw new Error(
    'Environment not set! Supported environments: dev, qa, and prod'
  );
}

const env = process.argv[2].toLowerCase();
if (!['dev', 'qa', 'prod'].includes(env)) {
  throw new Error(
    'Invalid environment! Supported environments: dev, qa, and prod'
  );
}
const S3_BUCKET = `alwaysai-artifacts-${env}`;

const isGitEnvDirty = execSync('git status --porcelain').length !== 0;
if (isGitEnvDirty === true) {
  throw new Error('Not publishing due to dirty git environment');
}
/* NOTE: Skip requiring release tag for now
if (env === 'prod') {
  try {
    const tag = execSync('git describe --tags --exact-match HEAD');
    if (tag.toString() === '') {
      throw new Error('Not publishing to production due to no git tag found');
    }
  } catch (e) {
    throw new Error('Not publishing to production due to no git tag found');
  }
}
*/

logger.info(`Publishing to ${env} environment`);

function configS3() {
  AWS.config.update({ region: 'us-west-1' });
  return new AWS.S3({ apiVersion: '2006-03-01' });
}

function uploadToS3(s3, filename, filePath) {
  const uploadParams = { Bucket: S3_BUCKET, Key: '', Body: '' };
  const fileStream = fs.createReadStream(filePath);
  fileStream.on('error', function (err) {
    throw new Error(err);
  });
  uploadParams.Body = fileStream;
  uploadParams.Key = `device-agent/${filename}`;

  s3.upload(uploadParams, function (err, data) {
    if (err) {
      throw new Error(err);
    }
    if (data) {
      logger.info('Upload Success', data.Location);
    }
  });
}

function writeVersionHeader(filename, filePath, dateTime, version, gitHash) {
  const distDir = path.join('.', 'dist');
  fs.mkdirSync(distDir, { recursive: true });
  const distFilePath = path.join(distDir, filename);
  fs.copyFileSync(filePath, distFilePath);

  var data = fs.readFileSync(distFilePath).toString().split('\n');
  data.splice(
    11, // Write these lines after the shebang and initial header
    0,
    `#\n# Published: ${dateTime}\n# Version: ${version}\n# Git Hash: ${gitHash}\n`
  );
  const text = data.join('\n');

  fs.writeFileSync(distFilePath, text, function (err) {
    if (err) return err;
  });
  return distFilePath;
}

const s3 = configS3();

const gitHash = execSync('git rev-parse HEAD').toString().trim();
dateTime = new Date().toLocaleString();

const scripts = ['install-device-agent.sh', 'provision.sh'];
scripts.forEach(function (filename) {
  const filePath = path.join('.', 'scripts', filename);
  const distFilePath = writeVersionHeader(
    filename,
    filePath,
    dateTime,
    version,
    gitHash
  );
  uploadToS3(s3, filename, distFilePath);
});
