import React from 'react'
import ShipmentCardHeading from './Heading'
import ShipmentCardMainPanel from './MainPanel'
import Proptypes from '../../prop-types'
import styles from './ShipmentCard.scss'

export default function ShipmentCard ({
  collapsed, theme, handleCollapser, content, headingText
}) {
  return (
    <div className={
      `${styles.shipment_card} flex-100 ` +
      'layout-row layout-align-start-center layout-wrap'
    }
    >
      <ShipmentCardHeading
        text={headingText}
        collapsed={collapsed}
        theme={theme}
        handleCollapser={handleCollapser}
      />
      <ShipmentCardMainPanel collapsed={collapsed} content={content} />
    </div>
  )
}

ShipmentCard.propTypes = {
  collapsed: Proptypes.bool,
  theme: Proptypes.theme,
  handleCollapser: Proptypes.func,
  content: Proptypes.node,
  headingText: Proptypes.string
}

ShipmentCard.defaultProps = {
  collapsed: false,
  theme: null,
  handleCollapser: null,
  content: '',
  headingText: ''
}
