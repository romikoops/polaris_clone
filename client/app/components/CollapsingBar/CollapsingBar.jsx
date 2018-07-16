import React from 'react'
import CollapsingHeading from './Heading'
import CollapsingContent from './Content'
import Proptypes from '../../prop-types'
import styles from './CollapsingBar.scss'

export default function CollapsingBar ({
  collapsed, theme, handleCollapser, content, headingText, faClass, minHeight
}) {
  return (
    <div className={
      `${styles.shipment_card} flex-100 ` +
      'layout-row layout-align-start-center layout-wrap'
    }
    >
      <CollapsingHeading
        text={headingText}
        collapsed={collapsed}
        theme={theme}
        handleCollapser={handleCollapser}
        faClass={faClass}
      />
      <CollapsingContent collapsed={collapsed} minHeight={minHeight} content={content} />
    </div>
  )
}

CollapsingBar.propTypes = {
  collapsed: Proptypes.bool,
  theme: Proptypes.theme,
  handleCollapser: Proptypes.func,
  content: Proptypes.node,
  headingText: Proptypes.string,
  faClass: Proptypes.string,
  minHeight: Proptypes.string
}

CollapsingBar.defaultProps = {
  collapsed: false,
  theme: null,
  handleCollapser: null,
  content: '',
  headingText: '',
  faClass: '',
  minHeight: ''
}
