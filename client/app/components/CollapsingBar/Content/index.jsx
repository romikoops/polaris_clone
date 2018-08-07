import React from 'react'
import Proptypes from '../../../prop-types'
import styles from './CollapsingContent.scss'

export default class CollapsingContent extends React.PureComponent {
  constructor (props) {
    super(props)
    this.state = { firstRender: true }
    this.setFirstRenderTo = this.setFirstRenderTo.bind(this)
  }
  componentDidMount () {
    this.setFirstRenderTo(false)
    this.updateHeight()
  }
  componentDidUpdate () {
    this.updateHeight()
  }
  setFirstRenderTo (bool) {
    this.setState({ firstRender: bool })
  }
  updateHeight () {
    const panelHeight = this.panel.clientHeight
    if (panelHeight > this.state.panelHeight || !this.state.panelHeight) {
      this.setState({ panelHeight: this.panel.clientHeight })
    }
  }
  render () {
    const { collapsed, content, minHeight } = this.props
    const { firstRender } = this.state
    if (!collapsed) {
      // debugger // eslint-disable-line
    }

    return (
      <div
        className={`${collapsed && !firstRender ? styles.collapsed : ''} ${styles.main_panel}`}
        style={{
          minHeight: `${!collapsed ? minHeight : ''}`,
          maxHeight: this.state.panelHeight,
          transition: `max-height ${Math.log(1 + this.state.panelHeight) / 10}s linear`
        }}
      >
        <div
          className={
            `${styles.inner_wrapper} flex-100 ` +
          'layout-row layout-wrap layout-align-start-start'
          }
          ref={(div) => { this.panel = div }}
        >
          { content }
        </div>
      </div>
    )
  }
}

CollapsingContent.propTypes = {
  collapsed: Proptypes.bool,
  content: Proptypes.node,
  minHeight: Proptypes.string
}

CollapsingContent.defaultProps = {
  collapsed: false,
  content: '',
  minHeight: ''
}
