import { routerReducer as routing } from 'react-router-redux'
import { combineReducers } from 'redux'

import * as types from '../actions/types'
import authentication from './authentication.reducer'
import users from './user.reducer'
import registration from './registration.reducer'
import shipment from './shipment.reducer'
import alert from './alert.reducer'
import error from './error.reducer'
import admin from './admin.reducer'
import app from './app.reducer'
import document from './document.reducer'
import messaging from './messaging.reducer'
import bookingSummary from './bookingSummary.reducer'
import { tenant, selectedSubdomain } from './tenant.reducer'
import cookie from './cookie.reducer'
import remark from './remark.reducer'
import content from './content.reducer'
import bookingProcess from './bookingProcess.reducer'

const filter = (state = '', action) => {
  switch (action.type) {
    case types.FILTER:
      return action.filter
    default:
      return state
  }
}

const rootReducer = combineReducers({
  authentication,
  registration,
  users,
  alert,
  error,
  filter,
  bookingData: shipment,
  selectedSubdomain,
  tenant,
  admin,
  app,
  routing,
  remark,
  messaging,
  bookingSummary,
  document,
  cookie,
  content,
  bookingProcess
})

export default rootReducer
