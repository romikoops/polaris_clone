import React from 'react'
import PropTypes from '../../prop-types'
import CollapsingHeading from './Heading'
import CollapsingContent from './Content'

export default function CollapsingBar ({
  collapsed,
  theme,
  handleCollapser,
  headerWrapClasses,
  content,
  text,
  faClass,
  minHeight,
  contentHeader,
  mainWrapperStyle,
  showArrow,
  hideContent
}) {
  return (
    <div className="flex-100 layout-row layout-align-start-center layout-wrap">
      <CollapsingHeading
        text={text}
        showArrow={showArrow}
        contentHeader={contentHeader}
        collapsed={collapsed}
        theme={theme}
        headerWrapClasses={headerWrapClasses}
        handleCollapser={handleCollapser}
        faClass={faClass}
        mainWrapperStyle={mainWrapperStyle}
      />
      {!hideContent ? (
        <CollapsingContent
          collapsed={collapsed}
          content={content}
          minHeight={minHeight}
        />
      ) : ''}
    </div>
  )
}

CollapsingBar.propTypes = {
  collapsed: PropTypes.bool,
  theme: PropTypes.theme,
  handleCollapser: PropTypes.func,
  mainWrapperStyle: PropTypes.objectOf(PropTypes.any),
  content: PropTypes.node,
  contentHeader: PropTypes.node,
  hideContent: PropTypes.bool,
  text: PropTypes.string,
  headerWrapClasses: PropTypes.string,
  faClass: PropTypes.string,
  minHeight: PropTypes.string,
  showArrow: PropTypes.bool
}

CollapsingBar.defaultProps = {
  collapsed: false,
  theme: null,
  handleCollapser: null,
  content: '',
  contentHeader: '',
  headerWrapClasses: '',
  mainWrapperStyle: {},
  text: '',
  hideContent: false,
  faClass: '',
  contentStyle: {},
  minHeight: '',
  showArrow: false
}
