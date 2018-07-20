import React from 'react'
import PropTypes from '../../prop-types'
import CollapsingHeading from './Heading'
import CollapsingContent from './Content'

export default function CollapsingBar ({
  collapsed,
  theme,
  handleCollapser,
  content,
  text,
  faClass,
  contentHeader,
  styleHeader,
  optClassName,
  showArrow,
  hideContent
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
      {!hideContent ? (
        <CollapsingContent collapsed={collapsed} content={content} />
      ) : ''}
    </div>
  )
}

CollapsingBar.propTypes = {
  collapsed: PropTypes.bool,
  theme: PropTypes.theme,
  handleCollapser: PropTypes.func,
  content: PropTypes.node,
  contentHeader: PropTypes.node,
  hideContent: PropTypes.bool,
  text: PropTypes.string,
  optClassName: PropTypes.string,
  faClass: PropTypes.string,
  showArrow: PropTypes.bool,
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
  hideContent: false,
  faClass: '',
  styleHeader: {},
  showArrow: false
}
