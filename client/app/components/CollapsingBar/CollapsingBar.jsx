import React from 'react'
import PropTypes from '../../prop-types'
import CollapsingHeading from './Heading'
import CollapsingContent from './Content'

export default function CollapsingBar ({
  collapsed, theme, handleCollapser, content, headingText, faClass, minHeight
}) {
  return (
    <div className="flex-100 layout-row layout-align-start-center layout-wrap">
      <CollapsingHeading
        text={text}
        showArrow={showArrow}
        optClassName={optClassName}
        contentHeader={contentHeader}
        collapsed={collapsed}
        theme={theme}
        handleCollapser={handleCollapser}
        faClass={faClass}
        styleHeader={styleHeader}
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
