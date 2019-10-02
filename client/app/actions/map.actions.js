import { mapConstants } from '../constants'
import { mapService } from '../services'

function getMapData (id) {
  function request (mapData) {
    return { type: mapConstants.GET_MAP_DATA_REQUEST, payload: mapData }
  }
  function success (mapData) {
    return { type: mapConstants.GET_MAP_DATA_SUCCESS, payload: mapData.data }
  }
  function failure (error) {
    return { type: mapConstants.GET_MAP_DATA_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    mapService.getMapData(id).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
      }
    )
  }
}
function getEditorMapData (args) {
  function request (mapData) {
    return { type: mapConstants.GET_EDITOR_MAP_DATA_REQUEST, payload: mapData }
  }
  function success (mapData) {
    return { type: mapConstants.GET_EDITOR_MAP_DATA_SUCCESS, payload: mapData.data }
  }
  function failure (error) {
    return { type: mapConstants.GET_EDITOR_MAP_DATA_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    mapService.getEditorMapData(args).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
      }
    )
  }
}
function getGeoJson (id) {
  function request (mapData) {
    return { type: mapConstants.GET_GEOJSON_REQUEST, payload: mapData }
  }
  function success (mapData) {
    return { type: mapConstants.GET_GEOJSON_SUCCESS, payload: mapData.data }
  }
  function failure (error) {
    return { type: mapConstants.GET_GEOJSON_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    mapService.getGeoJson(id).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
      }
    )
  }
}

const mapActions = {
  getMapData,
  getGeoJson,
  getEditorMapData
}
export default mapActions
