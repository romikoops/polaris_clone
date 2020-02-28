import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import {
  Switch, Route, Redirect, withRouter
} from 'react-router-dom'
import { get } from 'lodash'

import UserAccount from '../UserAccount/UserAccount'
import Landing from '../Landing/Landing'
import Shop from '../Shop/Shop'
import TenantMenu from '../../components/TenantMenu'
import Admin from '../Admin/Admin'
import AdminShipmentAction from '../../components/Redirects/AdminShipmentAction'
import { SignOut } from '../../components/SignOut/SignOut'
import Loading from '../../components/Loading/Loading'
import TermsAndConditions from '../../components/TermsAndConditions/TermsAndConditions'
import InsuranceDetails from '../../components/InsuranceDetails/InsuranceDetails'
import {
  appActions, authenticationActions, shipmentActions, userActions
} from '../../actions'
import { moment } from '../../constants'
import { PrivateRoute, AdminPrivateRoute } from '../../routes/index'
import ResetPasswordForm from '../../components/ResetPasswordForm'
import CookieConsentBar from '../../components/CookieConsentBar'
import GenericError from '../../components/ErrorHandling/Generic'
import SamlRedirect from '../../components/Redirects/SamlRedirect'
import ContextProvider from '../../hocs/ContextProvider'
import FatalError from '../../components/ErrorHandling/FatalError'

class App extends Component {
  constructor (props) {
    super(props)
    this.isUserExpired = this.isUserExpired.bind(this)
  }

  componentWillMount () {
    const { appDispatch, shipmentDispatch, location } = this.props

    appDispatch.getTenantId()
    appDispatch.setTenants()
    shipmentDispatch.checkAhoyShipment(location)
  }

  componentDidMount () {
    this.isUserExpired()
  }

  isUserExpired () {
    const { appDispatch, user } = this.props
    const { localStorage } = window
    const auth = JSON.parse(localStorage.getItem('authHeader'))
    if (auth && moment.unix(auth.expiry).isBefore(moment())) {
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
      loading
    } = this.props
    if (this.hasFatalError()) {
      return <FatalError error={get(app, 'error')} />
    }

    if (!tenant) {
      return null // Wait until tenant is fetched
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
          <CookieConsentBar
            user={user}
            theme={theme}
            tenant={tenant}
            loggedIn={loggedIn}
            cookieRef={this.cookieRef}
          />
          <div className="flex-100 mc layout-row  layout-align-start">
            {loading ? <Loading tenant={tenant} text="loading..." /> : ''}
            {user &&
              user.id &&
              tenant &&
              user.tenant_id !== tenant.id &&
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

                <Route path="/login/saml/success" render={(props) => <SamlRedirect theme={theme} {...props} />} />
                <Route
                  path="/login/saml/error"
                  render={(props) => (
                    <SamlRedirect theme={theme} failure {...props} />
                  )}
                />

                <Route render={() => <Redirect to="/" />} />

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
    selectedSubdomain, authentication, admin, users, app
  } = state
  const { tenant, tenants } = app
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
    app
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
