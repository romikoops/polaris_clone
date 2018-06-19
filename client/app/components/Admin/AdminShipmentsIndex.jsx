import React, { Component } from 'react'
import PropTypes from 'prop-types'
import adminStyles from './Admin.scss'
import { AdminSearchableShipments } from './AdminSearchables'
import { adminDashboard as adminTip } from '../../constants'
import Tabs from '../Tabs/Tabs'
import Tab from '../Tabs/Tab'

export class AdminShipmentsIndex extends Component {
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
    this.viewShipment = this.viewShipment.bind(this)
  }
  componentDidMount () {
    window.scrollTo(0, 0)
  }
  viewShipment (shipment) {
    this.props.viewShipment(shipment)
  }

  render () {
    console.log(this.props)
    // const {selectedShipment} = this.state;
    const {
      theme,
      hubs,
      shipments,
      clients,
      handleShipmentAction,
      hubHash,
      adminDispatch
    } = this.props
    // ;
    if (!shipments || !hubs || !clients) {
      return ''
    }
    const clientHash = {}
    clients.forEach((cl) => {
      clientHash[cl.id] = cl
    })

    const mergedOpenShipments = shipments.open.map(sh =>
      AdminShipmentsIndex.prepShipment(sh, clientHash, hubHash))
    const mergedReqShipments = shipments.requested.map(sh =>
      AdminShipmentsIndex.prepShipment(sh, clientHash, hubHash))
    const mergedFinishedShipments = shipments.finished.map(sh =>
      AdminShipmentsIndex.prepShipment(sh, clientHash, hubHash))

    const listView = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <Tabs>
          <Tab
            isActive
            iconClassName="icon-class-0"
            linkClassName="link-class-0"
            tabTitle="Requested"
          >
            <AdminSearchableShipments
              handleClick={this.viewShipment}
              hubs={hubHash}
              adminDispatch={adminDispatch}
              shipments={mergedReqShipments}
              title="Requested Shipments"
              theme={theme}
              handleShipmentAction={handleShipmentAction}
              tooltip={adminTip.requested}
              seeAll={false}
            />
          </Tab>
          <Tab
            isActive
            iconClassName="icon-class-0"
            linkClassName="link-class-0"
            tabTitle="Open"
          >
            <AdminSearchableShipments
              handleClick={this.viewShipment}
              hubs={hubHash}
              adminDispatch={adminDispatch}
              shipments={mergedOpenShipments}
              title="Open Shipments"
              theme={theme}
              handleShipmentAction={handleShipmentAction}
              tooltip={adminTip.open}
              seeAll={false}
            />
          </Tab>
          <Tab
            isActive
            iconClassName="icon-class-0"
            linkClassName="link-class-0"
            tabTitle="Finished"
          >
            <AdminSearchableShipments
              handleClick={this.viewShipment}
              hubs={hubHash}
              adminDispatch={adminDispatch}
              shipments={mergedFinishedShipments}
              title="Finished Shipments"
              theme={theme}
              handleAction={handleShipmentAction}
              tooltip={adminTip.finished}
              seeAll={false}
            />
          </Tab>
        </Tabs>



        {mergedOpenShipments.length === 0 &&
        mergedReqShipments.length === 0 &&
        mergedFinishedShipments.length === 0 ? (
            <div className="flex-95 flex-offset-5 layout-row layout-wrap layout-align-start-center">
              <div
                className={`flex-100 layout-row layout-align-space-between-center ${
                  adminStyles.sec_subheader
                }`}
              >
                <p className={` ${adminStyles.sec_subheader_text} flex-none`}> No Shipments yet</p>
              </div>
              <p className="flex-none"> As shipments are requested, they will appear here</p>
            </div>
          ) : (
            ''
          )}
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">{listView}</div>
    )
  }
}
AdminShipmentsIndex.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  shipments: PropTypes.arrayOf(PropTypes.shipment),
  clients: PropTypes.arrayOf(PropTypes.clients),
  handleShipmentAction: PropTypes.func.isRequired,
  viewShipment: PropTypes.func.isRequired,
  hubHash: PropTypes.objectOf(PropTypes.hub),
  adminDispatch: PropTypes.objectOf(PropTypes.func)
}

AdminShipmentsIndex.defaultProps = {
  theme: null,
  hubs: [],
  shipments: [],
  clients: [],
  hubHash: {},
  adminDispatch: {}
}

export default AdminShipmentsIndex
