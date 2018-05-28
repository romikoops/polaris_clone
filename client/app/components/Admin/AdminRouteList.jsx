import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './AdminRouteList.scss'

function stationType (transportMode) {
  let type

  switch (transportMode) {
    case 'ocean':
      type = 'Port'
      break
    case 'air':
      type = 'Airport'
      break
    case 'train':
      type = 'Station'
      break
    default:
      type = ''
      break
  }

  return type
}

function listShipments (shipments) {
  return shipments.map(shipment => (
    <div className={`layout-row layout-padding layout-align-space-around-stretch
        ${styles.listelement}`}
    >
      <div className="layout-row layout-align-center-center">
        <div className={`layout-row layout-align-center-center ${styles.routeIcon}`}>
          <i className="fa fa-ship" />
        </div>
      </div>
      <div className="layout-column layout-align-center-start">
        <span className="layout-padding">
          {shipment.originHub.location.city}<br />
          {stationType(shipment.originHub.data.hub_type)}
        </span>
      </div>
      <div className={`layout-row layout-align-center-center ${styles.icon}`}>
        <i className="fa fa-angle-double-right" />
      </div>
      <div className="layout-column layout-align-center-start">
        <span className="layout-padding">
          {shipment.destinationHub.location.city}<br />
          {stationType(shipment.destinationHub.data.hub_type)}
        </span>
      </div>
    </div>
  ))
}

export class AdminRouteList extends Component {
  constructor (props) {
    super(props)

    this.state = {}
  }

  render () {
    const {
      shipments
    } = this.props

    // const shipments = ['asd', 'asd', 'asd', 'asd', 'asd', 'asd', 'asd']

    return (
      <div className={`layout-column flex-100 layout-align-start-stretch ${styles.container}`}>
        <div className={`layout-padding layout-align-start-center ${styles.greyBg}`}>
          <span><b>Routes</b></span>
        </div>
        <div className={`layout-align-start-stretch ${styles.list}`}>
          {listShipments(shipments)}
        </div>
      </div>
    )
  }
}

AdminRouteList.propTypes = {
  shipments: PropTypes.arrayOf(PropTypes.shipment)
}

AdminRouteList.defaultProps = {
  shipments: {}
}

export default AdminRouteList
