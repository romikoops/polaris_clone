// import { push } from 'react-router-redux'
import { documentConstants } from '../constants/document.constants'
import { documentService } from '../services/document.service'
import { alertActions, adminActions, clientsActions } from "."
// import { Promise } from 'es6-promise-promise';

function uploadPricings (file) {
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

    documentService.uploadPricings(file).then(
      (data) => {
        dispatch(success(data))
        dispatch(adminActions.getPricings(false))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function uploadGeneratorSheet (file) {
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

    documentService.uploadGeneratorSheet(file).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
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
        dispatch(success(data))
        dispatch(adminActions.getHubs(1, {}, {}, 15))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function uploadMargins (args) {
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

    documentService.uploadMargins(args).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function uploadGroupPricings (args) {
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

    documentService.uploadGroupPricings(args).then(
      (data) => {
        dispatch(success(data))
        dispatch(adminActions.getGroupPricings(args.groupId))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function uploadChargeCategories (file) {
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

    documentService.uploadChargeCategories(file).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function downloadPricings (options) {
  function request (downloadData) {
    return { type: documentConstants.DOWNLOAD_REQUEST, payload: downloadData }
  }
  function success (downloadData) {
    return { type: documentConstants.DOWNLOAD_SUCCESS, payload: downloadData.data }
  }
  function failure (error) {
    return { type: documentConstants.DOWNLOAD_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    documentService.downloadPricings(options).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function downloadLocalCharges (options) {
  function request (downloadData) {
    return { type: documentConstants.DOWNLOAD_REQUEST, payload: downloadData }
  }
  function success (downloadData) {
    return { type: documentConstants.DOWNLOAD_SUCCESS, payload: downloadData.data }
  }
  function failure (error) {
    return { type: documentConstants.DOWNLOAD_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    documentService.downloadLocalCharges(options).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function downloadSchedules (options) {
  function request (downloadData) {
    return { type: documentConstants.DOWNLOAD_REQUEST, payload: downloadData }
  }
  function success (downloadData) {
    return { type: documentConstants.DOWNLOAD_SUCCESS, payload: downloadData.data }
  }
  function failure (error) {
    return { type: documentConstants.DOWNLOAD_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    documentService.downloadSchedules(options).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function downloadQuotations (options) {
  function request (downloadData) {
    return { type: documentConstants.DOWNLOAD_REQUEST, payload: downloadData }
  }
  function success (downloadData) {
    return { type: documentConstants.DOWNLOAD_SUCCESS, payload: downloadData.data }
  }
  function failure (error) {
    return { type: documentConstants.DOWNLOAD_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())
    documentService.downloadQuotations(options).then(
      (response) => {
        dispatch(success(response))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function downloadQuote (options) {
  function request (downloadData) {
    return { type: documentConstants.DOWNLOAD_REQUEST, payload: downloadData }
  }
  function success (downloadData) {
    return { type: documentConstants.DOWNLOAD_SUCCESS, payload: downloadData.data }
  }
  function failure (error) {
    return { type: documentConstants.DOWNLOAD_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())
    documentService.downloadQuote(options).then(
      (response) => {
        dispatch(success(response))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function downloadShipment (options) {
  function request (downloadData) {
    return { type: documentConstants.DOWNLOAD_REQUEST, payload: downloadData }
  }
  function success (downloadData) {
    return { type: documentConstants.DOWNLOAD_SUCCESS, payload: downloadData.data }
  }
  function failure (error) {
    return { type: documentConstants.DOWNLOAD_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())
    documentService.downloadShipment(options).then(
      (response) => {
        dispatch(success(response))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function downloadTrucking (options) {
  function request (downloadData) {
    return { type: documentConstants.DOWNLOAD_REQUEST, payload: downloadData }
  }
  function success (downloadData) {
    return { type: documentConstants.DOWNLOAD_SUCCESS, payload: downloadData.data }
  }
  function failure (error) {
    return { type: documentConstants.DOWNLOAD_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    documentService.downloadTrucking(options).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function downloadHubs () {
  function request (downloadData) {
    return { type: documentConstants.DOWNLOAD_REQUEST, payload: downloadData }
  }
  function success (downloadData) {
    return { type: documentConstants.DOWNLOAD_SUCCESS, payload: downloadData.data }
  }
  function failure (error) {
    return { type: documentConstants.DOWNLOAD_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    documentService.downloadHubs().then(
      (data) => {
        dispatch(alertActions.success('Downloading Successful successful'))
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function downloadChargeCategories () {
  function request (downloadData) {
    return { type: documentConstants.DOWNLOAD_REQUEST, payload: downloadData }
  }
  function success (downloadData) {
    return { type: documentConstants.DOWNLOAD_SUCCESS, payload: downloadData.data }
  }
  function failure (error) {
    return { type: documentConstants.DOWNLOAD_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    documentService.downloadChargeCategories().then(
      (data) => {
        dispatch(alertActions.success('Downloading Successful successful'))
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function downloadGdpr (options) {
  function request (downloadData) {
    return { type: documentConstants.DOWNLOAD_REQUEST, payload: downloadData }
  }
  function success (downloadData) {
    return { type: documentConstants.DOWNLOAD_SUCCESS, payload: downloadData.data }
  }
  function failure (error) {
    return { type: documentConstants.DOWNLOAD_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    documentService.downloadGdpr(options.userId).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
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
        dispatch(success(data))
        dispatch(adminActions.getSchedules(false))
      },
      (error) => {
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
        dispatch(success(data))
        dispatch(adminActions.getSchedules(false))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function uploadLocalCharges (file, mot, groupId) {
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

    documentService.uploadLocalCharges(file, mot, groupId).then(
      (data) => {
        dispatch(success(data))
        dispatch(clientsActions.getLocalChargesForList({ groupId }))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function uploadNotes (file) {
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

    documentService.uploadNotes(file).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
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
  downloadLocalCharges,
  downloadSchedules,
  downloadHubs,
  closeViewer,
  clearLoading,
  uploadHubs,
  setStats,
  downloadPricings,
  uploadLocalCharges,
  uploadSchedules,
  uploadItinerarySchedules,
  downloadTrucking,
  downloadGdpr,
  downloadShipment,
  downloadQuotations,
  downloadChargeCategories,
  uploadChargeCategories,
  uploadGeneratorSheet,
  uploadMargins,
  downloadQuote,
  uploadGroupPricings,
  uploadNotes
}

export default documentActions
