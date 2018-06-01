import React, { Component } from 'react'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import styles from './AdminShipmentRow.scss'
import { moment } from '../../constants'
import { gradientTextGenerator } from '../../helpers'
import AdminPromptConfirm from './Prompt/Confirm'

export class AdminShipmentRow extends Component {
  static switchIcon (sched, style) {
    let icon
    switch (sched.mode_of_transport) {
      case 'ocean':
        icon = <i className="fa fa-ship clip" style={style} />
        break
      case 'air':
        icon = <i className="fa fa-plane clip" style={style} />
        break
      case 'train':
        icon = <i className="fa fa-train clip" style={style} />
        break
      default:
        icon = <i className="fa fa-ship clip" style={style} />
        break
    }
    return icon
  }

  static dashedGradient (color1, color2) {
    return `linear-gradient(to right, transparent 70%, white 30%), linear-gradient(to right, ${color1}, ${color2})`
  }
  static calcCargoLoad (feeHash, loadType) {
    const cargoCount = Object.keys(feeHash.cargo).length
    let noun = ''
    if (loadType === 'cargo_item' && cargoCount > 1) {
      noun = 'Cargo Items'
    } else if (loadType === 'cargo_item' && cargoCount === 1) {
      noun = 'Cargo Item'
    } else if (loadType === 'container' && cargoCount > 1) {
      noun = 'Containers'
    } else if (loadType === 'container' && cargoCount === 1) {
      noun = 'Container'
    }
    return `${cargoCount} X ${noun}`
  }

  constructor (props) {
    super(props)
    this.state = {
      confirm: false
    }
    this.selectShipment = this.selectShipment.bind(this)
    this.handleDeny = this.handleDeny.bind(this)
    this.handleAccept = this.handleAccept.bind(this)
    this.handleIgnore = this.handleIgnore.bind(this)
    this.handleEdit = this.handleEdit.bind(this)
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

  handleIgnore () {
    const { shipment, handleAction } = this.props
    handleAction(shipment.id, 'ignore')
    this.closeConfirm()
  }

  handleEdit () {
    const { shipment, handleSelect } = this.props
    handleSelect(shipment)
  }
  confirmDelete () {
    this.setState({
      confirm: true
    })
  }
  closeConfirm () {
    this.setState({ confirm: false })
  }

  render () {
    const { theme, shipment, hubs } = this.props
    const { confirm } = this.state
    if (shipment.schedule_set.length < 1) {
      return ''
    }
    const hubKeys = shipment.schedule_set[0].hub_route_key.split('-')
    if (!hubs[hubKeys[0]] || !hubs[hubKeys[1]]) {
      return ''
    }
    const schedule = {}
    const originHub = hubs[hubKeys[0]].data
    const destHub = hubs[hubKeys[1]].data
    const gradientFontStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }

    const feeHash = shipment.schedules_charges[shipment.schedule_set[0].hub_route_key]
    const dashedLineStyles = {
      marginTop: '6px',
      height: '2px',
      width: '100%',
      background:
        theme && theme.colors
          ? AdminShipmentRow.dashedGradient(theme.colors.primary, theme.colors.secondary)
          : 'black',
      backgroundSize: '16px 2px, 100% 2px'
    }
    const showButtons = shipment.status === 'requested'
    const btnRow = (
      <div
        className={`flex-none layout-column layout-align-space-between-center ${styles.btn_row}`}
      >
        <div className="flex-30 layout-row layout-align-center-center" onClick={this.handleAccept}>
          <div className={`flex-none layout-row layout-align-center-center ${styles.grant}`}>
            <i className="flex-none fa fa-check" />
          </div>
        </div>
        <div className="flex-30 layout-row layout-align-center-center" onClick={this.handleEdit}>
          <div className={`flex-none layout-row layout-align-center-center ${styles.edit}`}>
            <i className="flex-none fa fa-pencil" />
          </div>
        </div>

        <div
          className="flex-30 layout-row layout-align-center-center"
          onClick={() => this.confirmDelete()}
        >
          <div className={`flex-none layout-row layout-align-center-center ${styles.deny}`}>
            <i className="fa fa-close" />
          </div>
        </div>
      </div>
    )
    const confimPrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading="Are you sure?"
        text={`This will reject the requested shipment ${shipment.imc_reference}. This shipment can be still be recovered after being ignored`}
        confirm={() => this.handleIgnore()}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )

    return (
      <div key={v4()} className={`flex-100 layout-row pointy ${styles.route_result}`}>
        {confimPrompt}
        <div
          className={`${styles.port_box} flex-25 layout-row layout-wrap`}
          onClick={this.selectShipment}
        >
          <div className="flex-100 layout-row layout-align-center-center">
            <h5 className="flex-none no_m">
              {' '}
              {`Booking Placed at: ${moment(shipment.booking_placed_at).format('DD/MM/YYYY HH:mm')}`}
            </h5>
          </div>
          <div className={`${styles.hub_half} flex-100 layout-row layout-align-center-center`}>
            <div className="flex-10 layout-row layout-align-center-center">
              <i className={`flex-none fa fa-map-marker ${styles.map_marker}`} />
            </div>
            <div className="flex layout-row layout-align-center-center">
              <h4 className="flex-100 center letter_3"> {originHub.name} </h4>
            </div>
          </div>
          <div
            className={`${
              styles.hub_mid_line
            } flex-none layout-row layout-align-space-around-center layout-wrap`}
          >
            {/* <i className="fa fa-chevron-down flex-none" />
            {/* <i className="fa fa-chevron-down flex-none" /> */}

            {/* <i className="fa fa-chevron-down flex-none" /> */}
            {/* <i className="fa fa-chevron-down flex-none" /> */}
            <div className="flex-100 layout-row layout-align-center-end">
              {AdminShipmentRow.switchIcon(schedule, gradientFontStyle)}
            </div>
            <div style={dashedLineStyles} />
          </div>
          <div className={`${styles.hub_half} flex-100 layout-row layout-align-center-center`}>
            <div className="flex-10 layout-row layout-align-center-center">
              <i className={`flex-none fa fa-flag-o ${styles.flag}`} />
            </div>
            <div className="flex layout-row layout-align-center-center">
              <h4 className="flex-100 center letter_3"> {destHub.name} </h4>
            </div>
          </div>
        </div>
        <div
          className={`${styles.main_info} flex layout-row layout-align-none-start layout-wrap`}
          onClick={this.selectShipment}
        >
          <div className="flex-100 layout-row layout-align-none-center">
            <div className="flex-50 layout-row layout-align-start-center">
              <h4 className="flex-none no_m letter_3"> {`Ref: ${shipment.imc_reference}`}</h4>
            </div>

            <div className="flex-50 layout-row layout-align-end-center">
              <h4 className="flex-none letter_3 no_m">
                {' '}
                {`${AdminShipmentRow.calcCargoLoad(feeHash, shipment.load_type)} `}
              </h4>
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-none-center">
            <div className={`${styles.user_info} flex-50 layout-row layout-align-start-center`}>
              <i className={`flex-none fa fa-user ${styles.flag}`} style={gradientFontStyle} />
              <h4 className="flex-none letter_3"> {shipment.clientName} </h4>
            </div>
            <div className="flex-50 layout-row layout-align-end-center">
              <h4 className="flex-none letter_3 no_m">
                {' '}
                {`Total: ${shipment.total_price.currency} ${parseFloat(shipment.total_price.value).toFixed(2)}`}
              </h4>
            </div>
          </div>

          <div className="flex-100 layout-row layout-align-none-center">
            <div className="flex-25 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <h4 className={styles.date_title}>
                  {shipment.has_pre_carriage ? 'Pickup Date' : 'Closing Date'}
                </h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(shipment.planned_pickup_date).format('DD/MM/YYYY')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(shipment.planned_pickup_date).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
            <div className="flex-25 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <h4 className={styles.date_title}> ETD</h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(shipment.planned_etd).format('DD/MM/YYYY')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(shipment.planned_etd).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
            <div className="flex-25 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <h4 className={styles.date_title}> ETA </h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(shipment.planned_eta).format('DD/MM/YYYY')}{' '}
                </p>
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(shipment.planned_eta).format('HH:mm')}{' '}
                </p>
              </div>
            </div>
            <div className="flex-25 layout-wrap layout-row layout-align-center-center">
              <div className="flex-100 layout-row">
                <h4 className={styles.date_title}> Estimated Transit Time </h4>
              </div>
              <div className="flex-100 layout-row">
                <p className={`flex-none ${styles.sched_elem}`}>
                  {' '}
                  {moment(shipment.planned_eta).diff(shipment.planned_etd, 'days')}
                  {'  Days'}
                </p>
              </div>
            </div>
          </div>
        </div>
        {showButtons ? btnRow : ''}
      </div>
    )
  }
}
AdminShipmentRow.propTypes = {
  theme: PropTypes.theme,
  handleSelect: PropTypes.func.isRequired,
  handleAction: PropTypes.func.isRequired,
  shipment: PropTypes.shipment.isRequired,
  hubs: PropTypes.objectOf(PropTypes.hub)
}

AdminShipmentRow.defaultProps = {
  theme: null,
  hubs: []
}

export default AdminShipmentRow
