import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import { moment, documentTypes } from '../../constants'
import styles from './BookingConfirmation.scss'
import { RouteHubBox } from '../RouteHubBox/RouteHubBox'
import { RoundButton } from '../RoundButton/RoundButton'
import defaults from '../../styles/default_classes.scss'
import { Price } from '../Price/Price'
import { TextHeading } from '../TextHeading/TextHeading'
import { gradientTextGenerator } from '../../helpers'
import { Tooltip } from '../Tooltip/Tooltip'
import { Checkbox } from '../Checkbox/Checkbox'
import { CargoItemGroup } from '../Cargo/Item/Group'
import { CargoContainerGroup } from '../Cargo/Container/Group'
import DocumentsForm from '../Documents/Form'

export class BookingConfirmation extends Component {
  static sumCargoFees (cargos) {
    let total = 0.0
    let curr = ''
    Object.keys(cargos).forEach((k) => {
      total += parseFloat(cargos[k].total.value)
      curr = cargos[k].total.currency
    })

    return { currency: curr, total: total.toFixed(2) }
  }
  static sumCustomsFees (cargos) {
    let total = 0.0
    let curr = ''
    const keys = Object.keys(cargos)

    keys.forEach((k) => {
      if (cargos[k].CUSTOMS && cargos[k].CUSTOMS.value) {
        total += parseFloat(cargos[k].CUSTOMS.value)
        curr = cargos[k].CUSTOMS.currency
      }
    })
    if (total === 0.0) {
      return { currency: '', total: 'None' }
    }
    return { currency: curr, total: total.toFixed(2) }
  }
  constructor (props) {
    super(props)
    this.state = {
      acceptTerms: false
    }
    this.toggleAcceptTerms = this.toggleAcceptTerms.bind(this)
    this.acceptShipment = this.acceptShipment.bind(this)
    this.fileFn = this.fileFn.bind(this)
    this.deleteDoc = this.deleteDoc.bind(this)
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
  deleteDoc (doc) {
    const { shipmentDispatch } = this.props
    shipmentDispatch.deleteDocument(doc.id)
  }
  acceptShipment () {
    const { shipmentData, shipmentDispatch } = this.props
    const { shipment } = shipmentData
    shipmentDispatch.acceptShipment(shipment.id)
  }
  fileFn (file) {
    const { shipmentData, shipmentDispatch } = this.props
    const { shipment } = shipmentData
    const type = file.doc_type
    const url = `/shipments/${shipment.id}/upload/${type}`
    shipmentDispatch.uploadDocument(file, type, url)
  }
  prepCargoItemGroups (cargos) {
    const { theme, shipmentData } = this.props
    const { cargoItemTypes, hsCodes } = shipmentData
    const cargoGroups = {}
    let groupCount = 1
    const resultArray = []
    cargos.forEach((c) => {
      if (!cargoGroups[c.id]) {
        cargoGroups[c.id] = {
          dimension_y: parseFloat(c.dimension_y) * parseInt(c.quantity, 10),
          dimension_z: parseFloat(c.dimension_z) * parseInt(c.quantity, 10),
          dimension_x: parseFloat(c.dimension_x) * parseInt(c.quantity, 10),
          payload_in_kg: parseFloat(c.payload_in_kg) * parseInt(c.quantity, 10),
          quantity: 1,
          groupAlias: groupCount,
          cargo_group_id: c.id,
          chargeable_weight: parseFloat(c.chargeable_weight) * parseInt(c.quantity, 10),
          hsCodes: c.hs_codes,
          hsText: c.hs_text,
          cargoType: cargoItemTypes[c.cargo_item_type_id],
          volume:
            parseFloat(c.dimension_y) *
            parseFloat(c.dimension_x) *
            parseFloat(c.dimension_y) /
            1000000 *
            parseInt(c.quantity, 10),
          items: []
        }
        for (let index = 0; index < parseInt(c.quantity, 10); index++) {
          cargoGroups[c.id].items.push(c)
        }
        groupCount += 1
      }
    })
    Object.keys(cargoGroups).forEach((k) => {
      resultArray.push(<CargoItemGroup group={cargoGroups[k]} theme={theme} hsCodes={hsCodes} />)
    })
    return resultArray
  }
  prepContainerGroups (cargos) {
    const { theme, shipmentData } = this.props
    const { hsCodes } = shipmentData
    const cargoGroups = {}
    let groupCount = 1
    const resultArray = []
    cargos.forEach((c) => {
      if (!cargoGroups[c.id]) {
        cargoGroups[c.id] = {
          items: [],
          size_class: c.size_class,
          payload_in_kg: parseFloat(c.payload_in_kg) * parseInt(c.quantity, 10),
          tare_weight: parseFloat(c.tare_weight) * parseInt(c.quantity, 10),
          gross_weight: parseFloat(c.gross_weight) * parseInt(c.quantity, 10),
          quantity: 1,
          groupAlias: groupCount,
          cargo_group_id: c.id,
          hsCodes: c.hs_codes,
          hsText: c.customs_text
        }
        groupCount += 1
      }
    })
    Object.keys(cargoGroups).forEach((k) => {
      resultArray.push(<CargoContainerGroup
        group={cargoGroups[k]}
        theme={theme}
        hsCodes={hsCodes}
      />)
    })
    return resultArray
  }
  render () {
    const {
      theme, shipmentData, user, shipmentDispatch
    } = this.props
    if (!shipmentData) return <h1>Loading</h1>
    const {
      shipment,
      schedules,
      locations,
      shipper,
      consignee,
      notifyees,
      cargoItems,
      containers,
      documents
    } = shipmentData
    const { acceptTerms } = this.state
    const hubs = { startHub: locations.startHub, endHub: locations.endHub }
    if (!shipment) return <h1> Loading</h1>

    let cargoView

    const textStyle = theme
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: 'black' }
    const brightGradientStyle = theme
      ? gradientTextGenerator(theme.colors.brightPrimary, theme.colors.brightSecondary)
      : { color: 'black' }

    if (containers) {
      cargoView = this.prepContainerGroups(containers)
    }
    if (cargoItems.length > 0) {
      cargoView = this.prepCargoItemGroups(cargoItems)
    }

    let notifyeesJSX =
      (notifyees &&
        notifyees.map(notifyee => (
          <div key={v4()} className="flex-40 layout-row">
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
    } else if (notifyeesJSX.length % 2 === 1) {
      notifyeesJSX.push(<div className="flex-40" />)
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
    const shipperContact = (
      <div className="flex-45 layout-row">
        <div className="flex-10 layout-column layout-align-start-center">
          <i className={` ${styles.icon} fa fa-envelope-open-o flex-none`} style={textStyle} />
        </div>
        <div className="flex-90 layout-row layout-wrap layout-align-start-start">
          <p className="flex-100">Sender</p>
          <div className="flex-100 layout-row layout-align-space-between-start">
            <div className="flex-60 layout-row layout-wrap layout-align-center-start">
              <p className={`${styles.contact_text} flex-100`}>
                {shipper.data.first_name} {shipper.data.last_name}
              </p>
              <p className={`${styles.contact_text} flex-100`}>{shipper.data.company_name}</p>
              <p className={`${styles.contact_text} flex-100`}>{shipper.data.email}</p>
              <p className={`${styles.contact_text} flex-100`}>{shipper.data.phone}</p>
            </div>
            <div className="flex-100 layout-row layout-align-space-between-start layout-wrap">
              <p className={`${styles.contact_text} flex-100 center`}>Address</p>
              <address className={` ${styles.address} flex-100 center`}>
                {shipper.location
                  ? `${shipper.location.street} ${shipper.location.street_number}`
                  : ''}{' '}
                <br />
                {shipper.location
                  ? `${shipper.location.zip_code} ${shipper.location.city}`
                  : ''}{' '}
                <br />
                {shipper.location ? `${shipper.location.country}` : ''}
              </address>
            </div>
          </div>
        </div>
      </div>
    )
    const consigneeContact = (
      <div className="flex-45 layout-row">
        <div className="flex-10 layout-column layout-align-start-center">
          <i className={` ${styles.icon} fa fa-envelope-open-o flex-none`} style={textStyle} />
        </div>
        <div className="flex-90 layout-row layout-wrap layout-align-start-start">
          <p className="flex-100">Receiver</p>
          <div className="flex-100 layout-row layout-align-space-between-start">
            <div className="flex-60 layout-row layout-wrap layout-align-center-start">
              <p className={`${styles.contact_text} flex-100`}>
                {consignee.data.first_name} {consignee.data.last_name}
              </p>
              <p className={`${styles.contact_text} flex-100`}>{consignee.data.company_name}</p>
              <p className={`${styles.contact_text} flex-100`}>{consignee.data.email}</p>
              <p className={`${styles.contact_text} flex-100`}>{consignee.data.phone}</p>
            </div>
            <div className="flex-100 layout-row layout-align-space-between-start layout-wrap">
              <p className={`${styles.contact_text} flex-100 center`}>Address</p>
              <address className={` ${styles.address} flex-100 center`}>
                {consignee.location
                  ? `${consignee.location.street} ${consignee.location.street_number}`
                  : ''}{' '}
                <br />
                {consignee.location
                  ? `${consignee.location.zip_code} ${consignee.location.city}`
                  : ''}{' '}
                <br />
                {consignee.location ? `${consignee.location.country}` : ''}
              </address>
            </div>
          </div>
        </div>
      </div>
    )
    const feeHash = shipment.schedules_charges[schedules[0].hub_route_key]
    const docView = []
    if (documents) {
      documents.forEach((doc) => {
        docView.push(<div className="flex-50 layout-row">
          <DocumentsForm
            theme={theme}
            type={doc.doc_type}
            dispatchFn={this.fileFn}
            text={documentTypes[doc.doc_type]}
            doc={doc}
            viewer
            deleteFn={this.deleteDoc}
          />
        </div>)
      })
    }
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-center-start">
        <div className="flex-none
          content_width_booking
          layout-row
          layout-wrap
          layout-align-start-start"
        >
          <div className={` ${styles.thank_box} flex-100 layout-row layout-wrap`}>
            <div
              className={` ${styles.thank_you} flex-100 layout-row layout-wrap layout-align-start`}
            >
              <p className="flex-100">
                Please review your booking below before confirming the shipment.
              </p>
            </div>
          </div>
          <div
            className={`flex-100 layout-row layout-align-space-between-center layout-wrap ${
              styles.sec_title
            }`}
          />
          <div
            className={`${
              styles.shipment_card
            } flex-100 layout-row layout-align-start-center layout-wrap`}
          >
            <div className="flex-100 layout-row layout-align-start-center">
              <TextHeading theme={theme} size={3} text="Itinerary" />
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-space-between-start">
              <p className=" flex-none">Shipment:</p>
              <p className="clip flex-none offset-5" style={textStyle}>
                {shipment.imc_reference}
              </p>
            </div>
            <RouteHubBox hubs={hubs} route={schedules} theme={theme} />
            <div
              className="flex-100 layout-row layout-align-space-between-center"
              style={{ position: 'relative' }}
            >
              <div className="flex-40 layout-row layout-wrap layout-align-center-center">
                <div className="flex-100 layout-row layout-align-center-start layout-wrap">
                  <p className="flex-100 center letter_3"> Expected Time of Departure:</p>
                  <p className="flex-none letter_3">{` ${moment(shipment.planned_etd).format('DD/MM/YYYY | HH:mm')}`}</p>
                </div>
                {shipment.has_pre_carriage ? (
                  <div className="flex-100 layout-row layout-align-center-start layout-wrap">
                    <div className="flex-100 layout-row layout-align-center-center">
                      <p className="flex-none letter_3"> Pickup Address</p>
                    </div>
                    <address className="flex-none">
                      {`${locations.origin.street_address} `} <br />
                      {`${locations.origin.city}`} <br />
                      {`${locations.origin.zip_code}`} <br />
                      {`${locations.origin.country}`} <br />
                    </address>
                  </div>
                ) : (
                  ''
                )}
              </div>
              <div className="flex-40 layout-row layout-wrap layout-align-center-center">
                <div className="flex-100 layout-row layout-align-center-start layout-wrap">
                  <p className="flex-100 center letter_3"> Expected Time of Arrival:</p>
                  <p className="flex-none letter_3">{`${moment(shipment.planned_eta).format('DD/MM/YYYY | HH:mm')}`}</p>
                </div>
                {shipment.has_on_carriage ? (
                  <div className="flex-100 layout-row layout-align-center-start layout-wrap">
                    <div className="flex-100 layout-row layout-align-center-center">
                      <p className="flex-none letter_3">Delivery Address</p>
                    </div>
                    <address className="flex-none">
                      {`${locations.destination.street_address}`} <br />
                      {`${locations.destination.city}`} <br />
                      {`${locations.destination.zip_code}`} <br />
                      {`${locations.destination.country}`} <br />
                    </address>
                  </div>
                ) : (
                  ''
                )}
              </div>
            </div>
          </div>
          <div
            className={`${
              styles.shipment_card
            } flex-100 layout-row layout-align-start-center layout-wrap`}
          >
            <div className="flex-100 layout-row layout-align-start-center">
              <TextHeading theme={theme} size={3} text="Fares & Fees" />
            </div>
            <div
              className={`${
                styles.total_row
              } flex-100 layout-row layout-wrap layout-align-space-around-center`}
            />
            <h3 className="flex-70 letter_3">Shipment Total:</h3>
            <div className="flex-30 layout-row layout-align-end-center">
              <div className="flex-100 layout-row layout-align-end-end">
                <div
                  className={`${styles.tot_price} flex-none layout-row layout-align-space-between`}
                  style={brightGradientStyle}
                >
                  <p>Total Price:</p>
                  <Tooltip theme={theme} icon="fa-info-circle" color="white" text="total_price" />
                  <Price value={parseFloat(shipment.total_price.value).toFixed(2)} user={user} />
                </div>
              </div>
            </div>
            <div
              className={`${
                styles.b_summ_top
              } flex-100 layout-row layout-align-space-around-center`}
            >
              <div
                className={`${
                  styles.charge_card
                } flex-30 layout-row layout-align-start-start layout-wrap`}
              >
                <div className="flex-100 layout-row layout-align-center-center">
                  <h5 className="flex-none letter_3">Freight</h5>
                </div>
                <div className="flex-100 layout-row layout-align-center-center layout-wrap">
                  <h4 className="flex-100 no_m letter_3 center">
                    {BookingConfirmation.sumCargoFees(feeHash.cargo).currency}
                  </h4>
                  <h3 className="flex-100 no_m letter_3 center">
                    {BookingConfirmation.sumCargoFees(feeHash.cargo).total}
                  </h3>
                </div>
              </div>
              <div
                className={`${
                  styles.charge_card
                } flex-30 layout-row layout-align-start-start layout-wrap`}
              >
                <div className="flex-100 layout-row layout-align-center-center">
                  <h5 className="flex-none letter_3">Pre Carriage</h5>
                </div>
                <div className="flex-100 layout-row layout-align-center-center layout-wrap">
                  {feeHash.trucking_pre.currency ? (
                    <h4 className="flex-100 no_m letter_3 center">
                      {feeHash.trucking_pre.currency}
                    </h4>
                  ) : (
                    <h4 className="flex-100 no_m letter_3 center" style={{ opacity: '0' }}>
                      None
                    </h4>
                  )}
                  <h3 className="flex-100 no_m letter_3 center">
                    {shipment.has_pre_carriage ? `${feeHash.trucking_pre.value}` : 'None'}
                  </h3>
                </div>
              </div>
              <div
                className={`${
                  styles.charge_card
                } flex-30 layout-row layout-align-start-start layout-wrap`}
              >
                <div className="flex-100 layout-row layout-align-center-center">
                  <h5 className="flex-none letter_3">On Carriage</h5>
                </div>
                <div className="flex-100 layout-row layout-align-center-center layout-wrap">
                  {feeHash.trucking_on.currency ? (
                    <h4 className="flex-100 no_m letter_3 center">
                      {feeHash.trucking_on.currency}
                    </h4>
                  ) : (
                    <h4 className="flex-100 no_m letter_3 center" style={{ opacity: '0' }}>
                      None
                    </h4>
                  )}
                  <h3 className="flex-100 no_m letter_3 center">
                    {shipment.has_on_carriage ? `${feeHash.trucking_on.value}` : 'None'}
                  </h3>
                </div>
              </div>
              <div
                className={`${
                  styles.charge_card
                } flex-30 layout-row layout-align-start-start layout-wrap`}
              >
                <div className="flex-100 layout-row layout-align-center-center">
                  <h5 className="flex-none letter_3">Insurance</h5>
                </div>
                <div className="flex-100 layout-row layout-align-center-center layout-wrap">
                  {feeHash.insurance && feeHash.insurance.val ? (
                    <h4 className="flex-100 no_m letter_3 center">{feeHash.insurance.currency}</h4>
                  ) : (
                    <h4 className="flex-100 no_m letter_3 center" style={{ opacity: '0' }}>
                      None
                    </h4>
                  )}
                  <h3 className="flex-100 no_m letter_3 center">
                    {feeHash.insurance && feeHash.insurance.val
                      ? `${feeHash.insurance.val.toFixed(2)}`
                      : 'None'}
                  </h3>
                </div>
              </div>
              <div
                className={`${
                  styles.charge_card
                } flex-30 layout-row layout-align-start-start layout-wrap`}
              >
                <div className="flex-100 layout-row layout-align-center-center">
                  <h5 className="flex-none letter_3">Customs</h5>
                </div>
                <div className="flex-100 layout-row layout-align-center-center layout-wrap">
                  <h4 className="flex-100 no_m letter_3 center">
                    {BookingConfirmation.sumCustomsFees(feeHash.cargo).currency}
                  </h4>
                  <h3 className="flex-100 no_m letter_3 center">
                    {BookingConfirmation.sumCustomsFees(feeHash.cargo).total}
                  </h3>
                </div>
              </div>
            </div>
          </div>
          <div
            className={`${
              styles.shipment_card
            } flex-100 layout-row layout-align-start-center layout-wrap`}
          >
            <div className="flex-100 layout-row layout-align-start-center">
              <TextHeading theme={theme} size={3} text="Contact Details" />
            </div>
            <div
              className={`${
                styles.b_summ_top
              } flex-100 layout-row layout-align-space-around-center`}
            >
              {shipperContact}
              {consigneeContact}
            </div>
            <div className="flex-100 layout-row layout-align-space-around-center layout-wrap">
              {' '}
              {notifyeesJSX}{' '}
            </div>
          </div>
          <div
            className={`${
              styles.shipment_card
            } flex-100 layout-row layout-align-start-center layout-wrap`}
          >
            <div className="flex-100 layout-row layout-align-start-center">
              <TextHeading theme={theme} size={3} text="Cargo Details" />
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
              {cargoView}
            </div>
          </div>
          <div
            className={`${
              styles.shipment_card
            } flex-100 layout-row layout-align-start-center layout-wrap`}
          >
            <div className="flex-100 layout-row layout-align-start-center">
              <TextHeading theme={theme} size={3} text="Documents" />
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
              {docView}
            </div>
          </div>

          <div className={`${styles.btn_sec} flex-100 layout-row layout-wrap layout-align-center`}>
            <div
              className={`${
                defaults.content_width
              } flex-none  layout-row layout-wrap layout-align-start-center`}
            >
              <div className="flex-65 layout-row layout-align-start-center">
                <div className="flex-15 layout-row layout-align-center-center">
                  <Checkbox
                    onChange={this.toggleAcceptTerms}
                    checked={this.state.acceptTerms}
                    theme={theme}
                  />
                </div>
                <div className="flex layout-row layout-align-start-center">
                  <div className="flex-5" />
                  <div className="flex-95 layout-row layout-wrap layout-align-start-center">
                    <div className="flex-100 layout-row layout-align-start-center">
                      <TextHeading theme={theme} text="By checking this box" size={4} />
                    </div>
                    <div className="flex-100 layout-row layout-align-start-center">
                      <ul className={`flex-100 ${styles.terms_list}`}>
                        <li>you verify that all the information provided above is true</li>
                        <li>
                          you agree to our Terms and Conditions and the General Conditions of the
                          Nordic Association of Freight Forwarders (NSAB) and those of{' '}
                          {this.props.tenant.name}
                        </li>
                        <li>
                          you agree to pay the price of the shipment as stated above upon arrival of
                          the invoice
                        </li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
              <div className="flex-35 layout-row layout-align-end-center">
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
