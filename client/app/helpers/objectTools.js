import { has } from 'lodash'
import { camelize } from './stringTools'

export const isEmpty = obj => (
  Object.keys(obj).every(k => !Object.prototype.hasOwnProperty.call(obj, k))
)

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

export function areEqual (obj1, obj2) {
  if (typeof obj1 === 'object' && typeof obj2 === 'object') {
    return Object.keys(obj1).length === Object.keys(obj2).length && Object.keys(obj1).every(key => obj1[key] === obj2[key])
  }

  return null
}

export function isDefined (obj) {
  return typeof obj !== 'undefined'
}

export function toQueryString (obj, connect) {
  return Object.keys(obj).map(key => `${connect ? '&' : ''}${key}=${obj[key]}`).join('&')
}

export function dig (obj, keyArray) {
  const valueExists = has(obj, keyArray)
  if (!valueExists) return null
  let value = obj
  keyArray.forEach((key) => {
    value = value[key]
  })
  return value
}
