import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
// import styles from './UserAccount.scss';
import { UserShipmentRow } from './'
import styles from '../Admin/Admin.scss'

import defaults from '../../styles/default_classes.scss'
import { TextHeading } from '../TextHeading/TextHeading'

export class UserShipments extends Component {
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
  }
  viewShipment (shipment) {
    const { userDispatch } = this.props
    userDispatch.getShipment(shipment.id, true)
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
        shipments.open.map(ship => (
          <UserShipmentRow
            key={v4()}
            shipment={ship}
            hubs={hubs}
            theme={theme}
            handleSelect={this.viewShipment}
            handleAction={this.handleShipmentAction}
            user={user}
          />
        ))
      ) : (
        <div>No open shipments available</div>
      )
    const reqShipments =
      shipments && shipments.requested.length !== 0 ? (
        shipments.requested.map(ship => (
          <UserShipmentRow
            key={v4()}
            shipment={ship}
            hubs={hubs}
            theme={theme}
            handleSelect={this.viewShipment}
            handleAction={this.handleShipmentAction}
            user={user}
          />
        ))
      ) : (
        <div>No requested shipments available</div>
      )
    const finishedShipments =
      shipments && shipments.finished.length !== 0 ? (
        shipments.finished.map(ship => (
          <UserShipmentRow
            key={v4()}
            shipment={ship}
            hubs={hubs}
            theme={theme}
            handleSelect={this.viewShipment}
            handleAction={this.handleShipmentAction}
            user={user}
          />
        ))
      ) : (
        <div>No finished shipments available</div>
      )
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100 layout-row layout-wrap layout-align-start-center">
          <TextHeading theme={theme} size={1} text="Shipments" />
        </div>
        <div
          className={
            `flex-100 layout-row layout-wrap layout-align-start-center ${defaults.border_divider}`
          }
        >
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}> Open Shipments</p>
          </div>
          {openShipments}
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}> Requested Shipments</p>
          </div>
          {reqShipments}
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}> Finished Shipments</p>
          </div>
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
  user: PropTypes.user,
  hubs: PropTypes.arrayOf(PropTypes.object),
  shipments: PropTypes.shipments.isRequired,
  loading: PropTypes.func.isRequired
}

UserShipments.defaultProps = {
  theme: null,
  user: null,
  hubs: []
}

export default UserShipments
