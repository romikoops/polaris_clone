import * as types from './types'

export * from './alert.actions'
export * from './user.actions'
export * from './authentication.actions'
export * from './shipment.actions'
export * from './admin.actions'
export * from './app.actions'
export * from './messaging.actions'
export { default as bookingSummaryActions } from './bookingSummary.actions'
export * from './document.actions'

export function filterTable (filter) {
  return {
    type: types.FILTER,
    filter
  }
}

export function setTenant (tenant) {
  return {
    type: types.SET_TENANT,
    tenant
  }
}
