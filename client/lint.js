const { exec } = require('child_process')
const { resolve } = require('path')

const DIR = resolve('..', __dirname)

function lintFile (filepath) {
  return new Promise((resolve, reject) => {
    const command = `yarn eslint-file ${filepath} --fix`
    const proc = exec(command, { cwd: __dirname })

    proc.stdout.on('data', (chunk) => {
      console.log(chunk.toString())
    })
    proc.stdout.on('end', () => resolve())
    proc.stdout.on('error', err => reject(err))
  })
}

function getModified () {
  return new Promise((resolve, reject) => {
    const proc = exec('git status', { cwd: DIR })
    let modified

    proc.stdout.on('data', (chunk) => {
      const log = chunk.toString().trim()

      const lines = log.split('\n').map(x => x.trim())

      modified = lines
        .filter(line => line.includes('modified:') || line.includes('new file:'))
        .map(line => line.replace('modified:', ''))
        .map(line => line.replace('new file:', ''))
        .filter(line => line.endsWith('.js') || line.endsWith('.jsx'))
        .filter(line => !line.includes('webpack'))
        .map(line => line.trim())
    })
    proc.stdout.on('end', () => resolve(modified))
    proc.stdout.on('error', err => reject(err))
  })
}

void (async function lint () {
  console.time('lint')
  const modified = await getModified()

  for (const filepath of modified) {
    console.log(filepath)
    console.log('__________________')
    await (lintFile(filepath))
  }

  console.log('===================')
  console.log(modified)

  console.timeEnd('lint')
}())
