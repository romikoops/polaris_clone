import { push } from 'react-router-redux'
import { clientsConstants } from '../constants'
import { clientsService } from '../services'

function getClientsForList (args) {
  function request () {
    return { type: clientsConstants.GET_CLIENTS_LIST_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.GET_CLIENTS_LIST_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.GET_CLIENTS_LIST_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.getClientsForList(args).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function getGroupsForList (args) {
  function request () {
    return { type: clientsConstants.GET_GROUPS_LIST_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.GET_GROUPS_LIST_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.GET_GROUPS_LIST_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.getGroupsForList(args).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function getGroupsAndMargins (args) {
  function request () {
    return { type: clientsConstants.GET_MEMBERSHIP_DATA_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.GET_MEMBERSHIP_DATA_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.GET_MEMBERSHIP_DATA_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.getGroupsAndMargins(args).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function getMarginsForList (args) {
  function request () {
    return { type: clientsConstants.GET_MARGINS_LIST_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.GET_MARGINS_LIST_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.GET_MARGINS_LIST_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.getMarginsForList(args).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function createGroup (args) {
  function request () {
    return { type: clientsConstants.CREATE_GROUP_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.CREATE_GROUP_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.CREATE_GROUP_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.createGroup(args).then(
      (resp) => {
        dispatch(success(resp.data))
        dispatch(push(`/admin/clients/groups/${resp.data.id}`))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function logOut () {
  return { type: clientsConstants.CLIENT_LOG_OUT, payload: null }
}

function createCompany (args) {
  function request () {
    return { type: clientsConstants.CREATE_COMPANY_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.CREATE_COMPANY_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.CREATE_COMPANY_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.createCompany(args).then(
      (resp) => {
        dispatch(success(resp.data))
        dispatch(push(`/admin/clients/companies/${resp.data.id}`))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function editGroupMembers (args) {
  function request () {
    return { type: clientsConstants.EDIT_GROUP_MEMBERSHIP_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.EDIT_GROUP_MEMBERSHIP_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.EDIT_GROUP_MEMBERSHIP_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.editGroupMembers(args).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function editMemberships (args) {
  function request () {
    return { type: clientsConstants.EDIT_MEMBERSHIP_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.EDIT_MEMBERSHIP_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.EDIT_MEMBERSHIP_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.editMemberships(args).then(
      (resp) => {
        switch (args.targetType) {
          case 'user':
            dispatch(viewClient(args.targetId))
            break
          case 'company':
            dispatch(viewCompany(args.targetId))
            break
          case 'group':
            dispatch(viewGroup(args.targetId))
            break

          default:
            break
        }
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}
function editCompanyEmployees (args) {
  function request () {
    return { type: clientsConstants.EDIT_EMPLOYEES_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.EDIT_EMPLOYEES_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.EDIT_EMPLOYEES_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.editCompanyEmployees(args).then(
      (resp) => {
        dispatch(viewCompany(args.id))
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function getCompaniesForList (args) {
  function request () {
    return { type: clientsConstants.GET_COMPANIES_LIST_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.GET_COMPANIES_LIST_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.GET_COMPANIES_LIST_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.getCompaniesForList(args).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function getMarginFormData (id) {
  function request () {
    return { type: clientsConstants.GET_MARGIN_FORM_DATA_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.GET_MARGIN_FORM_DATA_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.GET_MARGIN_FORM_DATA_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.getMarginFormData(id).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function testMargins (args) {
  function request () {
    return { type: clientsConstants.TEST_MARGINS_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.TEST_MARGINS_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.TEST_MARGINS_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.testMargins(args).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function getFinerMarginDetails (args) {
  function request () {
    return { type: clientsConstants.GET_MARGIN_FEE_DATA_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.GET_MARGIN_FEE_DATA_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.GET_MARGIN_FEE_DATA_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.getFinerMarginDetails(args).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function createMargin (args) {
  function request () {
    return { type: clientsConstants.CREATE_MARGIN_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.CREATE_MARGIN_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.CREATE_MARGIN_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.createMargin(args).then(
      (resp) => {
        dispatch(success(resp.data))
        dispatch(push(`/admin/clients/groups/${args.groupId}`))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function deleteMargin (id) {
  function request () {
    return { type: clientsConstants.DELETE_MARGIN_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.DELETE_MARGIN_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.DELETE_MARGIN_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.deleteMargin(id).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function updateMarginValues (args) {
  function request () {
    return { type: clientsConstants.UPDATE_MARGINS_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.UPDATE_MARGINS_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.UPDATE_MARGINS_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.updateMarginValues(args).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function viewGroup (id) {
  function request () {
    return { type: clientsConstants.VIEW_GROUP_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.VIEW_GROUP_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.VIEW_GROUP_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.viewGroup(id).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function viewCompany (id) {
  function request () {
    return { type: clientsConstants.VIEW_COMPANY_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.VIEW_COMPANY_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.VIEW_COMPANY_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.viewCompany(id).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function viewClient (id) {
  function request () {
    return { type: clientsConstants.VIEW_CLIENT_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.VIEW_CLIENT_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.VIEW_CLIENT_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.viewClient(id).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function fetchTargetScope (args) {
  function request () {
    return { type: clientsConstants.FETCH_SCOPE_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.FETCH_SCOPE_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.FETCH_SCOPE_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.fetchTargetScope(args).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function membershipData (args) {
  function request () {
    return { type: clientsConstants.MEMBERSHIP_DATA_REQUEST }
  }
  function success (payload) {
    return { type: clientsConstants.MEMBERSHIP_DATA_SUCCESS, payload }
  }
  function failure (error) {
    return { type: clientsConstants.MEMBERSHIP_DATA_ERROR, error }
  }

  return (dispatch) => {
    dispatch(request)
    clientsService.membershipData(args).then(
      (resp) => {
        dispatch(success(resp.data))
      },
      (error) => {
        error.then((data) => {
          dispatch(failure({ type: 'error', text: data.message }))
        })
      }
    )
  }
}

function newMarginFromGroup (id) {
  return (dispatch) => {
    dispatch({ type: clientsConstants.NEW_MARGIN_FROM_GROUP, payload: id })
    dispatch(push('/admin/clients/margincreator'))
  }
}
function goTo (path) {
  return (dispatch) => {
    dispatch(push(path))
  }
}

function updateGroupUsers (groupId, userIds) {
  return dispatch => dispatch({ type: clientsConstants.UPDATE_GROUP_USERS, payload: { groupId, userIds } })
}

export const clientsActions = {
  editCompanyEmployees,
  getGroupsAndMargins,
  newMarginFromGroup,
  viewGroup,
  viewCompany,
  updateGroupUsers,
  createCompany,
  updateMarginValues,
  getClientsForList,
  getGroupsForList,
  getCompaniesForList,
  createGroup,
  editGroupMembers,
  getMarginFormData,
  createMargin,
  getFinerMarginDetails,
  getMarginsForList,
  editMemberships,
  viewClient,
  membershipData,
  deleteMargin,
  testMargins,
  fetchTargetScope,
  goTo,
  logOut
}

export default clientsActions
