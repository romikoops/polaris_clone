import React, { Component } from 'react'
import moment from 'moment'
import PropTypes from 'prop-types'
import { v4 } from 'uuid'
import styles from './ShipmentCard.scss'
import adminStyles from '../Admin/Admin.scss'
import AdminPromptConfirm from '../Admin/Prompt/Confirm'
import {
  gradientTextGenerator,
  gradientGenerator,
  gradientBorderGenerator,
  switchIcon
} from '../../helpers'
import GradientBorder from '../GradientBorder'

export class AdminShipmentCardNew extends Component {
  constructor (props) {
    super(props)

    this.state = {
      confirm: false
    }
  }
  handleShipmentAction (id, action) {
    const { dispatches, shipment } = this.props
    dispatches.confirmShipment(shipment.id, action)
  }
  handleDeny () {
    const { shipment } = this.props
    this.handleShipmentAction(shipment.id, 'decline')
  }

  handleAccept () {
    const { shipment } = this.props
    this.handleShipmentAction(shipment.id, 'accept')
  }

  handleIgnore () {
    const { shipment } = this.props
    this.handleShipmentAction(shipment.id, 'ignore')
    this.closeConfirm()
  }
  handleFinished () {
    const { shipment } = this.props
    this.handleShipmentAction(shipment.id, 'finished')
  }
  confirmDelete () {
    this.setState({
      confirm: true
    })
  }
  closeConfirm () {
    this.setState({ confirm: false })
  }

  handleEdit () {
    const { shipment, dispatches } = this.props
    dispatches.getShipment(shipment.id, true)
  }
  handleView () {
    const { shipment, dispatches } = this.props
    dispatches.getShipment(shipment.id, true)
  }
  render () {
    const {
      shipment,
      theme,
      hubs
    } = this.props

    const gradientStyle =
      theme && theme.colors
        ? gradientGenerator(theme.colors.primary, theme.colors.secondary)
        : { background: 'black' }
    const gradientFontStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const deselectedStyle = {
      ...gradientTextGenerator('#DCDBDC', '#DCDBDC')
    }
    const gradientBorderStyle =
      theme && theme.colors
        ? gradientBorderGenerator(theme.colors.primary, theme.colors.secondary)
        : { background: 'black' }

    const bg1 =
      hubs.startHub && hubs.startHub.photo
        ? { backgroundImage: `url(${hubs.startHub.photo})` }
        : {
          backgroundImage:
            'url("https://assets.itsmycargo.com/assets/default_images/crane_sm.jpg")'
        }
    const bg2 =
      hubs.endHub && hubs.endHub.photo
        ? { backgroundImage: `url(${hubs.endHub.photo})` }
        : {
          backgroundImage:
            'url("https://assets.itsmycargo.com/assets/default_images/destination_sm.jpg")'
        }

    const { confirm } = this.state
    const confimPrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading="Are you sure?"
        text={`This will reject the requested shipment ${shipment.imc_reference}. 
        This shipment can be still be recovered after being ignored`}
        confirm={() => this.handleIgnore()}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )
    const plannedDate =
    shipment.has_pre_carriage ? shipment.planned_pickup_date : shipment.planned_origin_drop_off_date
    const requestedButtons = shipment.status === 'requested' ? (
      <div className={`layout-row layout-align-space-around-center ${styles.topRight}`}>
        <i className={`fa fa-check pointy ${styles.check}`} onClick={() => this.handleAccept()} />
        <i className={`fa fa-edit pointy ${styles.edit}`} onClick={() => this.handleEdit()} />
        <i className={`fa fa-trash pointy ${styles.trash}`} onClick={() => this.confirmDelete()} />
      </div>
    ) : ''
    const openButtons = shipment.status === 'confirmed' || shipment.status === 'in_progress' ? (
      <div className={`layout-row layout-align-space-around-center ${styles.topRight}`}>
        <i className={`fa fa-check pointy ${styles.check}`} onClick={() => this.handleFinished()} />
      </div>
    ) : ''

    return (
      <div
        key={v4()}
        className={
          `layout-column flex-100 layout-align-start-stretch
          ${styles.container} ${styles.relative}`
        }
      >
        {confimPrompt}
        <div className={adminStyles.card_link} onClick={() => this.handleView()} />
        {requestedButtons}
        {openButtons}
        <div className="layout-row layout-wrap flex-10 layout-wrap layout-align-center-center">
          <span className={`flex-100 ${styles.ref_row_card}`}>Ref: <b>{shipment.imc_reference}</b></span>
        </div>
        <div
          className={`layout-row flex-100 layout-align-space-between-stretch ${styles.section}`}
          onClick={() => this.handleView()}
        >
          <div className={`layout-row flex-55 layout-align-space-between-stretch ${styles.relative}`}>

            <GradientBorder
              wrapperClassName={`layout-column layout-align-end-stretch flex-50 ${styles.city} ${styles.margin_right}`}
              gradient={gradientBorderStyle}
              className="layout-column flex-100"
              content={(
                <div className="layout-column flex-100">
                  <div className="layout-align-center-center flex-100">
                    <div className={`flex-100 layout-align-center-center ${styles.hub_name}`}>
                      <p className="layout-align-center-center flex-100">{shipment.origin_hub.name}</p>
                    </div>
                  </div>
                  <div className="layout-column flex-100">
                    <span className="flex-100" style={bg1} />
                  </div>
                </div>
              )}
            />

            <div className={`layout-row layout-align-center-center ${styles.routeIcon}`} style={gradientStyle}>
              {switchIcon(shipment.mode_of_transport)}
            </div>

            <GradientBorder
              wrapperClassName={`layout-column layout-align-end-stretch flex-50 ${styles.city} ${styles.margin_left}`}
              gradient={gradientBorderStyle}
              className="layout-column flex-100"
              content={(
                <div className="layout-column flex-100">
                  <div className={`flex-100 layout-align-center-start ${styles.hub_name}`}>
                    <p>{shipment.destination_hub.name}</p>
                  </div>
                  <div className="layout-column flex-100">
                    <span className="flex-100" style={bg2} />
                  </div>
                </div>
              )}
            />

          </div>
          <div className={`layout-column flex-40 ${styles.user_info}`} onClick={() => this.handleView()}>
            <div className="layout-column flex-50 layout-align-center-stretch">
              <div className="layout-row flex-50 layout-align-start-start">
                <div className="flex-20 layout-row layout-align-center-center">
                  <i className="fa fa-user clip" style={gradientFontStyle} />
                </div>
                <div className="flex-80 layout-row layout-align-start-start">
                  <h4>{shipment.clientName}</h4>
                </div>
              </div>
              <div className="layout-row flex-50 layout-align-start-stretch">
                <span className="flex-20 layout-row layout-align-center-center">
                  <i className="fa fa-building clip" style={gradientFontStyle} />
                </span>
                <span className={`flex-80 layout-row layout-align-start-center ${styles.grey}`}>
                  <p>{shipment.companyName}</p>
                </span>
              </div>
            </div>
            <div className={`layout-row flex-50 layout-align-end-end ${styles.smallText}`}>
              <span className="flex-80"><b>Booking placed at</b><br />
                <span className={`${styles.grey}`}>
                  {moment(shipment.booking_placed_at).format('DD/MM/YYYY - hh:mm')}
                </span>
              </span>
            </div>
          </div>
        </div>
        <div className={`layout-row flex-40 layout-align-start-stretch
            ${styles.section} ${styles.separatorTop} ${styles.smallText}`}
        >
          <div className="layout-column flex-20">
            <span className="flex-100"><b>Pickup Date</b><br />
              <span className={`${styles.grey}`}>
                {moment(plannedDate).format('DD/MM/YYYY')}
              </span>
            </span>
          </div>
          <div className="layout-column flex-20">
            <span className="flex-100"><b>ETD</b><br />
              <span className={`${styles.grey}`}>
                {moment(shipment.planned_etd).format('DD/MM/YYYY')}
              </span>
            </span>
          </div>
          <div className="layout-column flex-20">
            <span className="flex-100"><b>ETA</b><br />
              <span className={`${styles.grey}`}>
                {moment(shipment.planned_eta).format('DD/MM/YYYY')}
              </span>
            </span>
          </div>
          <div className="layout-column flex-40">
            <span className="flex-100"><b>Estimated Transit Time</b><br />
              <span className={`${styles.grey}`}>
                {moment(shipment.planned_eta).diff(shipment.planned_etd, 'days')} days
              </span>
            </span>
          </div>
        </div>
        <div className={`layout-row flex-25 layout-align-space-between-center
            ${styles.sectionBottom} ${styles.separatorTop}`}
        >
          <div className="layout-row flex-60 layout-align-start-center">
            <div className="layout-row flex-15">
              <div className={`layout-row layout-align-center-center ${styles.green_icon}`} style={gradientStyle}>
                <span className={`${styles.smallText}`}>
                  <b>x</b><span className={`${styles.bigText}`}>1</span>
                </span>
              </div>
            </div>
            <span className="flex-30">Cargo item</span>
            <span className="flex-30">
              <i
                className="fa fa-check-square clip"
                style={shipment.pickup_address ? gradientFontStyle : deselectedStyle}
              />
              <span> pickup</span>
            </span>
            <span className="flex-30">
              <i
                className="fa fa-check-square clip"
                style={shipment.delivery_address ? gradientFontStyle : deselectedStyle}
              />
              <span> delivery</span>
            </span>
          </div>
          <div className="layout-align-end-center">
            <span className={`${styles.bigText}`}>
              <span>{shipment.total_price ? shipment.total_price.currency : ''} </span>
              <span>
                {shipment.total_price ? Number.parseFloat(shipment.total_price.value)
                  .toFixed(2) : 0}
              </span>
            </span>
          </div>
        </div>
      </div>
    )
  }
}

AdminShipmentCardNew.propTypes = {
  shipment: PropTypes.objectOf(PropTypes.shipment),
  dispatches: PropTypes.objectOf(PropTypes.func),
  theme: PropTypes.theme,
  hubs: PropTypes.objectOf(PropTypes.hub)
}

AdminShipmentCardNew.defaultProps = {
  shipment: {},
  dispatches: {},
  theme: {},
  hubs: {}
}

export default AdminShipmentCardNew
