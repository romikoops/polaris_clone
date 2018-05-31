import React, { Component } from 'react'
import moment from 'moment'
import PropTypes from 'prop-types'
import styles from './ShipmentCard.scss'

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

export class UserShipmentCard extends Component {
  constructor (props) {
    super(props)

    this.state = {}
  }

  render () {
    const {
      shipment
    } = this.props

    return (
      <div
        className={
          `layout-column flex-100 layout-align-start-stretch
          ${styles.container} ${styles.relative}`
        }
      >
        <div
          className={
            `layout-row layout-align-space-around-center ${styles.topRightBox} ${styles.topRightColor}`
          }
        >
          <b>REQUESTED</b>
        </div>
        <div className="layout-row layout-wrap flex-10 layout-wrap layout-align-center-center">
          <span className={`flex-100 ${styles.title}`}>Ref: <b>{shipment.imc_reference}</b></span>
        </div>
        <div className={`layout-row flex-90 layout-align-space-between-stretch ${styles.section}`}>
          <div className={`layout-row flex-50 layout-align-space-between-stretch
              ${styles.relative}`}
          >
            <div className={`layout-column flex-45 ${styles.city}`}>
              <div className="layout-column layout-padding flex-50 layout-align-center-start">
                <span>{shipment.originHub ? shipment.originHub.location.city : ''}<br />
                  {shipment.originHub ? stationType(shipment.originHub.data.hub_type) : ''}
                </span>
              </div>
              <div className="layout-column flex-50">
                <img className="flex-100" src="/app/assets/images/dashboard/stockholm.png" />
              </div>
            </div>
            <div className={`layout-row layout-align-center-center ${styles.routeIcon}`}>
              <i className="fa fa-ship" />
            </div>
            <div className={`layout-column flex-45 ${styles.city}`}>
              <div className="layout-column layout-padding flex-50 layout-align-center-start">
                <span>{shipment.destinationHub ? shipment.destinationHub.location.city : ''}<br />
                  {shipment.destinationHub ? stationType(shipment.destinationHub.data.hub_type) : ''}
                </span>
              </div>
              <div className="layout-column flex-50">
                <img className="flex-100" src="/app/assets/images/dashboard/shanghai.png" />
              </div>
            </div>
          </div>
          <div className="layout-column flex-40">
            <div className="layout-column flex-50 layout-align-center-stretch">
              <div className="layout-row flex-50 layout-align-start-stretch">
                <div className="flex-20">
                  <i className={`fa fa-user ${styles.profileIcon}`} />
                </div>
                <div className="flex-80">{shipment.clientName}</div>
              </div>
              <div className="layout-row flex-50 layout-align-start-stretch">
                <span className="flex-20">
                  <i className={`fa fa-building ${styles.profileIcon}`} />
                </span>
                <span className={`flex-80 ${styles.grey}`}>{shipment.companyName}</span>
              </div>
            </div>
            <div className={`layout-row flex-50 layout-align-end-end ${styles.smallText}`}>
              <span className="flex-80"><b>Booking placed at</b><br />
                <span className={`${styles.grey}`}>
                  {moment(shipment.booking_placed_at).format('DD/MM/YYYY - hh:mm')}
                </span>
              </span>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

UserShipmentCard.propTypes = {
  shipment: PropTypes.objectOf(PropTypes.shipment)
}

UserShipmentCard.defaultProps = {
  shipment: {}
}

export default UserShipmentCard
