import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './Admin.scss'
import { AdminSearchableShipments } from './AdminSearchables'
import { adminDashboard as adminTip } from '../../constants'

export class AdminShipmentsIndex extends Component {
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
  constructor (props) {
    super(props)
    this.viewShipment = this.viewShipment.bind(this)
  }
  viewShipment (shipment) {
    this.props.viewShipment(shipment)
  }

  render () {
    console.log(this.props)
    // const {selectedShipment} = this.state;
    const {
      theme, hubs, shipments, clients, handleShipmentAction, hubHash, adminDispatch
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
        <AdminSearchableShipments
          handleClick={this.viewShipment}
          hubs={hubHash}
          adminDispatch={adminDispatch}
          shipments={mergedReqShipments}
          title="Requested Shipments"
          theme={theme}
          handleShipmentAction={handleShipmentAction}
          tooltip={adminTip.requested}
        />
        <AdminSearchableShipments
          handleClick={this.viewShipment}
          hubs={hubHash}
          adminDispatch={adminDispatch}
          shipments={mergedOpenShipments}
          title="Open Shipments"
          theme={theme}
          handleShipmentAction={handleShipmentAction}
          tooltip={adminTip.open}
        />
        <AdminSearchableShipments
          handleClick={this.viewShipment}
          hubs={hubHash}
          adminDispatch={adminDispatch}
          shipments={mergedFinishedShipments}
          title="Finished Shipments"
          theme={theme}
          handleAction={handleShipmentAction}
          tooltip={adminTip.finished}
        />
        { mergedOpenShipments.length === 0 &&
        mergedReqShipments.length === 0 &&
        mergedFinishedShipments.length === 0
          ? <div className="flex-95 flex-offset-5 layout-row layout-wrap layout-align-start-center">
            <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_subheader}`}>
              <p className={` ${styles.sec_subheader_text} flex-none`} > No Shipments yet</p>
            </div>
            <p className="flex-none" > As shipments are requested, they will appear here</p>
          </div>
          : ''
        }
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        { listView }
      </div>
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
