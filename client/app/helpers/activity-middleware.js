import moment from 'moment'

export default function createActivityMiddleware () {

  return (store) => {
    return next => (action) => {
      if (action.type !== 'LAST_ACTIVITY' ) {
        next({ type: 'LAST_ACTIVITY', payload: moment().unix() })
      }

      return next(action)
    }
  }
}
