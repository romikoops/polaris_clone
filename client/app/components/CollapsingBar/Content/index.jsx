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
    const { collapsed, content } = this.props
    const { firstRender } = this.state
    return (
      <div
        className={`${collapsed && !firstRender ? styles.collapsed : ''} ${styles.main_panel}`}
        style={{
          maxHeight: this.state.panelHeight,
          transition: `max-height ${Math.log(1 + this.state.panelHeight) / 10}s linear`
        }}
        ref={(div) => { this.panel = div }}
      >
        <div className={
          `${styles.inner_wrapper} flex-100 ` +
          'layout-row layout-wrap layout-align-start-start'
        }
        >
          { content }
        </div>
      </div>
    )
  }
}

CollapsingContent.propTypes = {
  collapsed: Proptypes.bool,
  content: Proptypes.node
}

CollapsingContent.defaultProps = {
  collapsed: false,
  content: ''
}
