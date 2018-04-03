import React from 'react'
import Proptypes from '../../../prop-types'
import styles from './ShipmentCardHeading.scss'
import { TextHeading } from '../../TextHeading/TextHeading'

export default function ShipmentCardHeading ({
  text, theme, collapsed, handleCollapser
}) {
  const themeTitled =
    theme && theme.colors
      ? { background: theme.colors.primary, color: 'white' }
      : { background: 'rgba(0,0,0,0.25)', color: 'white' }

  return (
    <div
      style={themeTitled}
      className={`${styles.heading} flex-100 layout-row layout-align-space-between-center`}
    >
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

ShipmentCardHeading.propTypes = {
  text: Proptypes.string,
  collapsed: Proptypes.bool,
  theme: Proptypes.theme,
  handleCollapser: Proptypes.func
}

ShipmentCardHeading.defaultProps = {
  text: '',
  collapsed: false,
  theme: null,
  handleCollapser: null
}
