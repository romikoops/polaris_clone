// import { push } from 'react-router-redux'
import { documentConstants } from '../constants/document.constants'
import { documentService } from '../services/document.service'
import { alertActions, adminActions } from './'
// import { Promise } from 'es6-promise-promise';

function uploadPricings (file, loadType, open) {
  function request (uploadData) {
    return { type: documentConstants.UPLOAD_REQUEST, payload: uploadData }
  }
  function success (uploadData) {
    return { type: documentConstants.UPLOAD_SUCCESS, payload: uploadData.data }
  }
  function failure (error) {
    return { type: documentConstants.UPLOAD_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    documentService.uploadPricings(file, loadType, open).then(
      (data) => {
        dispatch(alertActions.success('Uploading successful'))
        dispatch(success(data))
        dispatch(adminActions.getPricings(false))
      },
      (error) => {
        // ;
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function uploadHubs (file) {
  function request (uploadData) {
    return { type: documentConstants.UPLOAD_REQUEST, payload: uploadData }
  }
  function success (uploadData) {
    return { type: documentConstants.UPLOAD_SUCCESS, payload: uploadData.data }
  }
  function failure (error) {
    return { type: documentConstants.UPLOAD_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    documentService.uploadHubs(file).then(
      (data) => {
        dispatch(alertActions.success('Uploading successful'))
        dispatch(success(data))
        dispatch(adminActions.getHubs(false))
      },
      (error) => {
        // ;
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function uploadSchedules (file, target) {
  function request (uploadData) {
    return { type: documentConstants.UPLOAD_REQUEST, payload: uploadData }
  }
  function success (uploadData) {
    return { type: documentConstants.UPLOAD_SUCCESS, payload: uploadData.data }
  }
  function failure (error) {
    return { type: documentConstants.UPLOAD_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    documentService.uploadSchedules(file, target).then(
      (data) => {
        dispatch(alertActions.success('Uploading successful'))
        dispatch(success(data))
        dispatch(adminActions.getSchedules(false))
      },
      (error) => {
        // ;
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function uploadItinerarySchedules (file, target) {
  function request (uploadData) {
    return { type: documentConstants.UPLOAD_REQUEST, payload: uploadData }
  }
  function success (uploadData) {
    return { type: documentConstants.UPLOAD_SUCCESS, payload: uploadData.data }
  }
  function failure (error) {
    return { type: documentConstants.UPLOAD_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    documentService.uploadItinerarySchedules(file, target).then(
      (data) => {
        dispatch(alertActions.success('Uploading successful'))
        dispatch(success(data))
        dispatch(adminActions.getSchedules(false))
      },
      (error) => {
        // ;
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function uploadLocalCharges (file) {
  function request (uploadData) {
    return { type: documentConstants.UPLOAD_REQUEST, payload: uploadData }
  }
  function success (uploadData) {
    return { type: documentConstants.UPLOAD_SUCCESS, payload: uploadData.data }
  }
  function failure (error) {
    return { type: documentConstants.UPLOAD_FAILURE, error }
  }
  return (dispatch) => {
    dispatch(request())

    documentService.uploadLocalCharges(file).then(
      (data) => {
        dispatch(alertActions.success('Uploading successful'))
        dispatch(success(data))
        // dispatch(adminActions.getHubs(false))
      },
      (error) => {
        // ;
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function setStats (stats) {
  return { type: documentConstants.UPLOAD_SUCCESS, payload: stats }
}
function closeViewer () {
  return { type: documentConstants.CLOSE_VIEWER, payload: true }
}
function clearLoading () {
  return { type: documentConstants.CLEAR_LOADING, payload: null }
}

export const documentActions = {
  uploadPricings,
  closeViewer,
  clearLoading,
  uploadHubs,
  setStats,
  uploadLocalCharges,
  uploadSchedules,
  uploadItinerarySchedules
}

export default documentActions
