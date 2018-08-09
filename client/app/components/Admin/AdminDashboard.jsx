import React, { Component } from 'react'
import PropTypes from 'prop-types'
import GreyBox from '../GreyBox/GreyBox'
import { ShipmentOverviewCard } from '../ShipmentCard/ShipmentOverviewCard'
import { AdminHubCard } from './AdminHubCard'
import { AdminClientCardIndex } from './AdminClientCardIndex'
import { AdminRouteList } from './AdminRouteList'
import { WorldMap } from './DashboardMap/WorldMap'
import { gradientTextGenerator } from '../../helpers'
import styles from './AdminDashboard.scss'

export class AdminDashboard extends Component {
  static prepShipment (baseShipment, clients, hubsObj) {
    const shipment = Object.assign({}, baseShipment)
    shipment.clientName = clients[shipment.user_id]
      ? `${clients[shipment.user_id].first_name} ${clients[shipment.user_id].last_name}`
      : ''
    shipment.companyName = clients[shipment.user_id]
      ? `${clients[shipment.user_id].company_name}`
      : ''

    return shipment
  }

  constructor (props) {
    super(props)
    this.state = {
      hoverId: false
    }
    this.handleClick = this.handleClick.bind(this)
    this.handleShipmentAction = this.handleShipmentAction.bind(this)
  }

  handleRouteHover (id) {
    this.setState((prevState) => {
      const { hoverId } = prevState

      return { hoverId: hoverId === id ? false : id }
    })
  }

  handleViewHubs () {
    const { adminDispatch } = this.props
    adminDispatch.getHubs(true)
  }

  handleViewClients () {
    const { adminDispatch } = this.props
    adminDispatch.getClients(true)
  }

  handleViewShipments () {
    const { adminDispatch } = this.props
    adminDispatch.getShipments(true)
  }
  handleShipmentAction (id, action) {
    const { adminDispatch } = this.props
    adminDispatch.confirmShipment(id, action)
  }
  handleClick (shipment) {
    const { handleClick, adminDispatch } = this.props
    if (handleClick) {
      handleClick(shipment)
    } else {
      adminDispatch.getShipment(shipment.id, true)
    }
  }

  render () {
    const {
      user,
      clients,
      shipments,
      hubHash,
      dashData,
      adminDispatch,
      theme
    } = this.props
    const { hoverId } = this.state

    if (!dashData) return ''
    const { itineraries, mapData } = dashData

    const clientHash = {}
    if (clients) {
      clients.forEach((cl) => {
        clientHash[cl.id] = cl
      })
    }

    const gradientFontStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }

    const preparedRequestedShipments = shipments.requested ? shipments.requested
      .map(s => AdminDashboard.prepShipment(s, clientHash, hubHash)) : []

    const mapComponent = (
      <div className="layout-row flex-100 layout-align-space-between-stretch layout-wrap">
        <div className="flex-gt-md-50 layout-padding flex-100">
          <AdminRouteList
            itineraries={itineraries}
            handleClick={itinerary => adminDispatch.loadItinerarySchedules(itinerary.id, true)}
            hoverFn={e => this.handleRouteHover(e)}
            theme={theme}
          />
        </div>
        <div className="flex-gt-md-50 layout-padding layout-row layout-align-center-center flex-100">
          <WorldMap
            itineraries={itineraries}
            hoverId={hoverId}
            theme={theme}
            mapData={mapData}
          />
        </div>
      </div>
    )

    return (
      <div
        className={
          `layout-row flex-100 layout-wrap layout-align-start-center extra_padding ${styles.container}`
        }
      >
        <div
          className={
            `layout-row flex-100 layout-align-space-between-start ${styles.header}`
          }
        >
          <div className={`layout-row flex-100 layout-align-start-center ${styles.headerElement}`}>
            <span className="layout-row flex-10 layout-align-center-center">
              <i className={`fa fa-user clip ${styles.bigProfile}`} style={gradientFontStyle} />
            </span>
            <span className={`${styles.welcome} flex-90 layout-row`}>Welcome back,&nbsp; <b>{user.first_name}</b></span>
          </div>
        </div>
        <div className="layout-padding flex-100 layout-align-start-center greyBg">
          <span><b>Requested Shipments</b></span>
        </div>
        <ShipmentOverviewCard
          admin
          noTitle
          handleSelect={this.handleClick}
          dispatches={adminDispatch}
          shipments={preparedRequestedShipments}
          theme={theme}
          hubs={hubHash}
          handleAction={this.handleShipmentAction}
        />
        <div className={`layout-row flex-100 layout-align-center-center ${styles.space}`}>
          <span className="flex-15" onClick={() => this.handleViewShipments()}><u><b>See more shipments</b></u></span>
          <div className={`flex-85 ${styles.separator}`} />
        </div>
        <GreyBox
          flex={100}
          component={mapComponent}
        />
        <div className="layout-row layout-wrap flex-100 layout-align-space-between-stretch">
          <div className="flex-gt-md-60 flex-100">
            <AdminHubCard
              hubs={hubHash}
              adminDispatch={adminDispatch}
              theme={theme}
            />
            <div className={`layout-row flex-100 layout-align-center-center ${styles.space}`}>
              <span className="flex-15" onClick={() => this.handleViewHubs()}><u><b>See more</b></u></span>
              <div className={`flex-85 ${styles.separator}`} />
            </div>
          </div>
          <div className="flex-gt-md-35 flex-100">
            <AdminClientCardIndex
              clients={clients}
              theme={theme}
            />
            <div className={`layout-row flex-100 layout-align-center-center ${styles.space}`}>
              <span className="flex-20" onClick={() => this.handleViewClients()}><u><b>See more</b></u></span>
              <div className={`flex-80 ${styles.separator}`} />
            </div>
          </div>
        </div>
      </div>
    )
  }
}

AdminDashboard.propTypes = {
  // eslint-disable-next-line react/forbid-prop-types
  user: PropTypes.any,
  theme: PropTypes.theme,
  dashData: PropTypes.shape({
    schedules: PropTypes.array
  }),
  handleClick: PropTypes.func,
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

AdminDashboard.defaultProps = {
  theme: null,
  user: {},
  dashData: null,
  handleClick: null,
  clients: [],
  shipments: {},
  hubHash: {}
}

export default AdminDashboard
