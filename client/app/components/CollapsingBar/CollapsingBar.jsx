import React from 'react'
import PropTypes from '../../prop-types'
import CollapsingHeading from './Heading'
import CollapsingContent from './Content'
import styles from './CollapsingBar.scss'

export default function CollapsingBar ({
  collapsed, theme, handleCollapser, content, text, faClass, contentHeader, styleHeader, optClassName
}) {
  return (
    <div className={
      `${styles.shipment_card} flex-100 ` +
      'layout-row layout-align-start-center layout-wrap'
    }
    >
      <CollapsingHeading
        text={text}
        optClassName={optClassName}
        contentHeader={contentHeader}
        collapsed={collapsed}
        theme={theme}
        handleCollapser={handleCollapser}
        faClass={faClass}
        styleHeader={styleHeader}
      />
      <CollapsingContent collapsed={collapsed} content={content} />
    </div>
  )
}

CollapsingBar.propTypes = {
  collapsed: PropTypes.bool,
  theme: PropTypes.theme,
  handleCollapser: PropTypes.func,
  content: PropTypes.node,
  contentHeader: PropTypes.node,
  text: PropTypes.string,
  optClassName: PropTypes.string,
  faClass: PropTypes.string,
  styleHeader: PropTypes.objectOf(PropTypes.string)
}

CollapsingBar.defaultProps = {
  collapsed: false,
  theme: null,
  handleCollapser: null,
  content: '',
  contentHeader: '',
  optClassName: '',
  text: '',
  faClass: '',
  styleHeader: {}
}
