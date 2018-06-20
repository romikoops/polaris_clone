import React, { Component } from 'react'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import { AdminNavItem } from './AdminNavItem'
import { adminMenutooltip as tooltip } from '../../constants'

export class AdminNav extends Component {
  constructor (props) {
    super(props)
    this.state = {
      links: [
        {
          icon: 'fa-tachometer',
          text: 'Dashboard',
          url: '/admin/dashboard',
          target: 'dashboard',
          tooltip: tooltip.dashboard
        },
        {
          icon: 'fa-ship',
          text: 'Shipments',
          url: '/admin/shipments',
          target: 'shipments',
          tooltip: tooltip.shipments
        },
        {
          icon: 'fa-building-o',
          text: 'Hubs',
          url: '/admin/hubs',
          target: 'hubs',
          tooltip: tooltip.hubs
        },
        {
          icon: 'fa-area-chart',
          text: 'Pricing',
          url: '/admin/pricing',
          target: 'pricing',
          tooltip: tooltip.pricing
        },
        {
          icon: 'fa-list',
          text: 'Schedules',
          url: '/admin/schedules',
          target: 'schedules',
          tooltip: tooltip.schedules
        },
        {
          icon: 'fa-truck',
          text: 'Trucking',
          url: '/admin/trucking',
          target: 'trucking',
          tooltip: tooltip.trucking
        },
        {
          icon: 'fa-users',
          text: 'Client',
          url: '/admin/clients',
          target: 'clients',
          tooltip: tooltip.clients
        },
        {
          icon: 'fa-map-signs',
          text: 'Routes',
          url: '/admin/routes',
          target: 'routes',
          tooltip: tooltip.routes
        },
        {
          icon: 'fa-magic',
          text: 'Set Up',
          url: '/admin/wizard',
          target: 'wizard',
          tooltip: tooltip.setup
        }
      ]
    }
  }
  render () {
    const { theme, navLink, user } = this.props
    const { links } = this.state
    const linkItems = links.map(li => (
      <AdminNavItem
        key={v4()}
        url={li.url}
        target={li.target}
        text={li.text}
        iconClass={li.icon}
        theme={theme}
        navFn={navLink}
        tooltip={li.tooltip}
      />
    ))
    if (user.role.name === 'super_admin') {
      linkItems.push(<AdminNavItem
        key={v4()}
        url="/super_admin/upload"
        target="super_admin"
        text="Super Admin"
        iconClass="fa-star"
        theme={theme}
        navFn={navLink}
      />)
    }
    const navStyle = { height: `${linkItems.length * 55}px` }

    return (
      <div
        className="flex-100 layout-row layout-wrap layout-align-start-center"
        style={navStyle}
      >
        {linkItems}
      </div>
    )
  }
}
AdminNav.propTypes = {
  theme: PropTypes.theme,
  navLink: PropTypes.func.isRequired,
  user: PropTypes.user
}

AdminNav.defaultProps = {
  theme: null,
  user: null
}

export default AdminNav
