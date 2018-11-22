import merge from 'lodash/merge'
import { appConstants } from '../constants'

export default function app (state = {}, action) {
  switch (action.type) {
    case appConstants.SET_TENANT_REQUEST: {
      return state
    }
    case appConstants.SET_TENANT_SUCCESS: {
      const { tenants } = state
      if (!tenants) return state
      const ret = {
          ...state,
          tenant: action.payload.tenant
        }

      return ret
    }
    case appConstants.SET_TENANT_ERROR: {
      const err = merge({}, state, {
        error: action.payload
      })

      return err
    }
    case appConstants.OVERRIDE_TENANT_REQUEST: {
      return state
    }
    case appConstants.OVERRIDE_TENANT_SUCCESS: {
      const { tenants } = state
      const newTenant = tenants.filter(t => t.value.id === parseInt(action.payload, 10))[0]
      const ret = {
          ...state,
          tenant: newTenant.value
        }

      return ret
    }
    case appConstants.OVERRIDE_TENANT_ERROR: {
      const err = merge({}, state, {
        error: action.payload
      })

      return err
    }
    case appConstants.SET_TENANTS_REQUEST: {
      return state
    }
    case appConstants.SET_TENANTS_SUCCESS: {
      return {
        ...state,
        tenants: action.payload
      }
    }
    case appConstants.SET_TENANTS_ERROR: {
      const err = merge({}, state, {
        error: action.payload
      })

      return err
    }
    case appConstants.FETCH_CURRENCIES_REQUEST: {
      return state
    }
    case appConstants.FETCH_CURRENCIES_SUCCESS: {
      const currSucc = merge({}, state, {
        currencies: action.payload,
        loading: false
      })

      return currSucc
    }
    case appConstants.FETCH_CURRENCIES_ERROR: {
      const currErr = merge({}, state, {
        error: action.payload,
        loading: false
      })

      return currErr
    }
    case appConstants.FETCH_COUNTRIES_REQUEST: {
      return state
    }
    case appConstants.FETCH_COUNTRIES_SUCCESS: {
      return {
        ...state,
        countries: action.payload.countries,
        loading: false
      }
    }
    case appConstants.FETCH_COUNTRIES_FAILURE: {
      const errCountries = merge({}, state, {
        error: { countries: action.error },
        loading: false
      })

      return errCountries
    }
    case appConstants.REFRESH_CURRENCIES_REQUEST: {
      return state
    }
    case appConstants.REFRESH_CURRENCIES_SUCCESS: {
      const currSucc = merge({}, state, {
        currencyList: action.payload,
        loading: false
      })

      return currSucc
    }
    case appConstants.REFRESH_CURRENCIES_ERROR: {
      const currErr = merge({}, state, {
        error: action.payload,
        loading: false
      })

      return currErr
    }
    case appConstants.FETCH_CURRENCIES_FOR_BASE_REQUEST: {
      return state
    }
    case appConstants.FETCH_CURRENCIES_FOR_BASE_SUCCESS: {
      return {
        ...state,
        currencyList: action.payload,
        loading: false
      }
    }
    case appConstants.FETCH_CURRENCIES_FOR_BASE_ERROR: {
      const currErr = merge({}, state, {
        error: action.payload,
        loading: false
      })

      return currErr
    }
    case appConstants.TOGGLE_CURRENCIES_REQUEST: {
      return state
    }
    case appConstants.TOGGLE_CURRENCIES_SUCCESS: {
      const currSucc = merge({}, state, {
        currencyList: action.payload.rates,
        loading: false
      })

      return currSucc
    }
    case appConstants.TOGGLE_CURRENCIES_ERROR: {
      const currErr = merge({}, state, {
        error: action.payload,
        loading: false
      })

      return currErr
    }
    case appConstants.RECEIVE_TENANTS: {
      return {
        ...state,
        tenants: action.payload.data
      }
    }

    case appConstants.SET_CURRENCY_SUCCESS: {
      return {
        ...state,
        currencies: action.payload,
        loading: false
      }
    }
    case appConstants.SET_CURRENCY_ERROR: {
      const currSetErr = merge({}, state, {
        error: action.payload,
        loading: false
      })

      return currSetErr
    }
    case appConstants.SET_CURRENCY_REQUEST: {
      const currSetReq = merge({}, state, {
        loading: true
      })

      return currSetReq
    }
    default:
      return state
  }
}
