import React, { Component } from 'react'
import ReactTooltip from 'react-tooltip'
import PropTypes from 'prop-types'
import { v4 } from 'node-uuid'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import { bindActionCreators } from 'redux'
import { adminActions, userActions } from '../../actions'
import { adminMenutooltip as menuTip } from '../../constants'
import { Modal } from '../Modal/Modal'
import { AvailableRoutes } from '../AvailableRoutes/AvailableRoutes'
import styles from './SideNav.scss'

class SideNav extends Component {
  constructor (props) {
    super(props)
    this.state = {
      expanded: true,
      showModal: false
    }
    this.toggleModal = this.toggleModal.bind(this)
  }
  setAdminUrl (target) {
    console.log(target)
    const { adminDispatch } = this.props
    switch (target) {
      case 'hubs':
        adminDispatch.getHubs(true)
        break
      case 'serviceCharges':
        adminDispatch.getServiceCharges(true)
        break
      case 'pricing':
        adminDispatch.getPricings(true)
        break
      case 'schedules':
        adminDispatch.getSchedules(true)
        break
      case 'trucking':
        adminDispatch.getTrucking(true)
        break
      case 'shipments':
        adminDispatch.getShipments(true)
        break
      case 'clients':
        adminDispatch.getClients(true)
        break
      case 'dashboard':
        adminDispatch.getDashboard(true)
        break
      case 'routes':
        adminDispatch.getItineraries(true)
        break
      case 'wizard':
        adminDispatch.goTo('/admin/wizard')
        break
      case 'super_admin':
        adminDispatch.goTo('/admin/super_admin/upload')
        break
      default:
        break
    }
  }
  setUserUrl (target) {
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
        userDispatch.goTo('/account/contacts')
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
      default:
        break
    }
  }
  toggleModal () {
    this.setState({ showModal: !this.state.showModal })
  }
  render () {
    const { expanded } = this.state
    const { theme, user, routes } = this.props
    const routeModal = (
      <Modal
        component={
          <AvailableRoutes
            user={user}
            theme={theme}
            routes={routes}
            initialCompName="UserAccount"
          />
        }
        width="48vw"
        verticalPadding="30px"
        horizontalPadding="15px"
        parentToggle={this.toggleModal}
      />
    )
    const userLinks = [
      {
        icon: 'fa-tachometer',
        text: 'Dashboard',
        url: '/account/dashboard',
        target: 'dashboard'
      },
      {
        icon: 'fa-ship',
        text: 'Avail. Routes',
        url: '/chooseroute/chooseroute',
        target: 'chooseRoutes'
      },
      {
        icon: 'fa-ship',
        text: 'Shipments',
        url: '/account/shipments',
        target: 'shipments'
      },
      {
        icon: 'fa-user',
        text: 'Profile',
        url: '/account/profile',
        target: 'profile'
      },
      {
        icon: 'fa-address-card',
        text: 'Contacts',
        url: '/account/contacts',
        target: 'contacts'
      }
    ]
    const adminLinks = [
      {
        icon: 'fa-tachometer',
        text: 'Dashboard',
        url: '/admin/dashboard',
        target: 'dashboard',
        tooltip: menuTip.dashboard
      },
      {
        icon: 'fa-ship',
        text: 'Shipments',
        url: '/admin/shipments',
        target: 'shipments',
        tooltip: menuTip.shipments
      },
      {
        icon: 'fa-building-o',
        text: 'Hubs',
        url: '/admin/hubs',
        target: 'hubs',
        tooltip: menuTip.hubs
      },
      {
        icon: 'fa-area-chart',
        text: 'Pricing',
        url: '/admin/pricing',
        target: 'pricing',
        tooltip: menuTip.pricing
      },
      {
        icon: 'fa-list',
        text: 'Schedules',
        url: '/admin/schedules',
        target: 'schedules',
        tooltip: menuTip.schedules
      },
      {
        icon: 'fa-truck',
        text: 'Trucking',
        url: '/admin/trucking',
        target: 'trucking',
        tooltip: menuTip.trucking
      },
      {
        icon: 'fa-users',
        text: 'Client',
        url: '/admin/clients',
        target: 'clients',
        tooltip: menuTip.clients
      },
      {
        icon: 'fa-map-signs',
        text: 'Routes',
        url: '/admin/routes',
        target: 'routes',
        tooltip: menuTip.routes
      },
      {
        icon: 'fa-magic',
        text: 'Set Up',
        url: '/admin/wizard',
        target: 'wizard',
        tooltip: menuTip.setup
      }
    ]
    const isAdmin = user.role_id === 1 || user.role_id === 3 || user.role === 4
    const links = isAdmin ? adminLinks : userLinks
    const expandNavClass = expanded ? styles.expanded : styles.collapsed
    const expandLinkClass = expanded ? styles.expanded_link : styles.collapsed_link
    const expandIconClass = expanded ? styles.expanded_icon : styles.collapsed_icon
    const textStyle = {
      background: theme && theme.colors ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})` : 'black'
    }
    const navLinks = links.map((li) => {
      const tli = li
      tli.action = isAdmin ? () => this.setAdminUrl(li.target) : () => this.setUserUrl(li.target)
      const toolId = v4()
      return (
        <div className={`${styles.dropdown_box} flex-100 layout-row layout-align-start-center`} onClick={tli.action}>
          <div className="flex-100 layout-row layout-align-start-center" data-for={toolId} data-tip={isAdmin ? li.tooltip : ''}>
            <div className={`flex-none layout-row-layout-align-center-center ${styles.icon_box} ${expandIconClass}`}>
              <i className={`fa flex-none clip pointy ${li.icon}`} style={textStyle} />
            </div>
            <div className={`flex-none layout-row-layout-align-center-center ${styles.link_text} ${expandLinkClass}`}>
              <p className={`${styles.text} flex-none`}>{li.text}</p>
            </div>
          </div>
          { isAdmin ? <ReactTooltip className={styles.tooltip} id={toolId} /> : '' }
        </div>
      )
    })
    return (
      <div className={`flex-none layout-column layout-align-start-start layout-wrap ${styles.side_nav} ${expandNavClass}`}>
        {this.state.showModal ? routeModal : ''}
        <div className={`flex-none layout-row layout-align-end-center ${styles.anchor}`} />
        <div className="flex layout-row layout-align-center-start layout-wrap">
          {navLinks}
        </div>
      </div>
    )
  }
}

SideNav.propTypes = {
  theme: PropTypes.theme,
  adminDispatch: PropTypes.shape({
    getHubs: PropTypes.func,
    getServiceCharges: PropTypes.func,
    getPricings: PropTypes.func,
    getSchedules: PropTypes.func,
    getTrucking: PropTypes.func,
    getShipments: PropTypes.func,
    getClients: PropTypes.func,
    getDashboard: PropTypes.func,
    getRoutes: PropTypes.func,
    goTo: PropTypes.func
  }).isRequired,
  user: PropTypes.user.isRequired,
  userDispatch: PropTypes.shape({
    getPricings: PropTypes.func,
    getSchedules: PropTypes.func,
    goTo: PropTypes.func,
    getDashboard: PropTypes.func,
    getLocations: PropTypes.func
  }).isRequired,
  routes: PropTypes.objectOf(PropTypes.any)
}

SideNav.defaultProps = {
  theme: null,
  routes: null
}

function mapStateToProps (state) {
  const {
    users, authentication, tenant, admin
  } = state
  const { user, loggedIn } = authentication
  return {
    user,
    users,
    tenant,
    theme: tenant.data.theme,
    loggedIn,
    adminData: admin
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch),
    userDispatch: bindActionCreators(userActions, dispatch)
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(SideNav))
