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

    this.setState(prevState => (
      panelHeight > prevState.panelHeight || !prevState.panelHeight ? { panelHeight } : {}
    ))
  }
  render () {
    const {
      collapsed, content, children, minHeight
    } = this.props
    const { firstRender } = this.state

    return (
      <div
        className={`${collapsed && !firstRender ? styles.collapsed : ''} ${styles.main_panel}`}
        style={{
          minHeight: `${!collapsed ? minHeight : ''}`,
          maxHeight: this.state.panelHeight,
          transition: `max-height ${Math.log(1 + this.state.panelHeight) / 10}s linear`
        }}
      >
        <div className="flex-none" ref={(div) => { this.panel = div }}>
          { content }
          { children }
        </div>
      </div>
    )
  }
}

CollapsingContent.propTypes = {
  collapsed: Proptypes.bool,
  content: Proptypes.node,
  minHeight: Proptypes.string,
  children: Proptypes.arrayOf(Proptypes.node)
}

CollapsingContent.defaultProps = {
  collapsed: false,
  content: '',
  minHeight: '',
  children: null
}
