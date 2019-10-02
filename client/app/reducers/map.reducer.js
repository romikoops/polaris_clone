import merge from 'lodash/merge'
import { mapConstants } from '../constants'

export default function map (state = {}, action) {
  switch (action.type) {
    case mapConstants.GET_MAP_DATA_REQUEST: {
      return state
    }
    case mapConstants.GET_MAP_DATA_SUCCESS: {
      return {
        ...state,
        geojsons: action.payload
      }
    }
    case mapConstants.GET_MAP_DATA_ERROR: {
      const err = merge({}, state, {
        error: action.payload
      })

      return err
    }
    case mapConstants.GET_EDITOR_MAP_DATA_REQUEST: {
      return { ...state, fetching: true }
    }
    case mapConstants.GET_EDITOR_MAP_DATA_SUCCESS: {
      return {
        ...state,
        editor: action.payload,
        fetching: false
      }
    }
    case mapConstants.GET_EDITOR_MAP_DATA_ERROR: {
      return {
        ...state,
        error: action.payload,
        fetching: false
      }
    }
    case mapConstants.GET_GEOJSON_REQUEST: {
      return state
    }
    case mapConstants.GET_GEOJSON_SUCCESS: {
      return {
        ...state,
        geojson: action.payload
      }
    }
    case mapConstants.GET_GEOJSON_ERROR: {
      const err = merge({}, state, {
        error: action.payload
      })

      return err
    }
    default:
      return state
  }
}
