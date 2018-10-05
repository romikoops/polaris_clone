const identity = x => x
const getUndefined = () => {}
const filter = () => true

export default function createSentryMiddleware(Sentry, options = {}) {
  const {
    breadcrumbDataFromAction = getUndefined,
    actionTransformer = identity,
    stateTransformer = identity,
    breadcrumbCategory = 'redux-action',
    filterBreadcrumbActions = filter,
    getUserContext,
    getTags
  } = options

  return (store) => {
    let lastAction

    Sentry.configureScope((scope) => {
      const state = store.getState()
      const reduxExtra = {
        lastAction: actionTransformer(lastAction),
        state: stateTransformer(state)
      }
      scope.setExtra('scope', reduxExtra)
      if (getUserContext) {
        scope.setUser(getUserContext(state))
      }
      if (getTags) {
        scope.setTags(getTags(state))
      }
    })

    return next => (action) => {
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
