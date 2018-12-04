import fetch from 'isomorphic-fetch'
import * as Sentry from '@sentry/browser'
import { tenantConstants } from '../constants'
import { tenantService } from '../services/tenant.service'
import { alertActions } from './'
import { getTenantApiUrl } from '../constants/api.constants'

function requestTenant (subdomain) {
  return {
    type: tenantConstants.REQUEST_TENANT,
    subdomain
  }
}
function logOut () {
  return {
    type: tenantConstants.CLEAR_TENANT,
    subdomain: ''
  }
}

function receiveTenant (subdomain, json) {
  return {
    type: tenantConstants.RECEIVE_TENANT,
    subdomain,
    data: json,
    receivedAt: Date.now()
  }
}

function invalidateSubdomain (subdomain) {
  return {
    type: tenantConstants.INVALIDATE_SUBDOMAIN,
    subdomain
  }
}

function updateEmails (newEmails, tenant) {
  function request (tenantData) {
    return {
      type: tenantConstants.UPDATE_EMAILS_REQUEST,
      tenantData
    }
  }
  function success (emails) {
    return {
      type: tenantConstants.UPDATE_EMAILS_SUCCESS,
      payload: emails
    }
  }
  function failure (error) {
    return { type: tenantConstants.UPDATE_EMAILS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request(newEmails, tenant))

    tenantService.updateEmails(newEmails, tenant).then(
      (resp) => {
        const { emails } = resp.data
        dispatch(success(emails))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function updateReduxStore (payload) {
  return dispatch => dispatch({ type: 'GENERAL_UPDATE', payload })
}

const tenantActions = {
  requestTenant,
  logOut,
  receiveTenant,
  invalidateSubdomain,
  updateEmails,
  updateReduxStore
}

export default tenantActions
