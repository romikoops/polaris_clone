import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { GreyBox as GBox } from '../GreyBox/GreyBox'
import { AdminShipmentCards as AShipCards } from './AdminShipmentCards'
import { AdminHubCards as AHubCards } from './AdminHubCards'
import { AdminClientCards as AClientCards } from './AdminClientCards'
import { AdminRouteList as ARouteList } from './AdminRouteList'
import { WorldMap as WMap } from './DashboardMap/WorldMap'
// import { TextHeading } from '../TextHeading/TextHeading'
import astyles from './AdminDashboardNew.scss'
// import { adminDashboard as adminTip, activeRoutesData } from '../../constants'

export class AdminDashboardNew extends Component {
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
      clients,
      shipments,
      hubHash,
      dashData
    } = this.props

    const { itineraries } = dashData

    const clientHash = {}
    if (clients) {
      clients.forEach((cl) => {
        clientHash[cl.id] = cl
      })
    }

    const preparedRequestedShipments = shipments.requested ? shipments.requested
      .map(s => AdminDashboardNew.prepShipment(s, clientHash, hubHash)) : []

    const header1 = (
      <div className={`layout-row flex-100 layout-align-start-center ${astyles.headerElement}`}>
        <span className="layout-row flex-20 layout-align-center-center">
          <i className={`fa fa-user ${astyles.bigProfile}`} />
        </span>
        <span className={`${astyles.welcome}`}>Welcome back, <b>{user.first_name}</b></span>
      </div>
    )

    const header2 = (
      <div className="layout-row layout-padding flex-100 layout-align-center-center">
        <img src="/app/assets/images/logos/logo_black.png" />
      </div>
    )

    const mapComponent = (
      <div className="layout-row flex-100 layout-align-space-between-stretch">
        <div className="flex-45 flex-sm-100">
          <ARouteList
            shipments={preparedRequestedShipments}
          />
        </div>
        <div className="flex-55 flex-sm-0">
          <WMap
            itineraries={itineraries}
          />
        </div>
      </div>
    )

    return (
      <div
        className={
          `layout-row flex-100 layout-wrap layout-align-start-center ${astyles.container}`
        }
      >
        <div
          className={
            `layout-row flex-100 layout-align-space-between-start ${astyles.header}`
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
        <AShipCards
          shipments={preparedRequestedShipments}
        />
        <div className={`layout-row flex-100 layout-align-center-center ${astyles.space}`}>
          <span className="flex-15"><u><b>See more shipments</b></u></span>
          <div className={`flex-85 ${astyles.separator}`} />
        </div>
        <GBox
          padding
          flex={100}
          component={mapComponent}
        />
        <div className="layout-row layout-wrap flex-100 layout-align-space-between-stretch">
          <div className="flex-60 flex-sm-100">
            <AHubCards
              hubs={hubHash}
            />
            <div className={`layout-row flex-100 layout-align-center-center ${astyles.space}`}>
              <span className="flex-15"><u><b>See more</b></u></span>
              <div className={`flex-85 ${astyles.separator}`} />
            </div>
          </div>
          <div className="flex-35 flex-sm-100">
            <AClientCards
              clients={clients}
            />
            <div className={`layout-row flex-100 layout-align-center-center ${astyles.space}`}>
              <span className="flex-20"><u><b>See more</b></u></span>
              <div className={`flex-80 ${astyles.separator}`} />
            </div>
          </div>
        </div>
      </div>
    )
  }
}

AdminDashboardNew.propTypes = {
  // eslint-disable-next-line react/forbid-prop-types
  user: PropTypes.any,
  dashData: PropTypes.shape({
    schedules: PropTypes.array
  }),
  clients: PropTypes.arrayOf(PropTypes.client),
  shipments: PropTypes.shape({
    open: PropTypes.arrayOf(PropTypes.shipment),
    requested: PropTypes.arrayOf(PropTypes.shipment),
    finished: PropTypes.arrayOf(PropTypes.shipment)
  }),
  hubHash: PropTypes.objectOf(PropTypes.hub)
}

AdminDashboardNew.defaultProps = {
  user: {},
  dashData: null,
  clients: [],
  shipments: {},
  hubHash: {}
}

export default AdminDashboardNew
