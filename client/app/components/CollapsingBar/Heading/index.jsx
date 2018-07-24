import React from 'react'
import Proptypes from '../../../prop-types'
import styles from './CollapsingHeading.scss'
import { TextHeading } from '../../TextHeading/TextHeading'

export default function CollapsingHeading ({
  text,
  theme,
  collapsed,
  handleCollapser,
  faClass,
  contentHeader,
  styleHeader,
  optClassName,
  showArrow,
  headerWrapClasses
}) {
  // debugger // eslint-disable-line
  return (
    <div
      style={{ background: '#E0E0E0', color: '#4F4F4F' }}
      className={`${styles.heading} flex-100 layout-row layout-align-space-between-center`}
      onClick={handleCollapser}
    >
      {text ? (
        <div className="layout-row flex layout-align-start-center">
          <i className={faClass} />
          <TextHeading theme={theme} color="white" size={3} text={text} />
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
        className="flex-10 layout-row layout-align-center-center"
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
  theme: Proptypes.theme,
  handleCollapser: Proptypes.func,
  faClass: Proptypes.string,
  contentHeader: Proptypes.node.isRequired,
  optClassName: Proptypes.string,
  showArrow: Proptypes.bool,
  headerWrapClasses: Proptypes.string,
  styleHeader: Proptypes.objectOf(Proptypes.string)
}

CollapsingHeading.defaultProps = {
  text: '',
  collapsed: false,
  theme: null,
  handleCollapser: null,
  faClass: '',
  headerWrapClasses: '',
  optClassName: '',
  styleHeader: {},
  showArrow: false
}
