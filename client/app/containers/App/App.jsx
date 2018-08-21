import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route, Redirect, withRouter } from 'react-router-dom'
import PropTypes from 'prop-types'
import UserAccount from '../UserAccount/UserAccount'
import Landing from '../Landing/Landing'
import Shop from '../Shop/Shop'
import Admin from '../Admin/Admin'
import AdminShipmentAction from '../../components/Redirects/AdminShipmentAction'
import { SignOut } from '../../components/SignOut/SignOut'
import Loading from '../../components/Loading/Loading'
import TermsAndConditions from '../../components/TermsAndConditions/TermsAndConditions'
import InsuranceDetails from '../../components/InsuranceDetails/InsuranceDetails'
import { appActions, authenticationActions, userActions, tenantActions } from '../../actions'
import { defaultTheme, moment } from '../../constants'
import { PrivateRoute, AdminPrivateRoute } from '../../routes/index'
import { getSubdomain } from '../../helpers'
import MessageCenter from '../../containers/MessageCenter/MessageCenter'
import ResetPasswordForm from '../../components/ResetPasswordForm'
import CookieConsentBar from '../../components/CookieConsentBar'

class App extends Component {
  componentWillMount () {
    const { tenant, isFetching, tenantDispatch } = this.props
    if (!tenant && !isFetching) {
      const subdomain = getSubdomain()
      tenantDispatch.fetchTenantIfNeeded(subdomain)
    }
    this.isUserExpired()
  }
  componentDidMount () {
    const { appDispatch, tenantDispatch } = this.props
    const subdomain = getSubdomain()
    tenantDispatch.fetchTenantIfNeeded(subdomain)
    appDispatch.fetchCurrencies()
    this.isUserExpired()
  }
  componentDidUpdate (prevProps) {
    // this.isUserExpired()
    if ((this.props.selectedSubdomain !== prevProps.selectedSubdomain ||
      (!this.props.tenant && !this.props.isFetching) ||
    (this.props.tenant && !this.props.tenant.data && !this.props.isFetching))) {
      const { tenantDispatch, selectedSubdomain } = this.props
      tenantDispatch.fetchTenantIfNeeded(selectedSubdomain)
    }
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
  render () {
    const {
      tenant, isFetching, user, loggedIn, showMessages, sending, authDispatch, appDispatch
    } = this.props
    if (!tenant || (tenant && !tenant.data)) {
      return <Loading theme={defaultTheme} text="loading..." />
    }
    const { theme } = tenant.data

    return (
      <div className="layout-fill layout-row layout-wrap layout-align-start hundred text-break">
        <CookieConsentBar
          user={user}
          theme={theme}
          authDispatch={authDispatch}
          tenant={tenant}
          loggedIn={loggedIn}
        />
        <div className="flex-100 mc layout-row  layout-align-start">
          {showMessages || sending ? <MessageCenter /> : ''}
          {isFetching ? <Loading theme={theme} text="loading..." /> : ''}
          {user &&
          user.id &&
          tenant &&
          tenant.data &&
          user.tenant_id !== tenant.data.id &&
            user.role &&
            user.role.name !== 'super_admin' ? (
              <Redirect to="/signout" />
            ) : (
              ''
            )}
          <Switch className="flex">
            <Route exact path="/" render={props => <Landing theme={theme} {...props} />} />

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
              render={props => <ResetPasswordForm user={user} theme={theme} {...props} clearLoading={() => appDispatch.clearLoading()} />}
            />
            <PrivateRoute
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
            <Route path="/signout" render={props => <SignOut theme={theme} {...props} />} />
            <Route
              exact
              path="/redirects/shipments/:uuid"
              render={props => <AdminShipmentAction theme={theme} {...props} />}
            />
            <PrivateRoute
              path="/account"
              component={UserAccount}
              user={user}
              loggedIn={loggedIn}
              theme={theme}
            />
          </Switch>
        </div>
      </div>
    )
  }
}

App.propTypes = {
  selectedSubdomain: PropTypes.string.isRequired,
  isFetching: PropTypes.bool.isRequired,
  tenant: PropTypes.tenant,
  user: PropTypes.user,
  loggedIn: PropTypes.bool,
  appDispatch: PropTypes.shape({
    fetchTenantIfNeeded: PropTypes.func,
    fetchCurrencies: PropTypes.func,
    clearLoading: PropTypes.func
  }).isRequired,
  sending: PropTypes.bool,
  showMessages: PropTypes.bool,
  authDispatch: PropTypes.objectOf(PropTypes.func).isRequired,
  userDispatch: PropTypes.objectOf(PropTypes.func).isRequired
}

App.defaultProps = {
  tenant: null,
  user: null,
  loggedIn: false,
  sending: false,
  showMessages: false
}

function mapStateToProps (state) {
  const {
    selectedSubdomain, tenant, authentication, messaging
  } = state
  const { showMessages, sending } = messaging
  const { user, loggedIn } = authentication
  // const { currencies } = app;
  const { isFetching } = tenant || {
    isFetching: true
  }

  return {
    selectedSubdomain,
    tenant,
    user,
    loggedIn,
    isFetching,
    showMessages,
    sending
    // currencies
  }
}
function mapDispatchToProps (dispatch) {
  return {
    appDispatch: bindActionCreators(appActions, dispatch),
    tenantDispatch: bindActionCreators(tenantActions, dispatch),
    authDispatch: bindActionCreators(authenticationActions, dispatch),
    userDispatch: bindActionCreators(userActions, dispatch)
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(App))
