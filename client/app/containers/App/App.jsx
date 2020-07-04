import { get, isEmpty } from 'lodash'
import React, { Component } from 'react'
import { connect } from 'react-redux'
import { Redirect, Route, Switch, withRouter } from 'react-router-dom'
import { bindActionCreators } from 'redux'
import { appActions, authenticationActions, shipmentActions, userActions } from '../../actions'
import ConsentManager from '../../components/ConsentManager'
import FatalError from '../../components/ErrorHandling/FatalError'
import GenericError from '../../components/ErrorHandling/Generic'
import InsuranceDetails from '../../components/InsuranceDetails/InsuranceDetails'
import Loading from '../../components/Loading/Loading'
import AdminShipmentAction from '../../components/Redirects/AdminShipmentAction'
import SamlRedirect from '../../components/Redirects/SamlRedirect'
import ResetPasswordForm from '../../components/ResetPasswordForm'
import { SignOut } from '../../components/SignOut/SignOut'
import TenantMenu from '../../components/TenantMenu'
import TermsAndConditions from '../../components/TermsAndConditions/TermsAndConditions'
import UserConfirmation from '../../components/UserAccount/UserConfirmation'
import { ZenDeskWidget } from '../../components/ZenDeskWidget/ZenDeskWidget'
import { moment } from '../../constants'
import getConfig from '../../constants/config.constants'
import ContextProvider from '../../hocs/ContextProvider'
import { AdminPrivateRoute, PrivateRoute } from '../../routes/index'
import Admin from '../Admin/Admin'
import Landing from '../Landing/Landing'
import Shop from '../Shop/Shop'
import UserAccount from '../UserAccount/UserAccount'

class App extends Component {
  constructor (props) {
    super(props)
    this.isUserExpired = this.isUserExpired.bind(this)
  }

  componentWillMount () {
    const { appDispatch, authDispatch, shipmentDispatch, location, user } = this.props
    appDispatch.getTenantId()
    appDispatch.setTenants()
    if (user) {
      authDispatch.setUser(user)
    }
    shipmentDispatch.checkAhoyShipment(location)
  }

  componentDidMount () {
    this.expiryWatcher()
  }

  componentWillUnmount () {
    const { interval } = this.state
    clearInterval(interval)
  }

  expiryWatcher () {
    const interval = setInterval(this.isUserExpired, 30 * 1000)
    this.setState({ interval })
  }

  isUserExpired () {
    const { appDispatch, user, lastActivity } = this.props
    if (!user) {
      return
    }
    const { localStorage } = window
    const { inactivityLimit } = user
    const auth = JSON.parse(localStorage.getItem('authHeader'))
    const authExpired = auth && moment.unix(auth.expiry).isBefore(moment())
    const inactive = moment.unix(lastActivity + inactivityLimit).isBefore(moment())
    const sessionExpired = authExpired || inactive
    if (sessionExpired) {
      appDispatch.goTo('/signout')
    }
    if ((user && !user.role) || (user && user.role && !user.role.name)) {
      appDispatch.goTo('/signout')
    }
  }

  hasFatalError () {
    const { app } = this.props

    return get(app, 'error.type', '') === 'FATAL'
  }

  render () {
    const {
      app,
      tenant,
      tenants,
      user,
      loggedIn,
      appDispatch,
      error,
      loading
    } = this.props
    if (this.hasFatalError()) {
      return <FatalError error={get(app, 'error')} />
    }
    if (!tenant) {
      return null // Wait until tenant is fetched
    }

    if (!isEmpty(error) && loading) {
      appDispatch.clearLoading()
    }

    const { theme } = tenant

    // Update document title
    if (tenant.name) {
      document.title = `${tenant.name} | ItsMyCargo`
    }

    const displayTenantsMenu = tenants && tenants.length > 0

    return (
      <ContextProvider tenant={tenant} theme={theme} user={user}>
        <div className="layout-fill layout-row layout-wrap layout-align-start hundred text-break">
          { displayTenantsMenu && <TenantMenu tenant={tenant} tenants={tenants} appDispatch={appDispatch} /> }
          <ConsentManager writeKey={getConfig().segment} />
          <ZenDeskWidget zenDeskKey={getConfig().zendesk} user={user} />
          <div className="flex-100 mc layout-row layout-align-start">
            {loading ? <Loading tenant={tenant} text="loading..." /> : ''}
            {user &&
              user.id &&
              tenant &&
              (user.organization_id && user.organization_id !== tenant.id) &&
              user.role &&
              user.role.name !== 'super_admin' && (<Redirect to="/signout" />)}
            <GenericError theme={theme}>
              <Switch className="flex">

                <Route exact path="/" render={(props) => <Landing theme={theme} {...props} />} />

                <Route
                  exact
                  path="/terms_and_conditions"
                  render={() => <TermsAndConditions tenant={tenant} user={user} theme={theme} />}
                />

                <Route
                  exact
                  path="/insurance"
                  render={() => <InsuranceDetails tenant={tenant} user={user} theme={theme} />}
                />

                <Route
                  exact
                  path="/password_reset"
                  render={(props) => <ResetPasswordForm user={user} theme={theme} {...props} />}
                />

                <Route
                  path="/booking"
                  component={Shop}
                  user={user}
                  loggedIn={loggedIn}
                  theme={theme}
                />

                <AdminPrivateRoute
                  path="/admin"
                  component={Admin}
                  user={user}
                  loggedIn={loggedIn}
                  theme={theme}
                />

                <Route path="/signout" render={(props) => <SignOut theme={theme} {...props} />} />

                <Route
                  exact
                  path="/redirects/shipments/:uuid"
                  render={(props) => <AdminShipmentAction theme={theme} {...props} />}
                />

                <PrivateRoute
                  path="/account"
                  component={UserAccount}
                  user={user}
                  tenant={tenant}
                  loggedIn={loggedIn}
                  theme={theme}
                />

                <Route path="/login/saml/success" render={(props) => (<SamlRedirect theme={theme} {...props} />)} />
                <Route
                  path="/login/saml/error"
                  render={(props) => (
                    <SamlRedirect theme={theme} failure {...props} />
                  )}
                />

                <Route render={() => <Redirect to="/" />} />

                <Route
                  path="/authentication/confirmation/:confirmation_token"
                  render={(props) => (
                    <UserConfirmation
                      theme={theme}
                    />
                  )}
                />

              </Switch>
            </GenericError>
          </div>
        </div>
      </ContextProvider>
    )
  }
}

App.defaultProps = {
  tenant: null,
  user: null,
  loggedIn: false,
  showMessages: false
}

function mapStateToProps (state) {
  const {
    selectedSubdomain, authentication, admin, users, app, error
  } = state
  const { tenant, tenants, lastActivity } = app
  const { user, loggedIn, loggingIn } = authentication
  const { isFetching } = tenant || {
    isFetching: true
  }
  const loading = admin.loading || users.loading

  return {
    selectedSubdomain,
    tenant,
    tenants,
    user,
    loggedIn,
    loggingIn,
    isFetching,
    loading,
    app,
    error,
    lastActivity
  }
}
function mapDispatchToProps (dispatch) {
  return {
    appDispatch: bindActionCreators(appActions, dispatch),
    authDispatch: bindActionCreators(authenticationActions, dispatch),
    userDispatch: bindActionCreators(userActions, dispatch),
    shipmentDispatch: bindActionCreators(shipmentActions, dispatch)
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(App))
