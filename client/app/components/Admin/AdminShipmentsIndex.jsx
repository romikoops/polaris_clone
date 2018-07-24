import React, { Component } from 'react'
import PropTypes from 'prop-types'
import adminStyles from './Admin.scss'
import { AdminSearchableShipments } from './AdminSearchables'
import { adminDashboard as adminTip } from '../../constants'
import { filters } from '../../helpers'
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

    const mergedOpenShipments = filters.sortByDate(shipments.open, 'booking_placed_at')
      .map(sh => AdminShipmentsIndex.prepShipment(sh, clientHash, hubHash))
    const mergedReqShipments = filters.sortByDate(shipments.requested, 'booking_placed_at')
      .map(sh => AdminShipmentsIndex.prepShipment(sh, clientHash, hubHash))
    const mergedFinishedShipments = filters.sortByDate(shipments.finished, 'booking_placed_at')
      .map(sh => AdminShipmentsIndex.prepShipment(sh, clientHash, hubHash))

    const listView = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <Tabs>
          <Tab
            tabTitle="Requested"
            theme={theme}
          >
            <AdminSearchableShipments
              handleClick={this.viewShipment}
              hubs={hubHash}
              dispatches={adminDispatch}
              shipments={mergedReqShipments}
              theme={theme}
              handleShipmentAction={handleShipmentAction}
              tooltip={adminTip.requested}
              seeAll={false}
            />
          </Tab>
          <Tab
            tabTitle="Open"
            theme={theme}
          >
            <AdminSearchableShipments
              handleClick={this.viewShipment}
              hubs={hubHash}
              dispatches={adminDispatch}
              shipments={mergedOpenShipments}
              theme={theme}
              handleShipmentAction={handleShipmentAction}
              tooltip={adminTip.open}
              seeAll={false}
            />
          </Tab>
          <Tab
            tabTitle="Finished"
            theme={theme}
          >
            <AdminSearchableShipments
              handleClick={this.viewShipment}
              hubs={hubHash}
              dispatches={adminDispatch}
              shipments={mergedFinishedShipments}
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
