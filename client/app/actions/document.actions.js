import { documentConstants } from '../constants/document.constants'
import { documentService } from '../services/document.service'
import { alertActions, adminActions, clientsActions } from '.'
import { errorActions } from './error.actions'

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
        dispatch(errorActions.setActionError({ uploadPricings: error }))
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
        dispatch(errorActions.setActionError({ uploadGeneratorSheet: error }))
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
        dispatch(errorActions.setActionError({ uploadHubs: error }))
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
        dispatch(errorActions.setActionError({ uploadMargins: error }))
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
        dispatch(errorActions.setActionError({ uploadGroupPricings: error }))
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
        dispatch(errorActions.setActionError({ uploadChargeCategories: error }))
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
        dispatch(errorActions.setActionError({ downloadChargeCategories: error }))
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
        dispatch(errorActions.setActionError({ downloadLocalCharges: error }))
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
        dispatch(errorActions.setActionError({ downloadSchedules: error }))
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
        dispatch(errorActions.setActionError({ downloadQuotations: error }))
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
        dispatch(errorActions.setActionError({ downloadQuote: error }))
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
        dispatch(errorActions.setActionError({ downloadShipment: error }))
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
        dispatch(errorActions.setActionError({ downloadTrucking: error }))
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
        dispatch(errorActions.setActionError({ downloadHubs: error }))
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
        dispatch(errorActions.setActionError({ downloadChargeCategories: error }))
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
        dispatch(errorActions.setActionError({ downloadGdpr: error }))
      }
    )
  }
}

function downloadDocument (id) {
  function request (downloadData) {
    return { type: documentConstants.DOWNLOAD_REQUEST, payload: downloadData }
  }
  function success (downloadData) {
    return {
      type: documentConstants.DOWNLOAD_SUCCESS,
      payload: { ...downloadData.data, key: 'id' }
    }
  }
  function failure (error) {
    return { type: documentConstants.DOWNLOAD_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    documentService.downloadDocument(id).then(
      (data) => {
        dispatch(success(data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
        dispatch(errorActions.setActionError({ downloadDocument: error }))
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
        dispatch(errorActions.setActionError({ uploadSchedules: error }))
      }
    )
  }
}

function uploadLocalCharges (file, mot, groupId = null) {
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
        dispatch(errorActions.setActionError({ uploadLocalCharges: error }))
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
        dispatch(errorActions.setActionError({ uploadNotes: error }))
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
  uploadNotes,
  downloadDocument
}

export default documentActions
