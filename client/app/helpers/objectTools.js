import { camelize } from './stringTools'

export const isEmpty = obj =>
  Object.keys(obj).every(k => !Object.prototype.hasOwnProperty.call(obj, k))

export const camelizeKeys = (obj) => {
  const newObj = {}
  Object.keys(obj).forEach((k) => {
    newObj[camelize(k)] = obj[k]
  })
  return newObj
}

export const deepCamelizeKeys = (obj) => {
  if (!obj || Object.keys(obj).length === 0) return obj

  const newObj = {}
  Object.keys(obj).forEach((k) => {
    newObj[camelize(k)] = deepCamelizeKeys(obj[k])
    console.log(newObj)
  })
  return newObj
}
