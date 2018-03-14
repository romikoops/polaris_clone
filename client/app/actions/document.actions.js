// import { push } from 'react-router-redux'
import { documentConstants } from '../constants/document.constants'
import { documentService } from '../services/document.service'
import { alertActions } from './'
// import { Promise } from 'es6-promise-promise';

function uploadPricings (file, loadType, open) {
  function request (uploadData) {
    return { type: documentConstants.UPLOAD_PRICINGS_REQUEST, payload: uploadData }
  }
  function success (uploadData) {
    return { type: documentConstants.UPLOAD_PRICINGS_SUCCESS, payload: uploadData.data }
  }
  function failure (error) {
    return { type: documentConstants.UPLOAD_PRICINGS_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    documentService.uploadPricings(file, loadType, open).then(
      (data) => {
        dispatch(alertActions.success('Uploading successful'))
        dispatch(success(data))
      },
      (error) => {
        // ;
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function closeViewer () {
  return { type: documentConstants.CLOSE_VIEWER, payload: true }
}

export const documentActions = {
  uploadPricings,
  closeViewer
}

export default documentActions
