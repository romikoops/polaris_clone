import { camelize } from './stringTools'

export const isEmpty = (obj) => {
  let returnBool = true
  Object.keys(obj).forEach((key) => {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      returnBool = false
    }
  })
  return returnBool
}

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
