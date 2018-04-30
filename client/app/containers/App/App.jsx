import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { Switch, Route, Redirect, withRouter } from 'react-router-dom'
import PropTypes from 'prop-types'
import UserAccount from '../UserAccount/UserAccount'
import './App.scss'
import Landing from '../Landing/Landing'
import Shop from '../Shop/Shop'
import Admin from '../Admin/Admin'
import AdminShipmentAction from '../../components/Redirects/AdminShipmentAction'
import { SignOut } from '../../components/SignOut/SignOut'
import Loading from '../../components/Loading/Loading'
import TermsAndConditions from '../../components/TermsAndConditions/TermsAndConditions'
import InsuranceDetails from '../../components/InsuranceDetails/InsuranceDetails'
import { appActions } from '../../actions'
import { PrivateRoute, AdminPrivateRoute } from '../../routes/index'
import { getSubdomain } from '../../helpers'
import MessageCenter from '../../containers/MessageCenter/MessageCenter'
import ResetPasswordForm from '../../components/ResetPasswordForm'

class App extends Component {
  componentDidMount () {
    const { appDispatch } = this.props
    const subdomain = getSubdomain()
    appDispatch.fetchTenantIfNeeded(subdomain)
    appDispatch.fetchCurrencies()
    // dispatch(anonymousLogin());
  }
  componentDidUpdate (prevProps) {
    if (this.props.selectedSubdomain !== prevProps.selectedSubdomain) {
      // const subdomain = getSubdomain();
      const { appDispatch, selectedSubdomain } = this.props
      appDispatch.fetchTenantIfNeeded(selectedSubdomain)
    }
  }
  render () {
    const {
      tenant, isFetching, user, loggedIn, showMessages, sending
    } = this.props
    const { theme } = tenant.data
    return (
      <div className="layout-fill layout-row layout-wrap layout-align-start hundred">
        {/* <SideNav/> */}
        <div className="flex-100 mc layout-row  layout-align-start">
          {showMessages || sending ? <MessageCenter /> : ''}
          {isFetching ? <Loading theme={theme} text="loading..." /> : ''}
          {user && user.id && tenant && tenant.data &&
            user.tenant_id !== tenant.data.id && user.role_id !== 3
            ? (
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
              render={props => (<ResetPasswordForm user={user} theme={theme} {...props} />)}
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
              path="/redirects/shipment/:uuid"
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
    fetchCurrencies: PropTypes.func
  }).isRequired,
  sending: PropTypes.bool,
  showMessages: PropTypes.bool
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
    appDispatch: bindActionCreators(appActions, dispatch)
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(App))
