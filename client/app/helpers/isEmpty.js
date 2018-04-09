export function isEmpty (obj) {
  return !Object.keys(obj).some(key => Object.prototype.hasOwnProperty.call(obj, key))
}
export default isEmpty
