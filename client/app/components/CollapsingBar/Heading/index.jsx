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
  optClassName
}) {
  return (
    <div
      style={styleHeader}
      className={`${styles.heading} ${optClassName} flex-100 layout-row layout-wrap layout-align-space-between-center`}
    >
      {text ? (
        <div className="layout-row flex layout-align-start-center">
          <i className={faClass} />
          <TextHeading theme={theme} color="white" size={3} text={text} />
        </div>
      ) : contentHeader }
      <div
        className={`${text ? 'flex-10' : 'flex-100'} layout-row layout-align-center-center`}
        onClick={handleCollapser}
      >
        <i className={`${collapsed ? styles.collapsed : ''} fa fa-chevron-down pointy`} />
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
  styleHeader: Proptypes.objectOf(Proptypes.string)
}

CollapsingHeading.defaultProps = {
  text: '',
  collapsed: false,
  theme: null,
  handleCollapser: null,
  faClass: '',
  optClassName: '',
  styleHeader: {}
}
