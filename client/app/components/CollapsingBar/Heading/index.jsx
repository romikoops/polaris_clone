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
  headerWrapClasses
}) {
  return (
    <div
      style={text ? { background: '#E0E0E0', color: '#4F4F4F' } : mainWrapperStyle}
      className={`${styles.heading} pointy flex-100 layout-row layout-align-space-between-center`}
      onClick={handleCollapser}
    >
      {text ? (
        <div className="layout-row flex layout-align-start-center">
          <i className={faClass} />
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
      <div
        className={`flex-10 layout-row layout-align-center-center ${styles.arrow_index}`}
      >
        {showArrow ? (
          <i className={`${collapsed ? styles.collapsed : ''} fa fa-chevron-down pointy`} />
        ) : '' }
      </div>
    </div>
  )
}

CollapsingHeading.propTypes = {
  text: Proptypes.string,
  collapsed: Proptypes.bool,
  mainWrapperStyle: Proptypes.objectOf(Proptypes.any),
  theme: Proptypes.theme,
  handleCollapser: Proptypes.func,
  faClass: Proptypes.string,
  contentHeader: Proptypes.node.isRequired,
  showArrow: Proptypes.bool,
  headerWrapClasses: Proptypes.string
}

CollapsingHeading.defaultProps = {
  text: '',
  collapsed: false,
  theme: null,
  handleCollapser: null,
  faClass: '',
  headerWrapClasses: '',
  mainWrapperStyle: {},
  showArrow: false
}
