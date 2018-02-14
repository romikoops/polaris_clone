import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import { moment } from '../../constants'
import styles from './BookingConfirmation.scss'
import { RouteHubBox } from '../RouteHubBox/RouteHubBox'
import { CargoItemDetails } from '../CargoItemDetails/CargoItemDetails'
import { ContainerDetails } from '../ContainerDetails/ContainerDetails'
import { RoundButton } from '../RoundButton/RoundButton'
import defaults from '../../styles/default_classes.scss'
import { Price } from '../Price/Price'
import { TextHeading } from '../TextHeading/TextHeading'
import { gradientTextGenerator } from '../../helpers'
import { Tooltip } from '../Tooltip/Tooltip'
import { Checkbox } from '../Checkbox/Checkbox'

export class BookingConfirmation extends Component {
  constructor (props) {
    super(props)
    this.state = {
      acceptTerms: false
    }
    this.toggleAcceptTerms = this.toggleAcceptTerms.bind(this)
    this.acceptShipment = this.acceptShipment.bind(this)
  }
  componentDidMount () {
    const { setStage } = this.props
    setStage(5)
    window.scrollTo(0, 0)
  }
  toggleAcceptTerms () {
    this.setState({ acceptTerms: !this.state.acceptTerms })
    // this.props.handleInsurance();
  }
  acceptShipment () {
    const { shipmentData, shipmentDispatch } = this.props
    const { shipment } = shipmentData
    shipmentDispatch.acceptShipment(shipment.id)
  }
  render () {
    const {
      theme, shipmentData, user, shipmentDispatch
    } = this.props
    if (!shipmentData) return <h1>Loading</h1>
    const {
      shipment,
      schedules,
      hubs,
      shipper,
      consignee,
      notifyees,
      cargoItems,
      containers
    } = shipmentData
    const { acceptTerms } = this.state
    if (!shipment) return <h1> Loading</h1>
    const createdDate = shipment
      ? moment(shipment.updated_at).format('DD-MM-YYYY | HH:mm A')
      : moment().format('DD-MM-YYYY | HH:mm A')
    const cargo = []
    const textStyle = theme
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: 'black' }
    const brightGradientStyle = theme
      ? gradientTextGenerator(theme.colors.brightPrimary, theme.colors.brightSecondary)
      : { color: 'black' }
    const pushToCargo = (array, Comp) => {
      array.forEach((ci, i) => {
        const offset = i % 3 !== 0 ? 'offset-5' : ''
        cargo.push(<div key={v4()} className={`flex-30 ${offset} layout-row layout-align-center-center`}>
          <Comp item={ci} index={i} theme={theme} viewHSCodes={false} />
        </div>)
      })
    }
    if (shipment.load_type === 'cargo_item' && cargoItems) pushToCargo(cargoItems, CargoItemDetails)
    if (shipment.load_type === 'container' && containers) pushToCargo(containers, ContainerDetails)
    let notifyeesJSX =
      (notifyees &&
        notifyees.map(notifyee => (
          <div key={v4()} className="flex-33 layout-row">
            <div className="flex-15 layout-column layout-align-start-center">
              <i className={`${styles.icon} fa fa-user flex-none`} style={textStyle} />
            </div>
            <div className="flex-85 layout-row layout-wrap layout-align-start-start">
              <div className="flex-100">
                <TextHeading theme={theme} size={4} text="Notifyee" />
              </div>
              <p className={`${styles.address} flex-100`}>
                {notifyee.first_name} {notifyee.last_name} <br />
              </p>
            </div>
          </div>
        ))) ||
      []
    if (notifyeesJSX.length === 0) {
      notifyeesJSX = (
        <div className="flex-100 layout-row layout-wrap layout-align-start-start">
          <div className="flex-5 layout-column layout-align-start-center">
            <i className={`${styles.icon} fa fa-users flex-none`} style={textStyle} />
          </div>
          <div className="flex-95 layout-row layout-wrap layout-align-start-start">
            <div className="flex-100">
              <TextHeading theme={theme} size={4} text="Notifyees" />
            </div>
            <p className={`${styles.address} flex-100`}>No notifyees added</p>
          </div>
        </div>
      )
    }
    const acceptedBtn = (
      <div className="flex-none layout-row">
        <RoundButton theme={theme} text="Finish Booking" active handleNext={this.acceptShipment} />
      </div>
    )
    const nonAcceptedBtn = (
      <div className="flex-none layout-row">
        <RoundButton theme={theme} text="Finish Booking" handleNext={e => e.preventDefault()} />
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-wrap">
        <div className="flex-100 layout-row layout-wrap layout-align-center">
          <div
            className={`${
              defaults.content_width
            } flex-none  layout-row layout-wrap layout-align-start`}
          >
            <div className={` ${styles.thank_box} flex-100 layout-row layout-wrap`}>
              <div
                className={` ${
                  styles.thank_you
                } flex-100 layout-row layout-wrap layout-align-start`}
              >
                <p className="flex-100">
                  Please review your booking details before confirming the shipment.
                </p>
              </div>
            </div>
            <RouteHubBox hubs={hubs} route={schedules} theme={theme} />
          </div>
          <div className={`${styles.b_summ} flex-100 layout-row layout-align-center`}>
            <div
              className={`${
                defaults.content_width
              } flex-none  layout-row layout-wrap layout-align-start`}
            >
              <div className={`${styles.b_summ_top} flex-100 layout-row`}>
                <div className="flex-33 layout-row">
                  <div className="flex-15 layout-column layout-align-start-center">
                    <i className={`${styles.icon} fa fa-user flex-none`} style={textStyle} />
                  </div>
                  <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                    <div className="flex-100">
                      <TextHeading theme={theme} size={4} text="Shipper" />
                    </div>
                    <p className={`${styles.address} flex-100`}>
                      {`${shipper.data.first_name} ${shipper.data.last_name} `} <br />
                      {` ${shipper.location.street ? shipper.location.street : ''} 
                                                ${
      shipper.location.street_number
        ? shipper.location.street_number
        : ''
      } `}
                      <br />
                      {` ${shipper.location.zip_code} ${shipper.location.city} `}
                      <br />
                      {` ${shipper.location.country} `}
                    </p>
                  </div>
                </div>
                <div className="flex-33 layout-row">
                  <div className="flex-15 layout-column layout-align-start-center">
                    <i className={`${styles.icon} fa fa-user flex-none`} style={textStyle} />
                  </div>
                  <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                    <div className="flex-100">
                      <TextHeading theme={theme} size={4} text="Consignee" />
                    </div>
                    <p className={`${styles.address} flex-100`}>
                      {`${consignee.data.first_name}
                                            ${consignee.data.last_name} `}{' '}
                      <br />
                      {`${consignee.location.street ? consignee.location.street : ''}
                                            ${
      consignee.location.street_number
        ? consignee.location.street_number
        : ''
      } `}{' '}
                      <br />
                      {`${consignee.location.zip_code}
                                            ${consignee.location.city} `}{' '}
                      <br />
                      {`${consignee.location.country} `}
                    </p>
                  </div>
                </div>
                <div className="flex-33 layout-row layout-align-end layout-wrap">
                  <p className="flex-100">Booking placed at: {createdDate}</p>
                  <p className="flex-100">
                    Booking placed by: {user.first_name} {user.last_name}{' '}
                  </p>
                </div>
              </div>
              <div className={`${styles.b_summ_top} flex-100 layout-row layout-wrap`}>
                {notifyeesJSX}
              </div>
              <div className={`${styles.b_summ_bottom} flex-100 layout-row layout-wrap`}>
                <div className={`${styles.wrapper_cargo} flex-100 layout-row layout-wrap`}>
                  <div className="flex-100 layout-row layout-align-start-center">
                    <div className="flex-none clip">
                      <TextHeading theme={theme} size={3} text="Cargo Details" />
                    </div>
                  </div>
                  {cargo}
                </div>
                <div className="flex-100 layout-row layout-align-end-end">
                  <div
                    className={`${
                      styles.tot_price
                    } flex-none layout-row layout-align-space-between`}
                    style={brightGradientStyle}
                  >
                    <p>Total Price:</p>
                    <Tooltip theme={theme} icon="fa-info-circle" color="white" text="total_price" />
                    <Price value={shipment.total_price} user={user} />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div className={`${styles.btn_sec} flex-100 layout-row layout-wrap layout-align-center`}>
          <div
            className={`${
              defaults.content_width
            } flex-none  layout-row layout-wrap layout-align-start-center`}
          >
            <div className="flex-50 layout-row layout-align-start-center">
              <div className="flex-15 layout-row layout-align-center-center">
                <Checkbox
                  onChange={this.toggleAcceptTerms}
                  checked={this.state.insuranceView}
                  theme={theme}
                />
              </div>
              <div className="flex layout-row layout-align-start-center">
                <div className="flex-5" />
                <p className="flex-95">
                  By checking this box you certify the provided information is accurate and agree to
                  the Terms and Conditions of {this.props.tenant.name}
                </p>
              </div>
            </div>
            <div className="flex-50 layout-row layout-align-end-center">
              {acceptTerms ? acceptedBtn : nonAcceptedBtn}
            </div>
          </div>
        </div>
        <hr className={`${styles.sec_break} flex-100`} />
        <div
          className={`${
            styles.back_to_dash_sec
          } flex-100 layout-row layout-wrap layout-align-center`}
        >
          <div
            className={`${
              defaults.content_width
            } flex-none content-width layout-row layout-align-start-center`}
          >
            <RoundButton
              theme={theme}
              text="Back to dashboard"
              back
              iconClass="fa-angle0-left"
              handleNext={() => shipmentDispatch.toDashboard()}
            />
          </div>
        </div>
      </div>
    )
  }
}
BookingConfirmation.propTypes = {
  theme: PropTypes.theme,
  shipmentData: PropTypes.shipmentData.isRequired,
  setStage: PropTypes.func.isRequired,
  tenant: PropTypes.tenant.isRequired,
  user: PropTypes.user.isRequired,
  shipmentDispatch: PropTypes.shape({
    toDashboard: PropTypes.func
  }).isRequired
}

BookingConfirmation.defaultProps = {
  theme: null
}

export default BookingConfirmation
