import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import styles from './UserShipmentRow.scss'
import { moment } from '../../constants'

export class UserShipmentRow extends Component {
  static switchIcon (sched) {
    let icon
    switch (sched.mode_of_transport) {
      case 'ocean':
        icon = <i className="fa fa-ship" />
        break
      case 'air':
        icon = <i className="fa fa-plane" />
        break
      case 'train':
        icon = <i className="fa fa-train" />
        break
      default:
        icon = <i className="fa fa-ship" />
        break
    }
    return icon
  }

  static dashedGradient (color1, color2) {
    return `linear-gradient(to right, transparent 70%, white 30%), linear-gradient(to right, ${color1}, ${color2})`
  }

  constructor (props) {
    super(props)
    this.selectShipment = this.selectShipment.bind(this)
    this.handleDeny = this.handleDeny.bind(this)
    this.handleAccept = this.handleAccept.bind(this)
  }
  selectShipment () {
    const { shipment, handleSelect } = this.props
    handleSelect(shipment)
  }
  handleDeny () {
    const { shipment, handleAction } = this.props
    handleAction(shipment.id, 'decline')
  }

  handleAccept () {
    const { shipment, handleAction } = this.props
    handleAction(shipment.id, 'accept')
  }
  render () {
    const {
      theme, shipment, hubs, user
    } = this.props
    if (shipment.schedule_set.length < 1) {
      return ''
    }
    const hubKeys = shipment.schedule_set[0].hub_route_key.split('-')
    if (!hubs[hubKeys[0]] || !hubs[hubKeys[1]]) {
      // ;
      return ''
    }
    // ;
    const schedule = {}
    const originHub = hubs[hubKeys[0]].data
    const destHub = hubs[hubKeys[1]].data
    const gradientFontStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.brightPrimary}, ${
            theme.colors.brightSecondary
          })`
          : 'black'
    }
    const dashedLineStyles = {
      marginTop: '6px',
      height: '2px',
      width: '100%',
      background:
        theme && theme.colors
          ? UserShipmentRow.dashedGradient(theme.colors.primary, theme.colors.secondary)
          : 'black',
      backgroundSize: '16px 2px, 100% 2px'
    }
    const pendingRow = (
      <div className="flex-50 layout-row layout-align-end-end layout-wrap">
        <div className="flex-none layout-row layout-align-start-end">
          <p className="flex-none">Status: </p>
        </div>
        <div className={`flex-40 layout-row layout-align-center-end ${styles.pending}`}>
          <i className="flex-none fa fa-clock-o" />
          <p className="flex-none">Pending</p>
        </div>
      </div>
    )
    const acceptedRow = (
      <div className="flex-50 layout-row layout-align-end-end layout-wrap">
        <div className="flex-none layout-row layout-align-start-end">
          <p className="flex-none">Status: </p>
        </div>
        <div className={`flex-40 layout-row layout-align-center-end ${styles.grant}`}>
          <i className="flex-none fa fa-check" />
          <p className="flex-none">Accepted</p>
        </div>
      </div>
    )
    const deniedRow = (
      <div className="flex-50 layout-row layout-align-end-end layout-wrap">
        <div className="flex-none layout-row layout-align-start-end">
          <p className="flex-none">Status: </p>
        </div>
        <div className={`flex-40 layout-row layout-align-center-end ${styles.deny}`}>
          <i className="flex-none fa fa-trash" />
          <p className="flex-none">Denied</p>
        </div>
      </div>
    )
    const nadaRow = <div className="flex-50 layout-row layout-align-end-end layout-wrap" />
    let statusRow
    switch (shipment.status) {
      case 'pending':
        statusRow = pendingRow
        break
      case 'requested':
        statusRow = pendingRow
        break
      case 'denied':
        statusRow = deniedRow
        break
      case 'accepted':
        statusRow = acceptedRow
        break
      case 'confirmed':
        statusRow = acceptedRow
        break
      case 'in_progress':
        statusRow = acceptedRow
        break
      default:
        statusRow = nadaRow
        break
    }
    return (
      <div
        key={v4()}
        className={`flex-100 layout-row ${styles.route_result}`}
        onClick={this.selectShipment}
      >
        <div className="flex-100 layout-row layout-wrap">
          <div
            className={`flex-40 layout-row layout-align-start-center layout-wrap ${styles.top_row}`}
          >
            <div className={`flex ${styles.header_hub}`}>
              <i className={`fa fa-map-marker ${styles.map_marker}`} />
              <div className="flex-100 layout-row">
                <h4 className="flex-100"> {originHub.name} </h4>
              </div>
              <div className="flex-100">
                <p className="flex-100"> {originHub.hub_code ? originHub.hub_code : ''} </p>
              </div>
            </div>
            <div className={`${styles.connection_graphics}`}>
              <div className="flex-none layout-row layout-align-center-center">
                {UserShipmentRow.switchIcon(schedule)}
              </div>
              <div style={dashedLineStyles} />
            </div>
            <div className={`${styles.header_hub}`}>
              <i className={`fa fa-flag-o ${styles.flag}`} />
              <div className="flex-100 layout-row">
                <h4 className="flex-100"> {destHub.name} </h4>
              </div>
              <div className="flex-100">
                <p className="flex-100"> {destHub.hub_code ? destHub.hub_code : ''} </p>
              </div>
            </div>
          </div>
          <div className="flex-60 layout-row layout-align-start-center layout-wrap">
            <div className={`flex-100 layout-row layout-align-start-center ${styles.action_bar}`}>
              <div
                className={`flex-33 layout-row layout-align-start-start layout-wrap ${
                  styles.user_info
                }`}
                onClick={this.selectShipment}
              >
                <i className={`flex-none fa fa-user ${styles.flag}`} style={gradientFontStyle} />
                <p className="flex-none"> {`${user.first_name} ${user.last_name}`} </p>
              </div>
              <div className="flex-33 layout-wrap layout-row layout-align-center-center">
                <div className="flex-100 layout-row">
                  <h4 className={styles.date_title}> Date of Departure</h4>
                </div>
                <div className="flex-100 layout-row">
                  <p className={`flex-none ${styles.sched_elem}`}>
                    {' '}
                    {moment(shipment.planned_etd).format('YYYY-MM-DD')}{' '}
                  </p>
                  <p className={`flex-none ${styles.sched_elem}`}>
                    {' '}
                    {moment(shipment.planned_etd).format('HH:mm')}{' '}
                  </p>
                </div>
              </div>
              <div className="flex-33 layout-wrap layout-row layout-align-center-center">
                <div className="flex-100 layout-row">
                  <h4 className={styles.date_title}> ETA terminal</h4>
                </div>
                <div className="flex-100 layout-row">
                  <p className={`flex-none ${styles.sched_elem}`}>
                    {' '}
                    {moment(shipment.planned_eta).format('YYYY-MM-DD')}{' '}
                  </p>
                  <p className={`flex-none ${styles.sched_elem}`}>
                    {' '}
                    {moment(shipment.planned_eta).format('HH:mm')}{' '}
                  </p>
                </div>
              </div>
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-end-center">
            <div className={`flex-50 layout-row layout-align-start-end ${styles.ref_row}`}>
              <p className="flex-none">Ref: {shipment.imc_reference}</p>
            </div>
            {statusRow}
          </div>
        </div>
      </div>
    )
  }
}
UserShipmentRow.propTypes = {
  theme: PropTypes.theme,
  handleSelect: PropTypes.func.isRequired,
  handleAction: PropTypes.func.isRequired,
  hubs: PropTypes.arrayOf(PropTypes.object),
  shipment: PropTypes.shipment.isRequired,
  user: PropTypes.objectOf(PropTypes.String).isRequired
}

UserShipmentRow.defaultProps = {
  theme: null,
  hubs: []
}

export default UserShipmentRow
