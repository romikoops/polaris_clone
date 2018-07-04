import React, { Component } from 'react'
import moment from 'moment'
import PropTypes from 'prop-types'
import styles from './AdminShipmentCard.scss'
import { totalPrice, formattedPriceValue } from '../../helpers'

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

export class AdminShipmentCard extends Component {
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
        <div className={`layout-row layout-align-space-around-center ${styles.topRight}`}>
          <i className={`fa fa-check ${styles.check}`} />
          <i className={`fa fa-edit ${styles.edit}`} />
          <i className={`fa fa-trash ${styles.trash}`} />
        </div>
        <div className="layout-row layout-wrap flex-10 layout-wrap layout-align-center-center">
          <span className={`flex-100 ${styles.title}`}>Ref: <b>{shipment.imc_reference}</b></span>
        </div>
        <div className={`layout-row flex-50 layout-align-space-between-stretch ${styles.section}`}>
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
        <div className={`layout-row flex-25 layout-align-start-stretch
            ${styles.section} ${styles.separatorTop} ${styles.smallText}`}
        >
          <div className="layout-column flex-25">
            <span className="flex-100"><b>Pickup Date</b><br />
              <span className={`${styles.grey}`}>
                {moment(shipment.planned_pickup_date).format('DD/MM/YYYY')}
              </span>
            </span>
          </div>
          <div className="layout-column flex-25">
            <span className="flex-100"><b>ETD</b><br />
              <span className={`${styles.grey}`}>
                {moment(shipment.planned_etd).format('DD/MM/YYYY')}
              </span>
            </span>
          </div>
          <div className="layout-column flex-25">
            <span className="flex-100"><b>ETA</b><br />
              <span className={`${styles.grey}`}>
                {moment(shipment.planned_eta).format('DD/MM/YYYY')}
              </span>
            </span>
          </div>
          <div className="layout-column flex-25">
            <span className="flex-100"><b>Estimated Transit Time</b><br />
              <span className={`${styles.grey}`}>
                {moment(shipment.planned_eta).diff(shipment.planned_etd, 'days')} days
              </span>
            </span>
          </div>
        </div>
        <div className={`layout-row flex-25 layout-align-space-between-center
            ${styles.sectionBottom} ${styles.separatorTop}`}
        >
          <div className="layout-row flex-60 layout-align-start-center">
            <div className="layout-row flex-15">
              <div className={`layout-row layout-align-center-center ${styles.greenIcon}`}>
                <span className={`${styles.smallText}`}>
                  <b>x</b><span className={`${styles.bigText}`}>1</span>
                </span>
              </div>
            </div>
            <span className="flex-30">Cargo item</span>
            <span className={`flex-30 ${shipment.planned_pickup_date ? '' : styles.noDisplay}`}>
              <i className={`fa fa-check-square ${styles.darkgreen}`} />
              <span> pickup</span>
            </span>
            <span className="flex-30">
              <i className={`fa fa-check-square ${styles.grey}`} />
              <span> delivery</span>
            </span>
          </div>
          <div className="layout-align-end-center">
            <span className={`${styles.bigText}`}>
              <span>{totalPrice(shipment).currency} </span>
              <span>
                {formattedPriceValue(totalPrice(shipment).value)}
              </span>
            </span>
          </div>
        </div>
      </div>
    )
  }
}

AdminShipmentCard.propTypes = {
  shipment: PropTypes.objectOf(PropTypes.shipment)
}

AdminShipmentCard.defaultProps = {
  shipment: {}
}

export default AdminShipmentCard
