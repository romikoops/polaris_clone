import {success, info, error, warning} from 'log-symbols'
import chalk from 'chalk'

const options = {
  success: {iconFn: success, colorFn:chalk.green }, 
  info: {iconFn: info, colorFn:chalk.blue }, 
  error: {iconFn: error, colorFn:chalk.red }, 
  warning: {iconFn: warning, colorFn:chalk.yellow }
}

export function log (input, label) {
  if (label === undefined) {
    return console.log(chalk.green.bold(input))
  }
  const {iconFn, colorFn} = options[label]

  console.log(iconFn, colorFn.bold(input))
}
