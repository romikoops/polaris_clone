import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './AdminRouteList.scss'
import AdminRouteListItem from '../RouteListItem'

/*   AdminRouteListItems   */

function BaseAdminRouteListItems ({
  routes, theme, clickable, onClickRoute, onMouseEnterRoute, onMouseLeaveRoute, t
}) {
  if (!routes || routes.length === 0) {
    return <span className="margin_lg_bottom">{t('errors:noRoutesAvailable')}</span>
  }

  return routes.map(route => (
    <AdminRouteListItem
      route={route}
      theme={theme}
      clickable={clickable}
      onClick={onClickRoute && (() => onClickRoute(route))}
      onMouseEnter={onMouseEnterRoute && (() => onMouseEnterRoute(route))}
      onMouseLeave={onMouseLeaveRoute && (() => onMouseLeaveRoute(route))}
    />
  ))
}

BaseAdminRouteListItems.defaultProps = {
  theme: null,
  clickable: true,
  onClickRoute: null,
  onMouseEnterRoute: null,
  onMouseLeaveRoute: null
}

const AdminRouteListItems = withNamespaces('errors')(BaseAdminRouteListItems)

/*   AdminRouteList   */

function AdminRouteList ({ listStyle, t, ...props }) {
  return (
    <div className="layout-column flex-100 layout-align-start-stretch">
      <div className="layout-padding layout-align-start-center greyBg">
        <span><b> {t('common:route_plural')} </b></span>
      </div>
      <div className={`layout-align-start-stretch ${styles.scrollable}`} style={{ height: 438, ...listStyle }}>
        <AdminRouteListItems {...props} />
      </div>
    </div>
  )
}

AdminRouteList.defaultProps = {
  listStyle: {}
}

export default withNamespaces('common')(AdminRouteList)
