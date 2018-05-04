/* eslint-disable */
export function pick (keys, obj) {
  if (obj === null || obj === undefined) {
    return undefined
  }
  const keysValue = typeof keys === 'string'
    ? keys.split(',')
    : keys

  const willReturn = {}
  let counter = 0

  while (counter < keysValue.length) {
    if (keysValue[counter] in obj) {
      willReturn[keysValue[counter]] = obj[keysValue[counter]]
    }
    counter++
  }

  return willReturn
}

export function any (fn, arr) {
  let counter = 0

  while (counter < arr.length) {
    if (fn(arr[counter])) {
      return true
    }
    counter++
  }

  return false
}

export function uniqWith (fn, arr) {
  let index = -1
  const len = arr.length
  const willReturn = []

  while (++index < arr.length) {
    const value = arr[index]
    const flag = any(willReturnInstance => fn(value, willReturnInstance), willReturn)

    if (!flag) {
      willReturn.push(value)
    }
  }

  return willReturn
}
/* eslint-enable */
