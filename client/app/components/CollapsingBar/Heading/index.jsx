import React from 'react'
import Proptypes from '../../../prop-types'
import styles from './CollapsingHeading.scss'
import { TextHeading } from '../../TextHeading/TextHeading'

export default function CollapsingHeading ({
  text, theme, collapsed, handleCollapser, faClass
}) {
  return (
    <div
      style={{ background: '#E0E0E0', color: '#4F4F4F' }}
      className={`${styles.heading} flex-100 layout-row layout-align-space-between-center`}
    >
      <i className={faClass} />
      <TextHeading theme={theme} color="white" size={3} text={text} />
      <div
        className="flex-10 layout-row layout-align-center-center"
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
  faClass: Proptypes.string
}

CollapsingHeading.defaultProps = {
  text: '',
  collapsed: false,
  theme: null,
  handleCollapser: null,
  faClass: ''
}
