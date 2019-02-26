import mapKeysDeep from 'map-keys-deep-lodash'
import { camelize, camelToSnakeCase } from './stringTools'

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

export function deepCamelizeKeys (obj) {
  return mapKeysDeep(obj, (_, key) => camelize(key))
}

export function deepSnakefyKeys (obj) {
  return mapKeysDeep(obj, (_, key) => camelToSnakeCase(key))
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
