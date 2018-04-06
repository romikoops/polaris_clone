import React from 'react'
import Proptypes from '../../../prop-types'
import styles from './ShipmentCardMainPanel.scss'

export default class ShipmentCardMainPanel extends React.PureComponent {
  constructor (props) {
    super(props)
    this.state = {}
  }
  componentDidMount () {
    this.updateHeight()
  }
  componentDidUpdate () {
    this.updateHeight()
  }
  updateHeight () {
    const panelHeight = this.panel.clientHeight
    if (panelHeight > this.state.panelHeight || !this.state.panelHeight) {
      this.setState({ panelHeight: this.panel.clientHeight })
    }
  }
  render () {
    const { collapsed, content } = this.props
    return (
      <div
        className={`${collapsed ? styles.collapsed : ''} ${styles.main_panel}`}
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

ShipmentCardMainPanel.propTypes = {
  collapsed: Proptypes.bool,
  content: Proptypes.node
}

ShipmentCardMainPanel.defaultProps = {
  collapsed: false,
  content: ''
}
