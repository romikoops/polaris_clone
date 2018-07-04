const path = require('path')
const { spawnSync } = require('child_process')
/* eslint-disable import/no-extraneous-dependencies */
const { CLIEngine } = require('eslint')
/* eslint-enable import/no-extraneous-dependencies */

const eslint = new CLIEngine({
  configFile: path.join(__dirname, '..', '.eslintrc'),
  ignorePath: path.join(__dirname, '..', '.eslintignore'),
  reportUnusedDisableDirectives: true
})

const { status, output } = spawnSync('git', [
  'diff', '--cached', '--name-status'
], {
  encoding: 'utf-8',
  cwd: path.join(__dirname, '..', '..')
})

if (status !== 0) {
  console.error('failed to get changeset!')
  if (output[2].length > 0) {
    console.error(output[2])
  }
  process.exit(status)
}

const files = output[1].split('\n').filter(l => l.length > 0).map((l) => {
  const [modifier, file] = l.split('\t', 2)
  return { file, modifier }
})

const failed = !files.every(({ file, modifier }) => {
  if (!file.startsWith('client/')) {
    return true
  }

  // DELETED
  if (modifier === 'D') {
    return true
  }

  console.log(' - Checking', file, '...')

  if ('ACMR'.split('').indexOf(modifier) < 0) {
    console.error('Unknown modifier', modifier)
    return false
  }

  const ext = path.extname(file)
  switch (ext) {
    case '.js':
    case '.mjs':
    case '.jsx':
    case '.json': {
      const fpath = path.resolve(path.join(__dirname, '..', '..'), file)
      const { errorCount, warningCount } = eslint.executeOnFiles([fpath])
      if (errorCount > 0) {
        console.error('   eslint found', errorCount, 'error(s), aborting commit.')
        return false
      }

      if (warningCount > 0) {
        console.warn('   eslint found', warningCount, 'warnings, continuing. Before pushing, please fix those warnings.')
      } else {
        console.info('   Nothing found, good job!')
      }
      return true
    }

    default:
      console.log('   Non-JavaScript related extension found, ignoring')
      return true
  }
})

if (failed) {
  console.error('Please run `npm run eslint-file $filename` to see more details about the errors!')
  console.error('To fix most errors, run `npm run eslint-file --fix $filename`.')
  process.exit(1)
} else {
  console.info('eslint is not complaining, good job!')
}
