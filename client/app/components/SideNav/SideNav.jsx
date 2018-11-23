import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'uuid'
import { connect } from 'react-redux'
import { withRouter } from 'react-router-dom'
import { bindActionCreators } from 'redux'
import { adminActions, userActions } from '../../actions'
import { adminMenutooltip as menuTip } from '../../constants'
import styles from './SideNav.scss'
import { gradientTextGenerator } from '../../helpers'

class SideNav extends Component {
  constructor (props) {
    super(props)
    this.state = {
      linkTextClass: '',
      linkVisibility: [],
      activeIndex: -1
    }
    const { t } = this.props
    this.userLinks = [
      {
        key: v4(),
        icon: 'fa-tachometer',
        url: '/account',
        text: t('account:dashboard'),
        target: 'dashboard'
      },
      {
        key: v4(),
        icon: 'fa-ship',
        text: t('account:shipments'),
        url: '/account/shipments',
        target: 'shipments'
      },
      {
        key: v4(),
        icon: 'fa-money',
        text: t('account:pricings'),
        url: '/account/pricings',
        target: 'pricings'
      },
      {
        key: v4(),
        icon: 'fa-user',
        text: t('account:profile'),
        url: '/account/profile',
        target: 'profile'
      },
      {
        key: v4(),
        icon: 'fa-address-card',
        text: t('account:contacts'),
        url: '/account/contacts',
        target: 'contacts'
      }
    ]
    this.adminLinks = [
      {
        key: v4(),
        icon: 'fa-tachometer',
        text: t('account:dashboard'),
        url: '/admin/dashboard',
        target: 'dashboard',
        tooltip: menuTip.dashboard
      },
      {
        key: v4(),
        icon: 'fa-ship',
        text: t('account:shipments'),
        url: '/admin/shipments',
        target: 'shipments',
        tooltip: menuTip.shipments
      },
      {
        key: v4(),
        icon: 'fa-building-o',
        text: t('account:hubs'),
        url: '/admin/hubs',
        target: 'hubs',
        tooltip: menuTip.hubs
      },
      {
        key: v4(),
        icon: 'fa-area-chart',
        url: '/admin/pricings',
        text: t('account:pricing'),
        target: 'pricing',
        tooltip: menuTip.pricing
      },
      {
        key: v4(),
        icon: 'fa-list',
        text: t('account:schedules'),
        url: '/admin/schedules',
        target: 'schedules',
        tooltip: menuTip.schedules
      },
      {
        key: v4(),
        icon: 'fa-users',
        text: t('account:clients'),
        url: '/admin/clients',
        target: 'clients',
        tooltip: menuTip.clients
      },
      {
        key: v4(),
        icon: 'fa-map-signs',
        text: t('account:routes'),
        url: '/admin/routes',
        target: 'routes',
        tooltip: menuTip.routes
      },
      {
        key: v4(),
        icon: 'fa-money',
        text: t('account:currencies'),
        url: '/admin/currencies',
        target: 'currencies',
        tooltip: menuTip.currencies
      },
      {
        key: v4(),
        icon: 'fa-cog',
        text: t('account:settings'),
        url: '/admin/settings',
        target: 'settings'
      }
    ]
    const width = window.innerWidth
    this.perPage = width >= 1920 ? 6 : 4
    const { user } = props
    const isAdmin = (user.role && user.role.name === 'admin') ||
      (user.role && user.role.name === 'super_admin') ||
      (user.role && user.role.name === 'sub_admin')
    const links = isAdmin ? this.adminLinks : this.userLinks
    const superAdminLink = {
      key: 'super-admin',
      icon: 'fa-star',
      text: t('account:superAdmin'),
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
    if (nextProps.currentUrl !== this.props.currentUrl) {
      this.updateActiveIndex(nextProps.currentUrl)
    }
  }

  setAdminUrl (target) {
    const { adminDispatch, tenant } = this.props
    const { scope } = tenant
    switch (target) {
      case 'hubs':
        adminDispatch.getHubs(true)
        break
      case 'serviceCharges':
        adminDispatch.getServiceCharges(true)
        break
      case 'pricing': {
        const pages = {}
        Object.keys(scope.modes_of_transport).forEach((mot) => {
          if (Object.values(scope.modes_of_transport[mot]) > 0) {
            pages[mot] = 1
          }
        })
        adminDispatch.getPricings(true, pages)
        break }
      case 'schedules':
        adminDispatch.getSchedules(true)
        break
      case 'trucking':
        adminDispatch.getTrucking(true)
        break
      case 'shipments': {
        const shipPages = scope.closed_quotation_tool || scope.open_quotation_tool
          ? { quoted: 1 } : { requested: 1, open: 1, finished: 1 }
        adminDispatch.getShipments(shipPages, this.perPage, true)
        break }
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
      case 'settings':
        adminDispatch.goTo('/admin/settings')
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
    const { userDispatch, user, tenant } = this.props
    const { scope } = tenant
    switch (target) {
      case 'pricings':
        userDispatch.goTo('/account/pricings')
        break
      case 'shipments': {
        const shipPages = scope.closed_quotation_tool || scope.open_quotation_tool
          ? { quoted: 1 } : { requested: 1, open: 1, finished: 1 }
        userDispatch.getShipments(shipPages, this.perPage, true)
        break }
      case 'contacts':
        userDispatch.getContacts({ page: 1 }, true)
        break
      case 'dashboard':
        userDispatch.getDashboard(user.id, true)
        break
      case 'addresses':
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
  updateActiveIndex (currentUrl) {
    const { user } = this.props
    const isAdmin = user && user.role && user.role.name.includes('admin')
    const newActiveLink = isAdmin
      ? this.adminLinks.filter(li => li.url === currentUrl)[0]
      : this.userLinks.filter(li => li.url === currentUrl)[0]
    const newActiveIndex = isAdmin
      ? this.adminLinks.indexOf(newActiveLink)
      : this.userLinks.indexOf(newActiveLink)
    this.toggleActiveIndex(newActiveIndex)
  }
  handleClickAction (li, i, isAdmin) {
    if (!this.state.linkVisibility[i] && !this.props.expand) return

    this.toggleActiveIndex(i)
    isAdmin ? this.setAdminUrl(li.target) : this.setUserUrl(li.target)
  }
  render () {
    const { theme, user, expand } = this.props

    const isAdmin = (user.role && user.role.name === 'admin') ||
    (user.role && user.role.name === 'super_admin') ||
    (user.role && user.role.name === 'sub_admin')
    const links = isAdmin ? this.adminLinks : this.userLinks

    const textStyle =
        theme && theme.colors
          ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
          : { background: 'black' }

    const navLinks = links.map((li, i) => {
      const toolId = v4()

      return (
        <div
          className={`${styles.dropdown_box} flex-100 layout-row layout-align-start-center ccb_${li.text.toLowerCase()}`}
          onClick={() => this.handleClickAction(li, i, isAdmin)}
          key={li.key}
          style={this.state.activeIndex === i ? { background: '#E0E0E0' } : {}}
        >
          <div
            className="flex-100 layout-row layout-align-start-center"
            onMouseLeave={() => this.setLinkVisibility(false, i)}
          >
            <div
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
              data-for={toolId}
              data-tip={isAdmin ? li.tooltip : ''}
              style={this.state.linkVisibility[i] ? { opacity: 1, visibility: 'visible' } : {}}
            >
              <p className={`${styles.text} flex-none`}>{li.text}</p>
            </div>
          </div>
          {isAdmin && (expand || this.state.linkVisibility[i]) ? (
            <ReactTooltip className={styles.tooltip} id={toolId} effect="solid" />
          ) : (
            ''
          )}
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
  tenant: PropTypes.tenant,
  t: PropTypes.func.isRequired,
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
  expand: PropTypes.bool,
  currentUrl: PropTypes.string
}

SideNav.defaultProps = {
  theme: null,
  tenant: null,
  expand: false,
  currentUrl: ''
}

function mapStateToProps (state) {
  const {
    users, authentication, app, admin
  } = state
  const { tenant } = app
  const { user, loggedIn } = authentication

  return {
    user,
    users,
    tenant,
    theme: tenant.theme,
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

export default withNamespaces('account')(withRouter(connect(mapStateToProps, mapDispatchToProps)(SideNav)))
