import { get } from 'lodash'
import FullStory from '@fullstory/browser'

const identity = x => x
const getUndefined = () => {}
const filter = () => true

const fullStoryReady = false
window['_fs_ready'] = function() {
 fullStoryReady = true
}

export default function createSentryMiddleware (Sentry, options = {}) {
  const {
    breadcrumbDataFromAction = getUndefined,
    actionTransformer = identity,
    stateTransformer = identity,
    breadcrumbCategory = 'redux-action',
    filterBreadcrumbActions = filter
  } = options

  return (store) => {
    let lastAction

    return next => (action) => {
      Sentry.configureScope((scope) => {
        const state = store.getState()
        const reduxExtra = {
          lastAction: actionTransformer(lastAction),
          state: stateTransformer(state)
        }
        scope.setExtra('scope', reduxExtra)

        if (fullStoryReady) {
          scope.setExtra("fullstory", { fullStoryUrl: FullStory.getCurrentSessionURL(true) })
        }

        const user = get(state, 'authentication.user')
        scope.setUser({ id: get(user, 'id'), email: get(user, 'email'), role: get(user, 'role.name') })
        scope.setTag('tenant', get(state, 'app.tenant.slug'))
        scope.setTag('agency', !!get(user, 'agency_id'))
        scope.setTag('appName', window.keel.appName)
      })

      // Log the action taken to Sentry so that we have narrative context in our
      // error report.
      if (filterBreadcrumbActions(action)) {
        Sentry.addBreadcrumb({
          category: breadcrumbCategory,
          message: action.type,
          data: breadcrumbDataFromAction(action)
        })
      }

      lastAction = action

      return next(action)
    }
  }
}
