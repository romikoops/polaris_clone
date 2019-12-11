import React from 'react'
import CollapsingHeading from './Heading'
import CollapsingContent from './Content'

export default class CollapsingBar extends React.PureComponent {
  constructor (props) {
    super(props)

    this.state = { collapsed: props.startCollapsed }

    this.handleCollapser = this.handleCollapser.bind(this)
  }

  handleCollapser () {
    this.setState(prevState => ({ collapsed: !prevState.collapsed }))
  }

  render () {
    const {
      collapsed,
      theme,
      handleCollapser,
      headerWrapClasses,
      wrapperContentClasses,
      content,
      text,
      faClass,
      minHeight,
      contentHeader,
      mainWrapperStyle,
      showArrow,
      children,
      hideIcon,
      parentClass,
      showArrowSpacer,
      overflow
    } = this.props

    return (
      <div className={`flex-100 layout-row layout-align-start-center layout-wrap ${parentClass}`}>
        <CollapsingHeading
          text={text}
          hideIcon={hideIcon}
          showArrow={showArrow}
          showArrowSpacer={showArrowSpacer}
          contentHeader={contentHeader}
          collapsed={collapsed != null ? collapsed : this.state.collapsed}
          theme={theme}
          headerWrapClasses={headerWrapClasses}
          handleCollapser={handleCollapser || this.handleCollapser}
          faClass={faClass}
          mainWrapperStyle={mainWrapperStyle}
        />
        <CollapsingContent
          collapsed={collapsed != null ? collapsed : this.state.collapsed}
          content={content || children}
          overflow={overflow}
          wrapperContentClasses={wrapperContentClasses}
          minHeight={minHeight}
        />
      </div>
    )
  }
}

CollapsingBar.defaultProps = {
  collapsed: null,
  theme: null,
  handleCollapser: null,
  content: '',
  contentHeader: '',
  headerWrapClasses: '',
  mainWrapperStyle: {},
  text: '',
  wrapperContentClasses: '',
  faClass: '',
  minHeight: '',
  parentClass: '',
  showArrow: false,
  hideIcon: false,
  children: null,
  startCollapsed: false,
  showArrowSpacer: false,
  overflow: false
}
