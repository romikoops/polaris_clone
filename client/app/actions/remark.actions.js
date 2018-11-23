import { remarkConstants } from '../constants'
import { remarkService } from '../services/remark.service'
import { alertActions } from './'

function getRemarks () {
  function request () {
    return { type: remarkConstants.GET_REMARKS_REQUEST }
  }
  function success (payload) {
    return { type: remarkConstants.GET_REMARKS_SUCCESS, payload }
  }
  function failure (error) {
    return { type: remarkConstants.GET_REMARKS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    remarkService
      .getRemarks()
      .then(resp => dispatch(success(resp.data)), error => dispatch(failure(error)))
  }
}
function addRemark (category, subcategory, body) {
  function request () {
    return {
      type: remarkConstants.ADD_REMARK_REQUEST
    }
  }
  function success (payload) {
    return {
      type: remarkConstants.ADD_REMARK_SUCCESS,
      payload
    }
  }
  function failure (error) {
    return { type: remarkConstants.ADD_REMARK_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    remarkService.addRemark(category, subcategory, body).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

function updateRemarks (newRemarkId, newRemarkBody) {
  function request () {
    return {
      type: remarkConstants.UPDATE_REMARKS_REQUEST
    }
  }
  function success (payload) {
    return {
      type: remarkConstants.UPDATE_REMARKS_SUCCESS,
      payload
    }
  }
  function failure (error) {
    return { type: remarkConstants.UPDATE_REMARKS_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    remarkService.updateRemarks(newRemarkId, newRemarkBody).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function deleteRemark (remarkId) {
  function request () {
    return {
      type: remarkConstants.DELETE_REMARK_REQUEST
    }
  }
  function success (payload) {
    return {
      type: remarkConstants.DELETE_REMARK_SUCCESS,
      payload
    }
  }
  function failure (error) {
    return { type: remarkConstants.DELETE_REMARK_FAILURE, error }
  }

  return (dispatch) => {
    dispatch(request())

    remarkService.deleteRemark(remarkId).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}
function updateReduxStore (payload) {
  return dispatch => dispatch({ type: 'GENERAL_UPDATE', payload })
}

const remarkActions = {
  getRemarks,
  addRemark,
  updateRemarks,
  deleteRemark,
  updateReduxStore
}

export default remarkActions
