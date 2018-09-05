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

export function log (input, label) {
  if (label === 'SELECTOR') {
    const selector = typeof input.selector === 'string'
      ? input.selector
      : JSON.stringify(input.selector)

    return console.log(boxen(
      `${input.type} ${selector}`,
      { padding: 0, margin: 0, borderStyle: 'double' }
    ))
  }
  if (label === undefined) {
    return console.log(chalk.green.bold(input))
  } else if (label === 'gradient') {
    return console.log(gradient.passion(input))
  }
  const { iconFn, colorFn } = options[label]

  console.log(iconFn, colorFn.bold(input))
}
