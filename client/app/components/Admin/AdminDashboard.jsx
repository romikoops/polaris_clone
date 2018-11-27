import React, { Component } from 'react'
import PropTypes from 'prop-types'
import GreyBox from '../GreyBox/GreyBox'
import ShipmentOverviewCard from '../ShipmentCard/ShipmentOverviewCard'
import { AdminHubCard } from './AdminHubCard'
import { AdminClientCardIndex } from './AdminClientCardIndex'
import AdminRouteList from './RouteList'
import { WorldMap } from './DashboardMap/WorldMap'
import { gradientTextGenerator } from '../../helpers'
import isQuote from '../../helpers/tenant'
import styles from './AdminDashboard.scss'
import GenericError from '../../components/ErrorHandling/Generic'

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
    this.determinePerPage = this.determinePerPage.bind(this)
    this.handleShipmentAction = this.handleShipmentAction.bind(this)
    this.handleRouteHover = this.handleRouteHover.bind(this)
  }
  componentDidMount () {
    window.scrollTo(0, 0)
    this.determinePerPage()
    window.addEventListener('resize', this.determinePerPage)
    this.props.setCurrentUrl(this.props.match.url)
  }
  componentWillUnmount () {
    window.removeEventListener('resize', this.determinePerPage)
  }

  handleRouteHover (route) {
    this.setState((prevState) => ({ hoverId: prevState.hoverId === route.id ? false : route.id }))
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
    adminDispatch.getShipments(1, 1, 1, 4, true)
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
  determinePerPage () {
    const width = window.innerWidth
    const perPage = width >= 1920 ? 3 : 2
    this.setState({ perPage })
  }

  render () {
    const {
      user,
      clients,
      shipments,
      hubHash,
      dashData,
      confirmShipmentData,
      adminDispatch,
      theme,
      tenant
    } = this.props
    const { hoverId, perPage } = this.state

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
    const shipmentsToDisplay = isQuote(tenant) ? shipments.quoted : shipments.requested
    const preppedShipments = shipmentsToDisplay ? shipmentsToDisplay.slice(0, perPage)
      .map(s => AdminDashboard.prepShipment(s, clientHash, hubHash)) : []

    const mapComponent = (
      <div className="layout-row flex-100 layout-align-space-between-stretch layout-wrap">
        <div className="flex-gt-md-50 layout-padding flex-100">
          <AdminRouteList
            routes={itineraries}
            onClickRoute={itinerary => adminDispatch.loadItinerarySchedules(itinerary.id, true)}
            onMouseEnterRoute={this.handleRouteHover}
            onMouseLeaveRoute={this.handleRouteHover}
            theme={theme}
          />
        </div>
        <div className="flex-gt-md-50 layout-padding layout-row layout-align-center-center flex-100 hide_overflow">
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
      <GenericError theme={theme}>
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
            <span><b>{isQuote(tenant) ? 'Quoted Shipments' : 'Requested Shipments' }</b></span>
          </div>
          <ShipmentOverviewCard
            admin
            noTitle
            confirmShipmentData={confirmShipmentData}
            handleSelect={this.handleClick}
            dispatches={adminDispatch}
            shipments={preppedShipments}
            theme={theme}
            hubs={hubHash}
            handleAction={this.handleShipmentAction}
          />
          <div className={`layout-row flex-100 layout-align-center-center ${styles.space}`}>
            <span className="flex-15" onClick={() => this.handleViewShipments()}><u><b>See more shipments</b></u></span>
            <div className={`flex-85 ${styles.separator}`} />
          </div>
          <div className="margin_bottom flex-100">
            <GreyBox
              flex={100}
              content={mapComponent}
            />
          </div>
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
                viewClient={id => adminDispatch.getClient(id, true)}
                theme={theme}
              />
              <div className={`layout-row flex-100 layout-align-center-center ${styles.space}`}>
                <span className="flex-20" onClick={() => this.handleViewClients()}><u><b>See more</b></u></span>
                <div className={`flex-80 ${styles.separator}`} />
              </div>
            </div>
          </div>
        </div>
      </GenericError>
    )
  }
}

AdminDashboard.propTypes = {
  // eslint-disable-next-line react/forbid-prop-types
  user: PropTypes.any,
  theme: PropTypes.theme,
  tenant: PropTypes.tenant.isRequired,
  dashData: PropTypes.shape({
    schedules: PropTypes.array
  }),
  confirmShipmentData: PropTypes.objectOf(PropTypes.any),
  handleClick: PropTypes.func,
  setCurrentUrl: PropTypes.func.isRequired,
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
  scope: {},
  confirmShipmentData: {},
  user: {},
  dashData: null,
  handleClick: null,
  clients: [],
  shipments: {},
  hubHash: {}
}

export default AdminDashboard
