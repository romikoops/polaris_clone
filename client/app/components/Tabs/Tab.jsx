import React from 'react'
import PropTypes from '../../prop-types'

export default function Tab (props) {
  const {
    linkClassName, isActive, onClick, tabIndex, tabTitle
  } = props

  return (
    <li className="tab">
      <a
        className={`tab-link ${linkClassName} ${isActive ? 'active' : ''}`}
        onClick={(event) => {
          event.preventDefault()
          onClick(tabIndex)
        }}
      >
        {tabTitle}
      </a>
    </li>
  )
}

Tab.propTypes = {
  onClick: PropTypes.func,
  tabIndex: PropTypes.number,
  isActive: PropTypes.bool,
  iconClassName: PropTypes.string.isRequired,
  linkClassName: PropTypes.string.isRequired
}

Tab.defaultProps = {
  onClick: null,
  tabIndex: PropTypes.number,
  isActive: PropTypes.bool
}
