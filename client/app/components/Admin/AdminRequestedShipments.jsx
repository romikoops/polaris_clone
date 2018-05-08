import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './AdminRequestedShipments.scss'

export class AdminRequestedShipments extends Component {
  constructor (props) {
    super(props)
    this.showShipments = this.showShipments.bind(this)
    this.state = {
      requested: this.props.requested
    }
  }

  showShipments () {
    return this.state.requested.map(r => (
      <div className={`layout-row layout-wrap layout-align-center-stretch ${styles.shipmentinfo}`}>
        <div className="layout-column flex-25 layout-wrap">
          <div className="layout-row flex-50 layout-wrap layout-align-space-around-center">
            <span className="layout-row flex-25 layout-wrap layout-align-center-center">I</span>
            <span className="layout-row flex-75 layout-wrap layout-align-center-center">Name</span>
          </div>
          <div className="layout-row flex-50 layout-wrap layout-align-space-around-center">
            <span className="layout-row flex-25 layout-wrap layout-align-center-center">I</span>
            <span className="layout-row flex-75 layout-wrap layout-align-center-center">Comp</span>
          </div>
        </div>
        <div className="layout-row flex-25 layout-wrap layout-align-center-center">
          <span>Icon</span>
        </div>
        <div className="layout-column flex-25 layout-wrap layout-align-space-around-center">
          <span>From</span>
          <span>To</span>
        </div>
        <div className="layout-column flex-25 layout-wrap layout-align-space-around-center">
          <span>Amount</span>
          <span>Type</span>
        </div>
      </div>
    ))
  }

  render () {
    return (
      <div className="layout-column flex-100 layout-align-space-start-center">
        <div className="layout-row flex-10 layout-wrap layout-align-space-start-start">
          <span className={`${styles.title}`}>Pending bookings</span>
        </div>
        <div className="layout-column layout-align-space-start-center">
          <div className={`layout-column layout-align-start-stretch ${styles.shipments}`}>
            {this.showShipments()}
          </div>
        </div>
      </div>
    )
  }
}

AdminRequestedShipments.propTypes = {
  requested: PropTypes.node
}

AdminRequestedShipments.defaultProps = {
  requested: ['']
}

export default AdminRequestedShipments
