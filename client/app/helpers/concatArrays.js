function concatArrays (first, second) {
  const array = first.concat(second)
  const uniqItems = Array.from(new Set(array))

  return uniqItems
}
export default concatArrays
