import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './AdminShipmentStatus.scss'

export class AdminShipmentStatus extends Component {
  constructor (props) {
    super(props)
    this.state = {
      shipments: props.shipments
    }
  }

  render () {
    return (
      <div className="layout-column flex-100 layout-wrap layout-align-start-stretch">
        <div className="layout-column flex-20 layout-wrap layout-align-start-center">
          <span className={`${styles.title}`}>Shipment status</span>
          <span className={`${styles.subtitle}`}>This month</span>
        </div>
        <div className="layout-row flex-80 layout-wrap layout-align-center-center">
          <div className="layout-column flex-33 layout-wrap layout-align-center-center">
            <span className={`${styles.amount}`}>
              {this.state.shipments.finished ? this.state.shipments.finished.length : 0}
            </span><br />
            <span className={`${styles.amounttitle}`}>Shipments</span>
          </div>
          <div className="layout-column flex-33 layout-wrap layout-align-center-center">
            <span className={`${styles.amount}`}>
              {this.state.shipments.open ? this.state.shipments.open.length : 0}
            </span><br />
            <span className={`${styles.amounttitle}`}>Active</span>
          </div>
          <div className="layout-column flex-33 layout-wrap layout-align-center-center">
            <span className={`${styles.amount}`}>
              {this.state.shipments.requested ? this.state.shipments.requested.length : 0}
            </span><br />
            <span className={`${styles.amounttitle}`}>Requested</span>
          </div>
        </div>
      </div>
    )
  }
}

AdminShipmentStatus.propTypes = {
  shipments: PropTypes.shape({
    open: PropTypes.arrayOf(PropTypes.shipment),
    requested: PropTypes.arrayOf(PropTypes.shipment),
    finished: PropTypes.arrayOf(PropTypes.shipment)
  })
}

AdminShipmentStatus.defaultProps = {
  shipments: {}
}

export default AdminShipmentStatus
