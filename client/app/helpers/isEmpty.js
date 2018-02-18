export function isEmpty (obj) {
  Object.keys(obj).every(k => !Object.prototype.hasOwnProperty.call(obj, k))
}
export default isEmpty
