import React from 'react'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
// import styles from './NavSidebar.scss';
// import Style from 'style-it';
import { AdminNavItem } from '../../components/Admin/AdminNavItem'

export function NavSidebar ({
  navLinkInfo,
  // activeLink,
  toggleActiveClass,
  theme
  // navHeadlineInfo
}) {
  const navLinks = navLinkInfo.map(op => (
    <AdminNavItem
      key={v4()}
      url={op.url}
      target={op.target}
      text={op.text}
      iconClass={op.icon}
      theme={theme}
      navFn={toggleActiveClass}
    />
  ))
  const navStyle = { height: `${navLinks.length * 55}px` }
  return (
    <div className="flex-100 layout-row layout-wrap layout-align-start-center" style={navStyle}>
      {navLinks}
    </div>
  )
}

NavSidebar.propTypes = {
  theme: PropTypes.theme,
  toggleActiveClass: PropTypes.func.isRequired,
  navLinkInfo: PropTypes.arrayOf(PropTypes.shape({
    url: PropTypes.string,
    target: PropTypes.string,
    text: PropTypes.string,
    icon: PropTypes.string
  })).isRequired
}

NavSidebar.defaultProps = {
  theme: null
}

export default NavSidebar
