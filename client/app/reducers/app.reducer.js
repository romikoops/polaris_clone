import merge from 'lodash/merge'
import { appConstants } from '../constants'

export default function app (state = {}, action) {
  switch (action.type) {
    case appConstants.FETCH_CURRENCIES_REQUEST: {
      const currReq = merge({}, state, {
        loading: true
      })
      return currReq
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
    case appConstants.REFRESH_CURRENCIES_REQUEST: {
      const currReq = merge({}, state, {
        loading: true
      })
      return currReq
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
      const currReq = merge({}, state, {
        loading: true
      })
      return currReq
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
      const currReq = merge({}, state, {
        loading: true
      })
      return currReq
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
      const currSetSucc = merge({}, state, {
        currencies: action.payload,
        loading: false
      })
      return currSetSucc
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
