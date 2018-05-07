export default function path (pathArr, obj) {
  if (obj === null || obj === undefined) {
    return undefined
  }
  let willReturn = obj
  let counter = 0

  const pathArrValue = typeof pathArr === 'string'
    ? pathArr.split('.')
    : pathArr

  while (counter < pathArrValue.length) {
    if (willReturn === null || willReturn === undefined) {
      return undefined
    }
    willReturn = willReturn[pathArrValue[counter]]
    counter += 1
  }

  return willReturn
}
