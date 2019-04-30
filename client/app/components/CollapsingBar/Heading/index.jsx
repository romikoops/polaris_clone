import React from 'react'
import Proptypes from '../../../prop-types'
import styles from './CollapsingHeading.scss'

export default function CollapsingHeading ({
  text,
  collapsed,
  handleCollapser,
  faClass,
  contentHeader,
  mainWrapperStyle,
  showArrow,
  headerWrapClasses,
  hideIcon,
  showArrowSpacer
}) {
  return (
    <div
      style={text ? { background: '#E0E0E0', color: '#4F4F4F' } : mainWrapperStyle}
      className={`${!contentHeader ? styles.heading : ''} pointy flex-100 layout-row layout-align-space-between-center`}
      onClick={handleCollapser}
    >
      {text ? (
        <div className="layout-row flex layout-align-start-center">
          {hideIcon ? '' : <i className={faClass} />}
          <h3 className={`flex ${styles.collapsed_heading}`}>{text}</h3>
        </div>
      ) : (
        <div
          className={`
          ${collapsed ? styles.collapsed : ''}
          ${headerWrapClasses}`}
          onClick={handleCollapser}
        >
          {contentHeader}
        </div>
      )}

      {showArrow ? (
        <div
          className={`flex-10 layout-row layout-align-center-center ${styles.arrow_index}`}
        >
          <i className={`${collapsed ? styles.collapsed : ''} fa fa-chevron-down pointy`} />
        </div>
      ) : '' }
      {showArrowSpacer ? (
        <div
          className={`flex-10 layout-row layout-align-center-center ${styles.arrow_index}`}
         />
      ) : '' }

    </div>
  )
}

CollapsingHeading.defaultProps = {
  text: '',
  collapsed: false,
  hideIcon: false,
  theme: null,
  handleCollapser: null,
  faClass: '',
  headerWrapClasses: '',
  mainWrapperStyle: {},
  showArrow: false,
  showArrowSpacer: false
}
