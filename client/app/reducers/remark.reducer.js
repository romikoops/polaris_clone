import { remarkConstants } from '../constants'

export default function remark (state = {}, action) {
  switch (action.type) {
    case remarkConstants.UPDATE_REMARKS_REQUEST:
      return state
    case remarkConstants.UPDATE_REMARKS_SUCCESS: {
      const newState = { ...state }

      const {
        category, subcategory, id, body
      } = action.payload

      const newRemark = { id, body }

      newState[category][subcategory].forEach((obj) => {
        if (obj.id === newRemark.id) {
          obj.body.replace(newRemark.body)
        }
      })

      return {
        ...newState,
        metaData: {
          remarkId: id,
          savedRemarkSuccess: true
        }
      }
    }
    case remarkConstants.GET_REMARKS_SUCCESS: {
      const newState = { ...state }
      action.payload.forEach((_remark) => {
        newState[_remark.category] = newState[_remark.category] || {}
        newState[_remark.category][_remark.subcategory] =
          newState[_remark.category][_remark.subcategory] || []
        const index = newState[_remark.category][_remark.subcategory].findIndex(r => r.id === _remark.id)
        if (index === -1) {
          newState[_remark.category][_remark.subcategory].push({ id: _remark.id, body: _remark.body })
        } else {
          newState[_remark.category][_remark.subcategory][index] = _remark
        }
      })

      return {
        ...newState,
        metaData: {
          getRemarksSuccess: true
        }
      }
    }
    case remarkConstants.DELETE_REMARK_SUCCESS: {
      const newState = { ...state }
      const { category, subcategory, id } = action.payload
      const idx = newState[category][subcategory].findIndex(_remark => _remark.id === id)
      newState[category][subcategory].splice(idx, 1)

      return newState
    }
    case 'GENERAL_UPDATE': {
      return {
        ...state,
        ...action.payload
      }
    }
    case remarkConstants.ADD_REMARK_SUCCESS: {
      const newState = { ...state }
      const {
        category, subcategory, id, body
      } = action.payload
      const newRemark = { id, body }
      if (newState[category] && newState[category][subcategory]) {
        newState[category][subcategory].push(newRemark)

        return newState
      }

      newState[category] = newState[category] || {}
      newState[category][subcategory] =
          newState[category][subcategory] || []
      newState[category][subcategory].push(newRemark)

      return newState
    }
    case remarkConstants.ADD_REMARK_REQUEST:
    case remarkConstants.ADD_REMARK_FAILURE:
    case remarkConstants.GET_REMARKS_REQUEST:
    case remarkConstants.GET_REMARKS_FAILURE:
    case remarkConstants.DELETE_REMARK_REQUEST:
    case remarkConstants.DELETE_REMARK_FAILURE:
    case remarkConstants.UPDATE_PDFREMARKS_FAILURE:
      return state
    default:
      return state
  }
}
