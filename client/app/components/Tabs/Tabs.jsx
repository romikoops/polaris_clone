import React, { PureComponent } from 'react'
import PropTypes from '../../prop-types'

export default class Tabs extends PureComponent {
  constructor (props, context) {
    super(props, context)
    this.state = {
      activeTabIndex: this.props.defaultActiveTabIndex ? this.props.defaultActiveTabIndex : 0
    }
    this.handleTabClick = this.handleTabClick.bind(this)
  }

  handleTabClick (tabIndex) {
    this.setState({
      activeTabIndex: tabIndex === this.state.activeTabIndex ? this.props.defaultActiveTabIndex : tabIndex
    })
  }

  // Encapsulate <Tabs/> component API as props for <Tab/> children
  renderChildrenWithTabsApiAsProps () {
    return React.Children.map(this.props.children, (child, index) => React.cloneElement(child, {
      onClick: this.handleTabClick,
      tabIndex: index,
      isActive: index === this.state.activeTabIndex
    }))
  }

  // Render current active tab content
  renderActiveTabContent () {
    const { children } = this.props
    const { activeTabIndex } = this.state
    if (children[activeTabIndex]) {
      return children[activeTabIndex].props.children
    }
    return ''
  }

  render () {
    const { wrapperTabs } = this.props

    return (
      <div className="layout-column flex-100">
        <div className="layout-row flex-100">
          <div className={wrapperTabs}>
            {this.renderChildrenWithTabsApiAsProps()}
          </div>
        </div>
        <div className="tabs-active-content">
          {this.renderActiveTabContent()}
        </div>
      </div>
    )
  }
}

Tabs.propTypes = {
  defaultActiveTabIndex: PropTypes.number,
  children: PropTypes.node,
  wrapperTabs: PropTypes.string

}

Tabs.defaultProps = {
  wrapperTabs: 'layout-row flex-40',
  defaultActiveTabIndex: 0,
  children: null
}
