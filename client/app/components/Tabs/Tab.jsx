import React from 'react'
import PropTypes from '../../prop-types'
import styles from './Tabs.scss'
import { gradientBorderGenerator } from '../../helpers'

export default function Tab (props) {
  const {
    linkClassName, isActive, onClick, tabIndex, tabTitle, theme
  } = props

  const borderGradient =
    theme && theme.colors
      ? gradientBorderGenerator(theme.colors.primary, theme.colors.secondary, '-180deg')
      : { borderBottom: '2px solid #E0E0E0' }
  const deselectedStyle = {
    ...gradientBorderGenerator('#DCDBDC', '#DCDBDC')
  }

  return (
    <div className={`layout-row flex-gt-lg-33 flex-md-45 layout-align-center-center ${styles.tab}`}>
      <div className={styles.gradient} style={isActive ? borderGradient : deselectedStyle} />
      <div className={`${styles.content}`}>
        <a
          className={` ${linkClassName} ${isActive ? 'active' && styles.active : styles.disabled}`}
          onClick={(event) => {
            event.preventDefault()
            onClick(tabIndex)
          }}
        >
          <p>{tabTitle}</p>
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
  theme: PropTypes.theme
}

Tab.defaultProps = {
  onClick: null,
  tabIndex: 0,
  isActive: false,
  theme: null
}
