import { mapConstants } from '../constants'
import { mapService } from '../services'

// import { Promise } from 'es6-promise-promise';
// import { push } from 'react-router-redux';

function getMapData (id) {
  function request (convoData) {
    return { type: mapConstants.GET_MAP_DATA_REQUEST, payload: convoData }
  }
  function success (convoData) {
    return { type: mapConstants.GET_MAP_DATA_SUCCESS, payload: convoData.data }
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

const mapActions = {
  getMapData
}
export default mapActions
