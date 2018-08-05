import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { v4 } from 'uuid'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import { bindActionCreators } from 'redux'
import { adminActions, userActions } from '../../actions'
import { adminMenutooltip as menuTip } from '../../constants'
import styles from './SideNav.scss'

class SideNav extends Component {
  constructor (props) {
    super(props)
    this.state = {
      linkTextClass: '',
      linkVisibility: [],
      activeIndex: -1
    }
    this.userLinks = [
      {
        key: v4(),
        icon: 'fa-tachometer',
        text: 'Dashboard',
        url: '/account/dashboard',
        target: 'dashboard'
      },
      {
        key: v4(),
        icon: 'fa-ship',
        text: 'Shipments',
        url: '/account/shipments',
        target: 'shipments'
      },
      {
        key: v4(),
        icon: 'fa-user',
        text: 'Profile',
        url: '/account/profile',
        target: 'profile'
      },
      {
        key: v4(),
        icon: 'fa-address-card',
        text: 'Contacts',
        url: '/account/contacts',
        target: 'contacts'
      }
    ]
    this.adminLinks = [
      {
        key: v4(),
        icon: 'fa-tachometer',
        text: 'Dashboard',
        url: '/admin/dashboard',
        target: 'dashboard',
        tooltip: menuTip.dashboard
      },
      {
        key: v4(),
        icon: 'fa-ship',
        text: 'Shipments',
        url: '/admin/shipments',
        target: 'shipments',
        tooltip: menuTip.shipments
      },
      {
        key: v4(),
        icon: 'fa-building-o',
        text: 'Hubs',
        url: '/admin/hubs',
        target: 'hubs',
        tooltip: menuTip.hubs
      },
      {
        key: v4(),
        icon: 'fa-area-chart',
        text: 'Pricing',
        url: '/admin/pricing',
        target: 'pricing',
        tooltip: menuTip.pricing
      },
      {
        key: v4(),
        icon: 'fa-list',
        text: 'Schedules',
        url: '/admin/schedules',
        target: 'schedules',
        tooltip: menuTip.schedules
      },
      {
        key: v4(),
        icon: 'fa-users',
        text: 'Clients',
        url: '/admin/clients',
        target: 'clients',
        tooltip: menuTip.clients
      },
      {
        key: v4(),
        icon: 'fa-map-signs',
        text: 'Routes',
        url: '/admin/routes',
        target: 'routes',
        tooltip: menuTip.routes
      },
      {
        key: v4(),
        icon: 'fa-money',
        text: 'Currencies',
        url: '/admin/currencies',
        target: 'currencies',
        tooltip: menuTip.currencies
      }
    ]

    const { user } = props
    const isAdmin = (user.role && user.role.name === 'admin') ||
      (user.role && user.role.name === 'super_admin') ||
      (user.role && user.role.name === 'sub_admin')
    const links = isAdmin ? this.adminLinks : this.userLinks
    const superAdminLink = {
      key: 'super-admin',
      icon: 'fa-star',
      text: 'SuperAdmin',
      url: '/admin/superadmin',
      target: 'superadmin'
    }
    if (user.role && user.role.name === 'super_admin' && links.indexOf(superAdminLink) < 0) {
      links.push(superAdminLink)
    }
    links.forEach((link, i) => {
      this.state.linkVisibility[i] = false
    })

    this.linkTextClass = ''
    this.setLinkVisibility = this.setLinkVisibility.bind(this)
    this.handleClickAction = this.handleClickAction.bind(this)
    this.toggleActiveIndex = this.toggleActiveIndex.bind(this)
  }
  componentWillReceiveProps (nextProps) {
    if (nextProps.expand) {
      this.setState({ linkTextClass: '' })
    } else {
      setTimeout(() => {
        if (!this.props.expand) {
          this.setState({ linkTextClass: styles.collapsed })
        }
      }, 200)
    }
  }
  setAdminUrl (target) {
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
      case 'currencies':
        adminDispatch.goTo('/admin/currencies')
        break
      case 'superadmin':
        adminDispatch.goTo('/admin/superadmin')
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
      // case 'chooseRoutes':
      //   this.toggleModal()
      //   break
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
  setLinkVisibility (bool, i) {
    this.setState((prevState) => {
      const { linkVisibility } = prevState
      linkVisibility[i] = bool

      return { linkVisibility }
    })
  }
  toggleActiveIndex (index) {
    this.setState({ activeIndex: index })
  }
  handleClickAction (li, i, isAdmin) {
    if (!this.state.linkVisibility[i] && !this.props.expand) return

    this.toggleActiveIndex(i)
    isAdmin ? this.setAdminUrl(li.target) : this.setUserUrl(li.target)
  }
  render () {
    const { theme, user } = this.props

    const isAdmin = (user.role && user.role.name === 'admin') ||
    (user.role && user.role.name === 'super_admin') ||
    (user.role && user.role.name === 'sub_admin')
    const links = isAdmin ? this.adminLinks : this.userLinks

    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const navLinks = links.map((li, i) => {
      const toolId = v4()

      return (
        <div
          className={`${styles.dropdown_box} flex-100 layout-row layout-align-start-center`}
          onClick={() => this.handleClickAction(li, i, isAdmin)}
          key={li.key}
          style={this.state.activeIndex === i ? { background: '#E0E0E0' } : {}}
        >
          <div
            className="flex-100 layout-row layout-align-start-center"
            onMouseLeave={() => this.setLinkVisibility(false, i)}
          >
            <div
              data-for={toolId}
              data-tip={isAdmin ? li.text : ''}
              className={`flex-none layout-row-layout-align-center-center ${styles.icon_box}`}
              onMouseEnter={() => this.setLinkVisibility(true, i)}
            >
              <i className={`fa flex-none clip pointy ${li.icon}`} style={textStyle} />
            </div>
            <div
              className={
                `flex-none layout-row-layout-align-center-center ${styles.link_text} ` +
                `${this.state.linkTextClass}`
              }

              style={this.state.linkVisibility[i] ? { opacity: 1, visibility: 'visible' } : {}}
            >
              <p className={`${styles.text} flex-none`}>{li.text}</p>
            </div>
          </div>
        </div>
      )
    })

    return (
      <div
        className={`flex-100 layout-column layout-align-start-stretch layout-wrap ${
          styles.side_nav
        }`}
      >
        <div className={`flex-none layout-row layout-align-end-center ${styles.anchor}`} />
        <div className="flex layout-row layout-align-center-start layout-wrap">{navLinks}</div>
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
  expand: PropTypes.bool
}

SideNav.defaultProps = {
  theme: null,
  expand: false
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
