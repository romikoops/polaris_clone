import { success, info, error, warning } from 'log-symbols'
import chalk from 'chalk'
import boxen from 'boxen'
import gradient from 'gradient-string'

const options = {
  success: { iconFn: success, colorFn: chalk.green },
  info: { iconFn: info, colorFn: chalk.blue },
  error: { iconFn: error, colorFn: chalk.red },
  warning: { iconFn: warning, colorFn: chalk.yellow }
}

let counter = 0
export function log (input, label) {
  if (input === 'SEPARATOR') {
    return console.log(gradient.passion('________________________________________'))
  }
  if (counter++ % 12 === 0) {
    log('SEPARATOR')
  }
  if (label === 'SELECTOR') {
    return console.log(boxen(
      `${input.type} ${input.selector}`,
      { padding: 1, margin: 1, borderStyle: 'single' }
    ))
  }
  if (label === undefined) {
    return console.log(chalk.green.bold(input))
  }
  const { iconFn, colorFn } = options[label]

  console.log(iconFn, colorFn.bold(input))
}
