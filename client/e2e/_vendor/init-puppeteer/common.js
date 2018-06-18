
export const LONG_TIMEOUT = 60000
export const TIMEOUT = 5000
export const SHORT_TIMEOUT = 100

export const waitForNetwork = {
  timeout: LONG_TIMEOUT,
  waitUntil: 'networkidle0'
}

export const getWaitCondition = condition => ({
  timeout: LONG_TIMEOUT,
  waitUntil: condition
})

export const waitForTimeout = ms => ({
  timeout: ms,
  waitUntil: 'networkidle0'
})
