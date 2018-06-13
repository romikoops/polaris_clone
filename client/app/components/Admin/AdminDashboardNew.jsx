import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { GreyBox as GBox } from '../GreyBox/GreyBox'
import { ShipmentCards as ShipCards } from '../ShipmentCardNew/ShipmentCards'
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
    const hubOrigin = shipment.schedule_set[0].origin_hub_id
    const hubDestination = shipment.schedule_set[0].destination_hub_id
    shipment.originHub = hubsObj[hubOrigin] ? hubsObj[hubOrigin].name : ''
    shipment.destinationHub = hubsObj[hubDestination] ? hubsObj[hubDestination].name : ''
    return shipment
  }

  constructor (props) {
    super(props)
    this.state = {
      hoverId: false
    }
  }
  handleRouteHover (id) {
    this.setState((prevState) => {
      const { hoverId } = prevState
      return { hoverId: hoverId === id ? false : id }
    })
  }

  render () {
    const {
      user,
      clients,
      shipments,
      hubHash,
      dashData,
      adminDispatch
    } = this.props
    const { hoverId } = this.state

    if (!dashData) return ''
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
        <img src="/app/assets/images/logos/logo_black.png" style={{ height: '90px' }} />
      </div>
    )

    const mapComponent = (
      <div className="layout-row flex-100 layout-align-space-between-stretch layout-wrap">
        <div className="flex-gt-md-50 layout-padding flex-100">
          <ARouteList
            itineraries={itineraries}
            handleClick={itinerary => adminDispatch.loadItinerarySchedules(itinerary.id, true)}
            hoverFn={e => this.handleRouteHover(e)}
          />
        </div>
        <div className="flex-gt-md-50 layout-padding layout-row layout-align-center-center flex-100">
          <WMap
            itineraries={itineraries}
            hoverId={hoverId}
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
        <ShipCards
          admin
          dispatches={adminDispatch}
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
          <div className="flex-gt-md-60 flex-100">
            <AHubCards
              hubs={hubHash}
              adminDispatch={adminDispatch}
            />
            <div className={`layout-row flex-100 layout-align-center-center ${astyles.space}`}>
              <span className="flex-15"><u><b>See more</b></u></span>
              <div className={`flex-85 ${astyles.separator}`} />
            </div>
          </div>
          <div className="flex-gt-md-35 flex-100">
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
  hubHash: PropTypes.objectOf(PropTypes.hub),
  adminDispatch: PropTypes.shape({
    getDashboard: PropTypes.func,
    getShipment: PropTypes.func,
    getHub: PropTypes.func,
    confirmShipment: PropTypes.func
  }).isRequired
}

AdminDashboardNew.defaultProps = {
  user: {},
  dashData: null,
  clients: [],
  shipments: {},
  hubHash: {}
}

export default AdminDashboardNew
