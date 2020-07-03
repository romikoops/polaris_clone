import * as types from './types'

export * from './alert.actions'
export * from './user.actions'
export { default as authenticationActions } from './authentication.actions'
export * from './shipment.actions'
export * from './content.actions'
export * from './admin.actions'
export * from './error.actions'
export * from './app.actions'
export { default as bookingSummaryActions } from './bookingSummary.actions'
export * from './document.actions'
export * from './tenant'
export { default as mapActions } from './map.actions'
export { default as tenantActions } from './tenant.actions'
export { default as clientsActions } from './clients.actions'
export { default as remarkActions } from './remark.actions'
export { default as bookingProcessActions } from './bookingProcess.actions'

export function filterTable (filter) {
  return {
    type: types.FILTER,
    filter
  }
}

export function setTenant (tenant) {
  return {
    type: types.SET_ORGANIZATION,
    tenant
  }
}
