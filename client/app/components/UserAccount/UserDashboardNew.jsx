import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { GreyBox as GBox } from '../GreyBox/GreyBox'
import { ShipmentCards as ShipCards } from '../ShipmentCardNew/ShipmentCards'
import styles from './UserDashboardNew.scss'
// import { adminDashboard as adminTip, activeRoutesData } from '../../constants'

export class UserDashboardNew extends Component {
  static prepShipment (baseShipment, clients, hubsObj) {
    const shipment = Object.assign({}, baseShipment)
    shipment.clientName = clients[shipment.user_id]
      ? `${clients[shipment.user_id].first_name} ${clients[shipment.user_id].last_name}`
      : ''
    shipment.companyName = clients[shipment.user_id]
      ? `${clients[shipment.user_id].company_name}`
      : ''
    const hubKeys = shipment.schedule_set[0].hub_route_key.split('-')
    shipment.originHub = hubsObj[hubKeys[0]] ? hubsObj[hubKeys[0]] : ''
    shipment.destinationHub = hubsObj[hubKeys[1]] ? hubsObj[hubKeys[1]] : ''
    return shipment
  }

  constructor (props) {
    super(props)
    this.state = {}
  }

  render () {
    const {
      user,
      dashboard,
      shipments,
      hubHash
    } = this.props

    const userHash = {}
    if (dashboard.contacts) {
      dashboard.contacts.forEach((us) => {
        userHash[us.user_id] = us
      })
    }

    const preparedRequestedShipments = shipments.requested ? shipments.requested
      .map(s => UserDashboardNew.prepShipment(s, userHash, hubHash)) : []

    const header1 = (
      <div className={`layout-row flex-100 layout-align-start-center ${styles.headerElement}`}>
        <span className="layout-row flex-20 layout-align-center-center">
          <i className={`fa fa-user ${styles.bigProfile}`} />
        </span>
        <span className={`${styles.welcome}`}>Welcome back, <b>{user.first_name}</b></span>
      </div>
    )

    const header2 = (
      <div className="layout-row layout-padding flex-100 layout-align-center-center">
        <img src="/app/assets/images/logos/logo_black.png" />
      </div>
    )

    return (
      <div
        className={
          `layout-row flex-100 layout-wrap layout-align-start-center ${styles.container}`
        }
      >
        <div
          className={
            `layout-row flex-100 layout-align-space-between-start ${styles.header}`
          }
        >
          <GBox
            flex={70}
            component={header1}
          />
          <GBox
            flex={25}
            component={header2}
          />
        </div>
        <ShipCards
          shipments={preparedRequestedShipments}
        />
        <div className={`layout-row flex-100 layout-align-center-center ${styles.space}`}>
          <span className="flex-15"><u><b>See more shipments</b></u></span>
          <div className={`flex-85 ${styles.separator}`} />
        </div>
      </div>
    )
  }
}

UserDashboardNew.propTypes = {
  // eslint-disable-next-line react/forbid-prop-types
  user: PropTypes.any,
  dashboard: PropTypes.shape({
    shipments: PropTypes.shipments,
    pricings: PropTypes.objectOf(PropTypes.string),
    contacts: PropTypes.arrayOf(PropTypes.object),
    locations: PropTypes.arrayOf(PropTypes.location)
  }),
  shipments: PropTypes.shape({
    open: PropTypes.arrayOf(PropTypes.shipment),
    requested: PropTypes.arrayOf(PropTypes.shipment),
    finished: PropTypes.arrayOf(PropTypes.shipment)
  }),
  hubHash: PropTypes.objectOf(PropTypes.hub)
}

UserDashboardNew.defaultProps = {
  user: {},
  dashboard: null,
  shipments: {},
  hubHash: {}
}

export default UserDashboardNew
