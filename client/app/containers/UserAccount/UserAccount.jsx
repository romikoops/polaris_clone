import React, { Component } from 'react'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { Switch, Route, withRouter } from 'react-router-dom'
import {
  UserDashboard,
  UserShipments,
  UserShipmentView,
  UserLocations,
  UserBilling,
  UserContacts
} from '../../components/UserAccount'
import UserProfile from '../../components/UserAccount/UserProfile'
// eslint-disable-next-line import/no-named-as-default
import UserShipmentsGroup from '../../components/User/Shipments/Group'
import { userActions, authenticationActions, appActions } from '../../actions'
import FloatingMenu from '../../components/FloatingMenu/FloatingMenu'
import PropTypes from '../../prop-types'
import Header from '../../components/Header/Header'
import Loading from '../../components/Loading/Loading'
import SideNav from '../../components/SideNav/SideNav'
import Footer from '../../components/Footer/Footer'
import defs from '../../styles/default_classes.scss'
import styles from './UserAccount.scss'
import NavBar from '../Nav'
import GenericError from '../../components/ErrorHandling/Generic'
import UserPricings from '../../components/UserAccount/UserPricings'

class UserAccount extends Component {
  constructor (props) {
    super(props)
    this.state = { currentUrl: '/account' }

    this.getLocations = this.getLocations.bind(this)
    this.destroyLocation = this.destroyLocation.bind(this)
    this.makePrimary = this.makePrimary.bind(this)
    this.setUrl = this.setUrl.bind(this)
    this.setCurrentUrl = this.setCurrentUrl.bind(this)
    this.setNavLink = this.setNavLink.bind(this)
  }
  componentDidMount () {
    const {
      userDispatch,
      users,
      user,
      shipments
    } = this.props

    if (user && users && !users.loading && !users.dashboard) {
      userDispatch.getDashboard(user.id, false)
    }
    if (user && users && !users.hubs) {
      userDispatch.getHubs(false)
    }
    if (shipments && !shipments.requested) {
      userDispatch.getShipments(false)
    }
  }

  setNavLink (target) {
    const { userDispatch, users, user } = this.props
    if (user && users && !users.loading && !users.dashboard) {
      userDispatch.getDashboard(user.id, false)
    }
  }

  getLocations () {
    const { userDispatch, user } = this.props
    userDispatch.getLocations(user.id)
  }
  setCurrentUrl (url) {
    this.setState({ currentUrl: url })
  }

  setUrl (target) {
    const { userDispatch, user } = this.props
    switch (target) {
      case 'pricing':
        userDispatch.getPricings(user.id, true)
        break
      case 'chooseRoutes':
        this.toggleModal()
        break
      case 'shipments':
        userDispatch.getShipments(true)
        break
      case 'contacts':
        userDispatch.getContacts({ page: 1 }, true)
        break
      case 'dashboard':
        userDispatch.getDashboard(user.id, true)
        break
      case 'locations':
        userDispatch.getLocations(user.id, true)
        break
      case 'profile':
        userDispatch.goTo('/account/profile')
        break
      case 'pricings':
        userDispatch.goTo('/account/pricings')
        break
      default:
        break
    }
  }
  destroyLocation (locationId) {
    const { userDispatch, user } = this.props
    userDispatch.destroyLocation(user.id, locationId)
  }

  makePrimary (locationId) {
    const { userDispatch, user } = this.props
    userDispatch.makePrimary(user.id, locationId)
  }
  render () {
    const {
      user,
      theme,
      users,
      userDispatch,
      authDispatch,
      currencies,
      appDispatch,
      tenant
    } = this.props
    if (!users || !user) {
      return <Loading theme={theme} text="loading..." />
    }
    const {
      shipments, hubs, shipment, dashboard, loading
    } = users
    if (!dashboard) {
      return <Loading theme={theme} text="loading..." />
    }

    const hubHash = {}
    if (hubs) {
      hubs.forEach((hub) => {
        hubHash[hub.data.id] = hub
      })
    }

    const loadingScreen = loading ? <Loading theme={theme} /> : ''
    const menu = <FloatingMenu Comp={SideNav} theme={theme} user={user} currentUrl={this.state.currentUrl} />
    const minHeightForFooter = window.innerHeight - 350
    const footerStyle = { minHeight: `${minHeightForFooter}px`, position: 'relative', paddingBottom: '230px' }

    return (
      <div className="layout-row flex-100 hundred">
        {loadingScreen}
        <GenericError theme={theme}>
          {menu}
        </GenericError >
        <GenericError theme={theme}>
          <Header theme={theme} shipments={users.dashboard.shipments} scrollable />
        </GenericError >
        <div
          className="layout-row flex layout-wrap layout-align-center-start"
          style={footerStyle}
        >
          <GenericError theme={theme}>
            <NavBar className={`${styles.top_margin}`} />
          </GenericError >
          <div
            className={`flex-100 ${defs.spacing_md_bottom} ${
              styles.top_margin
            } layout-row flex-none `}
          >
            <div className="layout-row flex-100 height_100">
              <GenericError theme={theme}>
                <Switch className="flex">
                  <Route
                    exact
                    path="/account"
                    render={props => (
                      <UserDashboard
                        setNav={this.setNavLink}
                        theme={theme}
                        {...props}
                        user={user}
                        tenant={tenant}
                        scope={tenant.data.scope}
                        setCurrentUrl={this.setCurrentUrl}
                        dashboard={dashboard}
                        hubs={hubHash}
                        navFn={this.setUrl}
                        userDispatch={userDispatch}
                      />
                    )}
                  />
                  <Route
                    path="/account/routesavailable"
                    render={props => (
                      <UserLocations
                        setNav={this.setNavLink}
                        theme={theme}
                        setCurrentUrl={this.setCurrentUrl}
                        {...props}
                        locations={users.dashboard.locations}
                        getLocations={this.getLocations}
                        destroyLocation={this.destroyLocation}
                        makePrimary={this.makePrimary}
                      />
                    )}
                  />
                  <Route
                    path="/account/locations"
                    render={props => (
                      <UserLocations
                        setNav={this.setNavLink}
                        theme={theme}
                        setCurrentUrl={this.setCurrentUrl}
                        {...props}
                        user={user}
                        locations={users.dashboard.locations}
                        getLocations={this.getLocations}
                        destroyLocation={this.destroyLocation}
                        makePrimary={this.makePrimary}
                      />
                    )}
                  />
                  <Route
                    path="/account/profile"
                    render={props => (
                      <UserProfile
                        appDispatch={appDispatch}
                        setNav={this.setNavLink}
                        currencies={currencies}
                        setCurrentUrl={this.setCurrentUrl}
                        theme={theme}
                        user={user}
                        tenant={tenant}
                        aliases={dashboard.aliases}
                        {...props}
                        locations={dashboard.locations}
                        userDispatch={userDispatch}
                        authDispatch={authDispatch}
                      />
                    )}
                  />
                  <Route
                    path="/account/contacts"
                    render={props => (
                      <UserContacts
                        setNav={this.setNavLink}
                        setCurrentUrl={this.setCurrentUrl}
                        theme={theme}
                        user={user}
                        aliases={dashboard.aliases}
                        {...props}
                        locations={dashboard.locations}
                        userDispatch={userDispatch}
                        authDispatch={authDispatch}
                      />
                    )}
                  />
                  <Route
                    path="/account/pricings"
                    render={props => (
                      <UserPricings
                        {...props}
                        setNav={this.setNavLink}
                        setCurrentUrl={this.setCurrentUrl}
                      />
                    )}
                  />
                  <Route
                    path="/account/billing"
                    render={props => (
                      <UserBilling setNav={this.setNavLink} theme={theme} user={user} {...props} />
                    )}
                  />
                  <Route
                    exact
                    path="/account/shipments"
                    render={props => (
                      <UserShipments
                        setNav={this.setNavLink}
                        setCurrentUrl={this.setCurrentUrl}
                        theme={theme}
                        hubs={hubHash}
                        tenant={tenant}
                        user={user}
                        {...props}
                        shipments={shipments}
                        userDispatch={userDispatch}
                      />
                    )}
                  />
                  <Route
                    path="/account/shipments/view/:id"
                    render={props => (
                      <UserShipmentView
                        setNav={this.setNavLink}
                        setCurrentUrl={this.setCurrentUrl}
                        theme={theme}
                        hubs={hubs}
                        user={user}
                        loading={loading}
                        {...props}
                        tenant={tenant}
                        shipmentData={shipment}
                        userDispatch={userDispatch}
                      />
                    )}
                  />
                  <Route
                    exact
                    path="/account/shipments/open"
                    render={props => (
                      <UserShipmentsGroup
                        setNav={this.setNavLink}
                        theme={theme}
                        hubHash={hubHash}
                        user={user}
                        target="open"
                        title="Open"
                        {...props}
                        shipments={dashboard.shipments}
                        userDispatch={userDispatch}
                      />
                    )}
                  />
                  <Route
                    exact
                    path="/account/shipments/requested"
                    render={props => (
                      <UserShipmentsGroup
                        setNav={this.setNavLink}
                        theme={theme}
                        hubHash={hubHash}
                        user={user}
                        target="requested"
                        title="Requested"
                        {...props}
                        shipments={dashboard.shipments}
                        userDispatch={userDispatch}
                      />
                    )}
                  />
                  <Route
                    exact
                    path="/account/shipments/finished"
                    render={props => (
                      <UserShipmentsGroup
                        setNav={this.setNavLink}
                        theme={theme}
                        hubHash={hubHash}
                        user={user}
                        target="finished"
                        title="Finished"
                        {...props}
                        shipments={dashboard.shipments}
                        userDispatch={userDispatch}
                      />
                    )}
                  />
                  <Route
                    exact
                    path="/account/shipments/rejected"
                    render={props => (
                      <UserShipmentsGroup
                        setNav={this.setNavLink}
                        theme={theme}
                        hubHash={hubHash}
                        user={user}
                        target="rejected"
                        title="Rejected"
                        {...props}
                        shipments={dashboard.shipments}
                        userDispatch={userDispatch}
                      />
                    )}
                  />
                  <Route
                    exact
                    path="/account/shipments/archived"
                    render={props => (
                      <UserShipmentsGroup
                        setNav={this.setNavLink}
                        theme={theme}
                        hubHash={hubHash}
                        user={user}
                        target="archived"
                        title="Archived"
                        {...props}
                        shipments={dashboard.shipments}
                        userDispatch={userDispatch}
                      />
                    )}
                  />
                </Switch>
              </GenericError >
            </div>
          </div>
          <Footer tenant={tenant} />
        </div>
      </div>
    )
  }
}

UserAccount.propTypes = {
  theme: PropTypes.theme,
  user: PropTypes.shape({
    id: PropTypes.number
  }),
  loggedIn: PropTypes.bool,
  shipments: PropTypes.arrayOf(PropTypes.object),
  users: PropTypes.shape({
    loading: PropTypes.bool,
    hubs: PropTypes.arrayOf(PropTypes.object)
  }),
  userDispatch: PropTypes.shape({
    getDashboard: PropTypes.func,
    getHubs: PropTypes.func
  }).isRequired,
  tenant: PropTypes.tenant,
  // eslint-disable-next-line react/forbid-prop-types
  authDispatch: PropTypes.any.isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  appDispatch: PropTypes.any.isRequired,

  currencies: PropTypes.arrayOf(PropTypes.object)
}

UserAccount.defaultProps = {
  theme: null,
  user: null,
  loggedIn: false,
  shipments: [],
  users: null,
  tenant: {},
  currencies: []
}

function mapStateToProps (state) {
  const {
    authentication, tenant, shipments, users, app
  } = state
  const { user, loggedIn } = authentication
  const { currencies } = app

  return {
    users,
    user,
    tenant,
    loggedIn,
    shipments,
    currencies
  }
}

function mapDispatchToProps (dispatch) {
  return {
    appDispatch: bindActionCreators(appActions, dispatch),
    userDispatch: bindActionCreators(userActions, dispatch),
    authDispatch: bindActionCreators(authenticationActions, dispatch)
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(UserAccount))
