import React, { Component } from 'react'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { Switch, Route, withRouter } from 'react-router-dom'
import {
  UserProfile,
  UserDashboardNew,
  UserShipments,
  UserShipmentView,
  UserLocations,
  UserBilling,
  UserContacts
} from '../../components/UserAccount'
// eslint-disable-next-line import/no-named-as-default
import UserShipmentsGroup from '../../components/User/Shipments/Group'
import { userActions, authenticationActions, appActions } from '../../actions'
import FloatingMenu from '../../components/FloatingMenu/FloatingMenu'
import PropTypes from '../../prop-types'
import Header from '../../components/Header/Header'
import Loading from '../../components/Loading/Loading'
import SideNav from '../../components/SideNav/SideNav'
import { Footer } from '../../components/Footer/Footer'
import defs from '../../styles/default_classes.scss'
import styles from './UserAccount.scss'
import NavBar from '../Nav'

class UserAccount extends Component {
  constructor (props) {
    super(props)

    this.getLocations = this.getLocations.bind(this)
    this.destroyLocation = this.destroyLocation.bind(this)
    this.makePrimary = this.makePrimary.bind(this)
    this.setUrl = this.setUrl.bind(this)
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

  setUrl (target) {
    const { userDispatch, user } = this.props
    switch (target) {
      case 'pricing':
        // this.setState({ activeLink: target })
        userDispatch.getPricings(user.id, true)
        break
      case 'chooseRoutes':
        this.toggleModal()
        break
      case 'shipments':
        // this.setState({ activeLink: target })
        userDispatch.getShipments(true)
        break
      case 'contacts':
        // this.setState({ activeLink: target })
        userDispatch.goTo('/account/contacts')
        break
      case 'dashboard':
        // this.setState({ activeLink: target })
        userDispatch.getDashboard(user.id, true)
        break
      case 'locations':
        // this.setState({ activeLink: target })
        userDispatch.getLocations(user.id, true)
        break
      case 'profile':
        // this.setState({ activeLink: target })
        userDispatch.goTo('/account/profile')
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
      return ''
    }
    const {
      shipments, hubs, shipment, dashboard, loading
    } = users
    if (!dashboard) {
      return ''
    }

    const hubHash = {}
    if (hubs) {
      hubs.forEach((hub) => {
        hubHash[hub.data.id] = hub
      })
    }

    const loadingScreen = loading ? <Loading theme={theme} /> : ''
    const menu = <FloatingMenu Comp={SideNav} theme={theme} user={user} />
    return (
      <div className="layout-row flex-100 hundred">
        {loadingScreen}
        {menu}
        <Header theme={theme} shipments={users.dashboard.shipments} scrollable />
        <div className="layout-row flex layout-wrap layout-align-center">
          <NavBar className={`${styles.top_margin}`} />
          <div
            className={`flex-95 ${defs.spacing_md_bottom} ${
              styles.top_margin
            } layout-row flex-none`}
          >
            <div className="layout-row flex-100 ">
              <Switch className="flex">
                <Route
                  exact
                  path="/account"
                  render={props => (
                    <UserDashboardNew
                      {...props}
                      shipments={shipments}
                      user={user}
                      dashboard={dashboard}
                      hubHash={hubHash}
                    />
                  )}
                />
                <Route
                  path="/account/routesavailable"
                  render={props => (
                    <UserLocations
                      setNav={this.setNavLink}
                      theme={theme}
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
              </Switch>
            </div>
          </div>
          <Footer />
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
