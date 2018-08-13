const { existsSync } = require('fs')
const { log } = require('log')
const looksSame = require('./_vendor/looks-same')

const SCREEN_DIR = `${__dirname}/node_modules`
const [, , label, toleranceInput] = process.argv
const tolerance = toleranceInput === undefined ? 0 : toleranceInput

const base = `${SCREEN_DIR}/${label}.png`
const compareTo = `${SCREEN_DIR}/${label}.to.compare.png`
const diff = `${SCREEN_DIR}/${label}.diff.png`

function compare () {
  if (!existsSync(base) || !existsSync(base)) {
    log('Files do not exists', 'error')

    return
  }
  looksSame(
    base,
    compareTo,
    { tolerance },
    (err, numberOfDiffPixels) => {
      if (err !== null) {
        throw err
      }

      if (numberOfDiffPixels === 0) {
        return log(`'${label}' successful visual regression testing`, 'success')
      }

      /**
       * `false` indicates images with different size, so we skip the creation of diff image
       */
      if (numberOfDiffPixels === false) {
        return
      }
      log(`'${label}' has ${numberOfDiffPixels} pixels difference in visual regression testing`, 'warning')
      log(`Building a diff image. It will take some time, please be patient!`, 'info')

      if (existsSync(diff)) {
        unlinkSync(diff)
      }

      looksSame.createDiff({
        reference: base,
        current: compareTo,
        diff,
        highlightColor: '#ff00ff',
        strict: false
      }, (diffErr) => {
        if (diffErr !== null) {
          throw diffErr
        }
        log('Diff image is created', diff, 'success')
      })
    }
  )
}

compare()
