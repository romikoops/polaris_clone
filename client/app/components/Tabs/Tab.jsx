import React from 'react'
import PropTypes from '../../prop-types'
import styles from './Tabs.scss'
import { gradientBorderGenerator, gradientTextGenerator, switchIcon } from '../../helpers'

export default function Tab (props) {
  const {
    linkClassName, isActive, onClick, tabIndex, tabTitle, theme, icon, mot
  } = props

  const borderGradient =
    theme && theme.colors
      ? gradientBorderGenerator(theme.colors.primary, theme.colors.secondary, '-180deg')
      : { borderBottom: '2px solid #E0E0E0' }
  const gradientFontStyle =
      theme && theme.colors && isActive
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { backroundImage: '#E0E0E0' }
  const deselectedStyle = {
    ...gradientBorderGenerator('#DCDBDC', '#DCDBDC')
  }
  const showIcon = isActive ? switchIcon(mot, gradientFontStyle) : switchIcon(mot)

  return (
    <div className={`layout-row flex-100 layout-align-center-center ${styles.tab}`}>
      <div className={styles.gradient} style={isActive ? borderGradient : deselectedStyle} />
      <div className={`${styles.content}`}>
        <a
          className={`layout-row layout-align-${icon || mot ? 'center' : 'space-around'}-end ${linkClassName} ${isActive ? 'active' && styles.active : styles.disabled}`}
          onClick={(event) => {
            event.preventDefault()
            onClick(tabIndex)
          }}
        >
          {mot && !icon ? showIcon : ''}
          {icon
            ? <i
              className={`${icon} ${isActive ? 'clip' : ''}`}
              style={isActive ? gradientFontStyle : { color: '#E0E0E0' }}
            /> : ''}
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
  linkClassName: PropTypes.string,
  mot: PropTypes.string,
  tabTitle: PropTypes.string.isRequired,
  theme: PropTypes.theme,
  icon: PropTypes.string
}

Tab.defaultProps = {
  onClick: null,
  tabIndex: 0,
  linkClassName: '',
  mot: '',
  isActive: false,
  theme: null,
  icon: ''
}
