import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import PropTypes from 'prop-types'
import defaults from '../../styles/default_classes.scss'
import { AdminScheduleLine } from './'
import {
  AdminSearchableRoutes,
  AdminSearchableHubs,
  AdminSearchableClients,
  AdminSearchableShipments
} from './AdminSearchables'
import Loading from '../../components/Loading/Loading'
import { Carousel } from '../Carousel/Carousel'
import style from './AdminDashboard.scss'
import { TextHeading } from '../TextHeading/TextHeading'
import { adminDashboard as adminTip, activeRoutesData } from '../../constants'

export class AdminDashboard extends Component {
  static prepShipment (baseShipment, clients, hubsObj) {
    const shipment = Object.assign({}, baseShipment)
    shipment.clientName = clients[shipment.user_id]
      ? `${clients[shipment.user_id].first_name} ${clients[shipment.user_id].last_name}`
      : ''
    shipment.companyName = clients[shipment.user_id]
      ? `${clients[shipment.user_id].company_name}`
      : ''
    const hubKeys = shipment.schedule_set[0].hub_route_key.split('-')
    shipment.originHub = hubsObj[hubKeys[0]] ? hubsObj[hubKeys[0]].name : ''
    shipment.destinationHub = hubsObj[hubKeys[1]] ? hubsObj[hubKeys[1]].name : ''
    return shipment
  }
  static dynamicSort (property) {
    let sortOrder = 1
    let prop
    if (property[0] === '-') {
      sortOrder = -1
      prop = property.substr(1)
    } else {
      prop = property
    }
    return (a, b) => {
      const result1 = a[prop] < b[prop] ? -1 : a[prop] > b[prop]
      const result2 = result1 ? 1 : 0
      return result2 * sortOrder
    }
  }

  constructor (props) {
    super(props)
    this.state = {}
    this.viewShipment = this.viewShipment.bind(this)
    this.handleShipmentAction = this.handleShipmentAction.bind(this)
  }

  componentDidMount () {
    const {
      dashData, loading, adminDispatch, hubs
    } = this.props
    if (!dashData && !loading) {
      adminDispatch.getDashboard(false)
    } else if (dashData && !dashData.schedules) {
      adminDispatch.getDashboard(false)
    }
    if (!hubs && !loading) {
      adminDispatch.getHubs(false)
    }
  }
  viewShipment (shipment) {
    const { adminDispatch } = this.props
    adminDispatch.getShipment(shipment.id, true)
  }
  viewHub (hub) {
    const { adminDispatch } = this.props
    adminDispatch.getHub(hub.id, true)
  }
  handleShipmentAction (id, action) {
    const { adminDispatch } = this.props
    adminDispatch.confirmShipment(id, action)
  }
  render () {
    const {
      dashData, clients, hubs, hubHash, adminDispatch, theme
    } = this.props
    // ;
    if (!dashData || !hubs) {
      return <Loading theme={theme} />
    }
    const {
      routes, shipments, air, ocean
    } = dashData
    const clientHash = {}

    if (clients) {
      clients.forEach((cl) => {
        clientHash[cl.id] = cl
      })
    }
    const filteredClients = clients ? clients.filter(x => !x.guest) : []
    const schedArr = []

    const mergedOpenShipments =
      shipments && shipments.open
        ? shipments.open
          .sort(AdminDashboard.dynamicSort('-updated_at'))
          .map(sh => AdminDashboard.prepShipment(sh, clientHash, hubHash))
        : false

    const mergedFinishedShipments =
      shipments && shipments.finished
        ? shipments.finished
          .sort(AdminDashboard.dynamicSort('-updated_at'))
          .map(sh => AdminDashboard.prepShipment(sh, clientHash, hubHash))
        : false

    const mergedRequestedShipments =
      shipments && shipments.requested
        ? shipments.requested
          .sort(AdminDashboard.dynamicSort('-updated_at'))
          .map(sh => AdminDashboard.prepShipment(sh, clientHash, hubHash))
        : false

    const requestedShipments = mergedRequestedShipments ? (
      <AdminSearchableShipments
        title="Requested Shipments"
        limit={3}
        hubs={hubHash}
        shipments={mergedRequestedShipments}
        adminDispatch={adminDispatch}
        theme={theme}
        handleClick={this.viewShipment}
        handleShipmentAction={this.handleShipmentAction}
        tooltip={adminTip.requested}
        seeAll={() => adminDispatch.goTo('/admin/shipments/requested')}
      />
    ) : (
      ''
    )

    const openShipments = mergedOpenShipments ? (
      <AdminSearchableShipments
        title="Open Shipments"
        limit={3}
        hubs={hubHash}
        shipments={mergedOpenShipments}
        adminDispatch={adminDispatch}
        theme={theme}
        handleClick={this.viewShipment}
        handleShipmentAction={this.handleShipmentAction}
        tooltip={adminTip.open}
        seeAll={() => adminDispatch.goTo('/admin/shipments/open')}
      />
    ) : (
      ''
    )

    const finishedShipments = mergedFinishedShipments ? (
      <AdminSearchableShipments
        title="Finished Shipments"
        limit={3}
        hubs={hubHash}
        shipments={mergedFinishedShipments}
        adminDispatch={adminDispatch}
        theme={theme}
        handleClick={this.viewShipment}
        handleShipmentAction={this.handleShipmentAction}
        tooltip={adminTip.finished}
        seeAll={() => adminDispatch.goTo('/admin/shipments/finished')}
      />
    ) : (
      ''
    )

    if (air) {
      air.forEach((asched) => {
        schedArr.push(<AdminScheduleLine key={v4()} schedule={asched} hubs={hubs} theme={theme} />)
      })
    }
    if (ocean) {
      ocean.forEach((osched) => {
        schedArr.push(<AdminScheduleLine key={v4()} schedule={osched} hubs={hubs} theme={theme} />)
      })
    }
    const shortSchedArr = schedArr.sort(AdminDashboard.dynamicSort('etd')).slice(0, 5)
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-center">
        <div
          className={`flex-100 layout-row layout-wrap layout-align-start-start ${
            style.dashboard_main
          }`}
        >
          <div
            className={`flex-100 layout-row layout-wrap layout-align-start-start ${
              style.dashboard_top
            }`}
          >
            <div className={`flex-100 layout-row ${style.left} layout-align-center-center`}>
              <div className={`flex-100 layout-row layout-align-start-center ${style.welcome}`}>
                <h2 className="flex-none">Welcome back, Admin</h2>
              </div>
              <div className={`flex-none layout-row layout-align-center-center ${style.carousel}`}>
                <Carousel theme={theme} slides={activeRoutesData} noSlides={1} fade />
              </div>
              <div
                className={`flex-50 layout-row ${
                  style.right
                } layout-wrap layout-align-space-between-space-between`}
              >
                <div
                  className={`flex-none layout-row layout-align-center-center ${style.stat_box}`}
                >
                  <h1 className="flex-none">
                    {mergedOpenShipments.length +
                      mergedFinishedShipments.length +
                      mergedRequestedShipments.length}
                  </h1>
                  <div
                    className={`flex-none layout-row layout-align-center-center ${
                      style.stat_box_title
                    }`}
                  >
                    <h3 className="flex-none">Total Shipments</h3>
                  </div>
                </div>
                <div
                  className={`flex-none layout-row layout-align-center-center ${style.stat_box}`}
                >
                  <h1 className="flex-none">{mergedRequestedShipments.length}</h1>
                  <div
                    className={`flex-none layout-row layout-align-center-center ${
                      style.stat_box_title
                    }`}
                  >
                    <h3 className="flex-none">Requested Shipments</h3>
                  </div>
                </div>
                <div
                  className={`flex-none layout-row layout-align-center-center ${style.stat_box}`}
                >
                  <h1 className="flex-none">{mergedOpenShipments.length}</h1>
                  <div
                    className={`flex-none layout-row layout-align-center-center ${
                      style.stat_box_title
                    }`}
                  >
                    <h3 className="flex-none">Shipments in Progress</h3>
                  </div>
                </div>
                <div
                  className={`flex-none layout-row layout-align-center-center ${style.stat_box}`}
                >
                  <h1 className="flex-none">{mergedFinishedShipments.length}</h1>
                  <div
                    className={`flex-none layout-row layout-align-center-center ${
                      style.stat_box_title
                    }`}
                  >
                    <h3 className="flex-none">Completed Shipments</h3>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            className={`layout-row flex-100 layout-wrap layout-align-center-center ${
              defaults.border_divider
            }`}
          >
            <TextHeading theme={theme} size={1} text="Dashboard" />
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
              {requestedShipments}
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
              {openShipments}
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
              {finishedShipments}
            </div>
          </div>

          <div
            className={`layout-row flex-100 layout-wrap layout-align-center-center ${
              defaults.border_divider
            }`}
          >
            <AdminSearchableRoutes
              routes={routes}
              theme={theme}
              hubs={hubs}
              adminDispatch={adminDispatch}
              tooltip={adminTip.routes}
              icon="fa-info-circle"
              showTooltip
            />
          </div>
          <div
            className={`layout-row flex-100 layout-wrap layout-align-center-center ${
              defaults.border_divider
            }`}
          >
            <TextHeading theme={theme} size={1} text="Schedules" />
          </div>
          {shortSchedArr}
          <div
            className={`layout-row flex-100 layout-wrap layout-align-center-center ${
              defaults.border_divider
            }`}
          >
            <AdminSearchableHubs
              theme={theme}
              hubs={hubs}
              adminDispatch={adminDispatch}
              tooltip={adminTip.hubs}
              icon="fa-info-circle"
              showTooltip
            />
          </div>
          <div
            className={`layout-row flex-100 layout-wrap layout-align-center-center ${
              defaults.border_divider
            }`}
          >
            <AdminSearchableClients
              theme={theme}
              clients={filteredClients}
              adminDispatch={adminDispatch}
              tooltip={adminTip.clients}
              icon="fa-info-circle"
              showTooltip
            />
          </div>
        </div>
      </div>
    )
  }
}
AdminDashboard.propTypes = {
  theme: PropTypes.theme,
  loading: PropTypes.bool,
  dashData: PropTypes.shape({
    schedules: PropTypes.array
  }),
  adminDispatch: PropTypes.shape({
    getDashboard: PropTypes.func,
    getShipment: PropTypes.func,
    getHub: PropTypes.func,
    confirmShipment: PropTypes.func
  }).isRequired,
  clients: PropTypes.arrayOf(PropTypes.client),
  hubs: PropTypes.arrayOf(PropTypes.hub),
  hubHash: PropTypes.objectOf(PropTypes.hub)
}

AdminDashboard.defaultProps = {
  theme: null,
  loading: false,
  dashData: null,
  clients: [],
  hubs: {},
  hubHash: {}
}

export default AdminDashboard
