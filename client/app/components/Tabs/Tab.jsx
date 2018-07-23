import React from 'react'
import PropTypes from '../../prop-types'
import styles from './Tabs.scss'
import { gradientBorderGenerator } from '../../helpers'

export default function Tab (props) {
  const {
    linkClassName, isActive, onClick, tabIndex, tabTitle, theme, icon
  } = props

  const borderGradient =
    theme && theme.colors
      ? gradientBorderGenerator(theme.colors.primary, theme.colors.secondary, '-180deg')
      : { borderBottom: '2px solid #E0E0E0' }
  const deselectedStyle = {
    ...gradientBorderGenerator('#DCDBDC', '#DCDBDC')
  }

  return (
    <div className={`layout-row flex-100 layout-align-center-center ${styles.tab}`}>
      <div className={styles.gradient} style={isActive ? borderGradient : deselectedStyle} />
      <div className={`${styles.content}`}>
        <a
          className={` layout-row layout-align-space-around-end ${linkClassName} ${isActive ? 'active' && styles.active : styles.disabled}`}
          onClick={(event) => {
            event.preventDefault()
            onClick(tabIndex)
          }}
        >
          {icon}
          <p className="flex-none">{tabTitle}</p>
        </a>
      </div>
    </div>
  )
}

Tab.propTypes = {
  onClick: PropTypes.func,
  tabIndex: PropTypes.number,
  isActive: PropTypes.bool,
  linkClassName: PropTypes.string.isRequired,
  tabTitle: PropTypes.string.isRequired,
  theme: PropTypes.theme,
  icon: PropTypes.node
}

Tab.defaultProps = {
  onClick: null,
  tabIndex: 0,
  isActive: false,
  theme: null,
  icon: null
}
