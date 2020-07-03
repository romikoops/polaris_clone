import merge from 'lodash/merge'
import { appConstants } from '../constants'


export default function app (state = {}, action) {
  switch (action.type) {
    case appConstants.LAST_ACTIVITY: {
      return {
        ...state,
        lastActivity: action.payload
      }
    }
    case appConstants.SET_ORGANIZATION_REQUEST: {
      return state
    }
    case appConstants.SET_ORGANIZATION_SUCCESS: {
      return {
        ...state,
        tenant: action.payload.tenant
      }
    }
    case appConstants.SET_ORGANIZATION_ERROR: {
      const err = merge({}, state, {
        error: action.payload
      })

      return err
    }

    case appConstants.OVERRIDE_ORGANIZATION_REQUEST: {
      return state
    }

    case appConstants.OVERRIDE_ORGANIZATION_SUCCESS: {
      return {
        tenants: state.tenants
      }
    }

    case appConstants.OVERRIDE_ORGANIZATION_ERROR: {
      const err = merge({}, state, {
        error: action.payload
      })

      return err
    }
    case appConstants.SET_ORGANIZATIONS_REQUEST: {
      return state
    }
    case appConstants.SET_ORGANIZATIONS_SUCCESS: {
      return {
        ...state,
        tenants: action.payload
      }
    }
    case appConstants.SET_ORGANIZATIONS_ERROR: {
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
    case appConstants.RECEIVE_ORGANIZATIONS: {
      return {
        ...state,
        tenants: action.payload.data
      }
    }

    case appConstants.FETCH_SCOPE_SUCCESS: {
      return {
        ...state,
        tenant: {
          ...state.tenant,
          scope: action.payload
        }
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
