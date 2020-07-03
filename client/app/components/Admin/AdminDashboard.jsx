import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import GreyBox from '../GreyBox/GreyBox'
import ShipmentOverviewCard from '../ShipmentCard/ShipmentOverviewCard'
import AdminHubsComp from './Hubs/AdminHubsComp'
import AdminClientCardIndex from './AdminClientCardIndex'
import AdminRouteList from './RouteList'
import { WorldMap } from './DashboardMap/WorldMap'
import { gradientTextGenerator } from '../../helpers'
import isQuote from '../../helpers/tenant'
import styles from './AdminDashboard.scss'
import GenericError from '../ErrorHandling/Generic'

export class AdminDashboard extends Component {
  constructor (props) {
    super(props)
    this.state = {
      hoverId: false
    }
    this.handleClick = this.handleClick.bind(this)
    this.determinePerPage = this.determinePerPage.bind(this)
    this.handleShipmentAction = this.handleShipmentAction.bind(this)
    this.handleRouteHover = this.handleRouteHover.bind(this)
    this.viewHub = this.viewHub.bind(this)
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
    this.setState(prevState => ({ hoverId: prevState.hoverId === route.id ? false : route.id }))
  }

  handleViewHubs () {
    const { adminDispatch } = this.props
    adminDispatch.goTo('/admin/hubs')
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

  viewHub (hub) {
    const { adminDispatch } = this.props
    adminDispatch.getHub(hub.id, true)
  }

  render () {
    const {
      t,
      user,
      clients,
      shipments,
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
    const preppedShipments = shipmentsToDisplay ? shipmentsToDisplay.slice(0, perPage) : []

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
              <span className={`${styles.welcome} flex-90 layout-row`}>
                {t('common:welcomeBack')}
&nbsp;
                {' '}
                <b>{user.first_name}</b>
              </span>
            </div>
          </div>
          <div className="layout-padding flex-100 layout-align-start-center greyBg">
            <span><b>{isQuote(tenant) ? t('admin:quotedShipments') : t('admin:requestedShipments')}</b></span>
          </div>
          <ShipmentOverviewCard
            admin
            noTitle
            confirmShipmentData={confirmShipmentData}
            handleSelect={this.handleClick}
            dispatches={adminDispatch}
            shipments={preppedShipments}
            theme={theme}
            handleAction={this.handleShipmentAction}
          />
          <div className={`layout-row flex-100 layout-align-center-center ${styles.space}`}>
            <span className="flex-15" onClick={() => this.handleViewShipments()}><u><b>{t('shipment:seeMoreShipments')}</b></u></span>
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
              <AdminHubsComp showLocalExpiry={false} perPage={10} handleClick={this.viewHub}/>
              <div className={`layout-row flex-100 layout-align-center-center ${styles.space}`}>
                <span className="flex-15" onClick={() => this.handleViewHubs()}><u><b>{t('admin:seeMore')}</b></u></span>
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

export default withNamespaces(['admin', 'common', 'shipment'])(AdminDashboard)
