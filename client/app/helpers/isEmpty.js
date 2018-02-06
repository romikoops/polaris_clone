export function isEmpty (obj) {
  return Object.keys(obj).every(key => Object.prototype.hasOwnProperty.call(obj, key))
}

export default isEmpty
