import { push } from 'react-router-redux'
import { contentConstants } from '../constants'
import { contentService } from '../services'
import { alertActions } from '.'

function getContentForComponent (component) {
  function request (contentData) {
    return { type: contentConstants.COMPONENT_FETCH_REQUEST, payload: contentData }
  }
  function success (contentData) {
    return { type: contentConstants.COMPONENT_FETCH_SUCCESS, payload: contentData }
  }
  function failure (error) {
    return { type: contentConstants.COMPONENT_FETCH_CLEAR, error }
  }

  return (dispatch) => {
    dispatch(request())

    contentService.getContentForComponent(component).then(
      (response) => {
        dispatch(success(response.data))
      },
      (error) => {
        dispatch(failure(error))
        dispatch(alertActions.error(error))
      }
    )
  }
}

export const contentActions = {
  getContentForComponent
}

export default contentActions
