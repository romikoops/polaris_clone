import React, { Component } from 'react'
// import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
// import { UserShipmentRow } from './'
// import styles from '../Admin/Admin.scss'
import defaults from '../../styles/default_classes.scss'
import { TextHeading } from '../TextHeading/TextHeading'
import { AdminSearchableShipments } from '../Admin/AdminSearchables'

export class UserShipments extends Component {
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
  static prepShipment (baseShipment, client, hubsObj) {
    const shipment = Object.assign({}, baseShipment)
    shipment.clientName = client
      ? `${client.first_name} ${client.last_name}`
      : ''
    shipment.companyName = client
      ? `${client.company_name}`
      : ''
    shipment.originHub = hubsObj[shipment.origin_hub_id] ? hubsObj[shipment.origin_hub_id].data.name : ''
    shipment.destinationHub = hubsObj[shipment.destination_hub_id] ? hubsObj[shipment.destination_hub_id].data.name : ''
    return shipment
  }
  constructor (props) {
    super(props)
    this.viewShipment = this.viewShipment.bind(this)
  }
  componentDidMount () {
    const { shipments, loading, userDispatch } = this.props
    if (!shipments && !loading) {
      userDispatch.getShipments(false)
    }
    this.props.setNav('shipments')
    window.scrollTo(0, 0)
  }
  viewShipment (shipment) {
    const { userDispatch } = this.props
    userDispatch.getShipment(shipment.id, true)
  }
  gotToShipmentGroup (type) {
    const { userDispatch } = this.props
    userDispatch.goTo(`/account/shipments/${type}`)
  }

  render () {
    const {
      theme, hubs, shipments, user
    } = this.props
    // ;
    if (!user) {
      return <h1>NO DATA</h1>
    }

    const openShipments =
      shipments && shipments.open.length !== 0 ? (
        <AdminSearchableShipments
          userView
          shipments={shipments.open.map(shipment => UserShipments.prepShipment(shipment, user, hubs)).sort(UserShipments.dynamicSort('booking_placed_at'))}
          hubs={hubs}
          theme={theme}
          user={user}
          title="Open Shipments"
          seeAll={() => this.gotToShipmentGroup('open')}
          handleClick={this.viewShipment}
          handleShipmentAction={this.handleShipmentAction}
        />
      ) : (
        <div>No open shipments available</div>
      )
    const reqShipments =
      shipments && shipments.requested.length !== 0 ? (
        <AdminSearchableShipments
          userView
          shipments={shipments.requested.map(shipment => UserShipments.prepShipment(shipment, user, hubs)).sort(UserShipments.dynamicSort('booking_placed_at'))}
          hubs={hubs}
          theme={theme}
          user={user}
          title="Requested Shipments"
          handleClick={this.viewShipment}
          seeAll={() => this.gotToShipmentGroup('requested')}
          handleShipmentAction={this.handleShipmentAction}
        />
      ) : (
        <div>No requested shipments available</div>
      )
    const finishedShipments =
      shipments && shipments.finished.length !== 0 ? (
        <AdminSearchableShipments
          userView
          shipments={shipments.finished.map(shipment => UserShipments.prepShipment(shipment, user, hubs)).sort(UserShipments.dynamicSort('booking_placed_at'))}
          hubs={hubs}
          theme={theme}
          user={user}
          title="Finished Shipments"
          handleClick={this.viewShipment}
          seeAll={() => this.gotToShipmentGroup('finished')}
          handleShipmentAction={this.handleShipmentAction}
        />
      ) : (
        <div>No finished shipments available</div>
      )
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-wrap layout-align-start-center">
          <TextHeading theme={theme} size={1} text="Shipments" />
        </div>
        <div
          className={`flex-100 layout-row layout-wrap layout-align-start-center ${
            defaults.border_divider
          }`}
        >
          {/* <div
            className={`flex-100 layout-row layout-align-space-between-center section_padding ${
              styles.sec_header
            }`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}> Open Shipments</p>
          </div> */}
          {openShipments}
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-start-center">
          {/* <div
            className={`flex-100 layout-row layout-align-space-between-center section_padding ${
              styles.sec_header
            }`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}> Requested Shipments</p>
          </div> */}
          {reqShipments}
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-start-center">
          {/* <div
            className={`flex-100 layout-row layout-align-space-between-center section_padding ${
              styles.sec_header
            }`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}> Finished Shipments</p>
          </div> */}
          {finishedShipments}
        </div>
      </div>
    )
  }
}

UserShipments.propTypes = {
  setNav: PropTypes.func.isRequired,
  userDispatch: PropTypes.shape({
    getShipment: PropTypes.func
  }).isRequired,
  theme: PropTypes.theme,
  loading: PropTypes.bool,
  user: PropTypes.user,
  hubs: PropTypes.arrayOf(PropTypes.object),
  shipments: PropTypes.shipments.isRequired
}

UserShipments.defaultProps = {
  theme: null,
  user: null,
  hubs: [],
  loading: false
}

export default UserShipments
