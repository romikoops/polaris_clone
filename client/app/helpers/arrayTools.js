export function onlyUnique (value, index, self) {
  return self.indexOf(value) === index
}
export function concatArrays (first, second) {
  const array = first.concat(second)
  const uniqItems = Array.from(new Set(array))

  return uniqItems
}

export function uniqueItems (array) {
  const uniqItems = [...new Set(array.flat())]
  return uniqItems
}

export function uniqueObjects (array, prop) {
  return array.filter((obj, pos, arr) => arr.map(mapObj => mapObj[prop]).indexOf(obj[prop]) === pos)
}
