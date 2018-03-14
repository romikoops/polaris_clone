import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import { moment, documentTypes, shipmentStatii } from '../../constants'
import styles from './BookingConfirmation.scss'
import { RouteHubBox } from '../RouteHubBox/RouteHubBox'
import { RoundButton } from '../RoundButton/RoundButton'
import defaults from '../../styles/default_classes.scss'
// import { Price } from '../Price/Price'
import { TextHeading } from '../TextHeading/TextHeading'
import { gradientTextGenerator } from '../../helpers'
// import { Tooltip } from '../Tooltip/Tooltip'
import { Checkbox } from '../Checkbox/Checkbox'
import { CargoItemGroup } from '../Cargo/Item/Group'
import { CargoContainerGroup } from '../Cargo/Container/Group'
import DocumentsForm from '../Documents/Form'
import Contact from '../Contact/Contact'

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
      acceptTerms: false,
      collapser: {}
    }
    this.toggleAcceptTerms = this.toggleAcceptTerms.bind(this)
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
  handleCollapser (key) {
    this.setState({
      collapser: {
        ...this.state.collapser,
        [key]: !this.state.collapser[key]
      }
    })
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
    const { theme, shipmentData, shipmentDispatch } = this.props
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
    const { acceptTerms, collapser } = this.state
    const hubsObj = { startHub: locations.startHub, endHub: locations.endHub }
    if (!shipment) return <h1> Loading</h1>

    let cargoView

    const textStyle = theme
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: 'black' }
    // const brightGradientStyle = theme
    //   ? gradientTextGenerator(theme.colors.brightPrimary, theme.colors.brightSecondary)
    //   : { color: 'black' }
    const createdDate = shipment
      ? moment(shipment.updated_at).format('DD-MM-YYYY | HH:mm A')
      : moment().format('DD-MM-YYYY | HH:mm A')
    if (containers) {
      cargoView = this.prepContainerGroups(containers)
    }
    if (cargoItems.length > 0) {
      cargoView = this.prepCargoItemGroups(cargoItems)
    }

    const shipperAndConsignee = [
      <Contact contact={shipper} contactType="Shipper" textStyle={textStyle} />,
      <Contact contact={consignee} contactType="Consignee" textStyle={textStyle} />
    ]

    if (shipment.direction === 'import') shipperAndConsignee.reverse()

    const notifyeesJSX =
      (notifyees &&
        notifyees.map(notifyee => (
          <div key={v4()} className="flex-40 layout-row">
            <div className="flex-15 layout-column layout-align-start-center">
              <i className={`${styles.icon} fa fa-envelope-open-o flex-none`} style={textStyle} />
            </div>
            <div className="flex-85 layout-row layout-wrap layout-align-start-start">
              <div className="flex-100">
                <h3 style={{ fontWeight: 'normal' }}>Notifyee</h3>
              </div>
              <p style={{ marginTop: 0 }}>
                {notifyee.first_name} {notifyee.last_name}
              </p>
            </div>
          </div>
        ))) ||
      []
    if (notifyeesJSX.length % 2 === 1) {
      notifyeesJSX.push(<div className="flex-40" />)
    }
    const acceptedBtn = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          text="Finish Booking"
          handleNext={() => this.acceptShipment()}
          active
        />
      </div>
    )
    const nonAcceptedBtn = (
      <div className="flex-none layout-row">
        <RoundButton theme={theme} text="Finish Booking" handleNext={e => e.preventDefault()} />
      </div>
    )

    const feeHash = shipment.schedules_charges[schedules[0].hub_route_key]
    const docView = []
    if (documents) {
      documents.forEach((doc) => {
        docView.push(<div className="flex-50 layout-row" style={{ padding: '10px' }}>
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
    const themeTitled =
      theme && theme.colors
        ? { background: theme.colors.primary, color: 'white' }
        : { background: 'rgba(0,0,0,0.25)', color: 'white' }
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-center-start">
        <div
          className="
          flex-none
          layout-row
          layout-wrap
          layout-align-center-start
          content_width_booking"
        >
          <div
            className={
              `${styles.shipment_card} flex-100 ` +
              'layout-row layout-align-space-between-center layout-wrap'
            }
          >
            <div
              style={themeTitled}
              className={`${
                styles.heading_style
              } flex-100 layout-row layout-align-space-between-center`}
            >
              <TextHeading theme={theme} color="white" size={3} text="Overview" />
              <div
                className="flex-10 layout-row layout-align-center-center"
                onClick={() => this.handleCollapser('overview')}
              >
                {collapser.overview ? (
                  <i className="fa fa-chevron-down pointy" />
                ) : (
                  <i className="fa fa-chevron-up pointy" />
                )}
              </div>
            </div>
            <div className={`${collapser.overview ? styles.collapsed : ''} ${styles.main_panel}`}>
              <div
                className={
                  `${styles.inner_wrapper} flex-100 ` +
                  'layout-row layout-wrap layout-align-start-start'
                }
              >
                <div className="flex-100 layout-row layout-wrap layout-align-space-between-start">
                  <h4 className=" flex-none">Shipment Reference:</h4>
                  <h4 className="clip flex-none offset-5" style={textStyle}>
                    {shipment.imc_reference}
                  </h4>
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-space-between-start">
                  <p className={` ${styles.sec_subtitle_text_normal} flex-none`}>Status:</p>
                  <p className={` ${styles.sec_subtitle_text} flex-none offset-5 `}>
                    {shipmentStatii[shipment.status]}
                  </p>
                </div>
                <div className="flex-100 layout-row layout-wrap layout-align-space-between-start">
                  <p className={` ${styles.sec_subtitle_text_normal} flex-none`}>Created at:</p>
                  <p className={` ${styles.sec_subtitle_text} flex-none offset-5 `}>
                    {createdDate}
                  </p>
                </div>
              </div>
            </div>
          </div>
          <div
            className={
              `${styles.shipment_card_itinerary} flex-100 ` +
              'layout-row layout-align-space-between-center layout-wrap'
            }
          >
            <div
              style={themeTitled}
              className={`${
                styles.heading_style
              } flex-100 layout-row layout-align-space-between-center`}
            >
              <TextHeading theme={theme} color="white" size={3} text="Itinerary" />
              <div
                className="flex-10 layout-row layout-align-center-center"
                onClick={() => this.handleCollapser('itinerary')}
              >
                {collapser.itinerary ? (
                  <i className="fa fa-chevron-down pointy" />
                ) : (
                  <i className="fa fa-chevron-up pointy" />
                )}
              </div>
            </div>
            <div className={`${collapser.itinerary ? styles.collapsed : ''} ${styles.main_panel}`}>
              <div
                className={`${
                  styles.inner_wrapper
                } flex-100 layout-row layout-wrap layout-align-start-start`}
              >
                <RouteHubBox hubs={hubsObj} route={schedules} theme={theme} />
                <div
                  className="flex-100 layout-row layout-align-space-between-center"
                  style={{ position: 'relative' }}
                >
                  <div className="flex-40 layout-row layout-wrap layout-align-center-center">
                    <div className="flex-100 layout-row layout-align-center-start layout-wrap">
                      <p className="flex-100 center letter_3"> Expected Time of Departure:</p>
                      <p className="flex-none letter_3">
                        {`${moment(shipment.planned_etd).format('DD/MM/YYYY | HH:mm')}`}
                      </p>
                    </div>
                    {shipment.has_pre_carriage ? (
                      <div className="flex-100 layout-row layout-align-start-start">
                        <address className="flex-none">
                          {`${locations.origin.street_number} ${locations.origin.street}`} <br />
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
                      <div className="flex-100 layout-row layout-align-start-start">
                        <address className="flex-none">
                          {`${locations.destination.street_number} ${locations.destination.street}`}{' '}
                          <br />
                          {`${locations.destination.city}`} <br />
                          {`${locations.destination.zip_code}`} <br />
                          {`${locations.destination.country}`} <br />
                        </address>
                      </div>
                    ) : (
                      ''
                    )}
                  </div>
                  <div className={`${styles.time_edit_button}`} onClick={this.toggleEditTime}>
                    <i className="fa fa-pencil clip" style={textStyle} />
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            className={
              `${styles.shipment_card} flex-100 ` +
              'layout-row layout-align-space-between-center layout-wrap'
            }
          >
            <div
              style={themeTitled}
              className={`${
                styles.heading_style
              } flex-100 layout-row layout-align-space-between-center`}
            >
              <TextHeading theme={theme} color="white" size={3} text="Fares & Fees" />
              <div
                className="flex-10 layout-row layout-align-center-center"
                onClick={() => this.handleCollapser('charges')}
              >
                {collapser.charges ? (
                  <i className="fa fa-chevron-down pointy" />
                ) : (
                  <i className="fa fa-chevron-up pointy" />
                )}
              </div>
            </div>
            <div
              className={`${
                styles.total_row
              } flex-100 layout-row layout-wrap layout-align-space-around-center`}
            >
              <h3 className="flex-70 letter_3">Shipment Total:</h3>
              <div className="flex-30 layout-row layout-align-end-center">
                <h3 className="flex-none letter_3">{`${shipment.total_price.currency} ${parseFloat(shipment.total_price.value).toFixed(2)} `}</h3>
              </div>
            </div>
            <div className={`${collapser.charges ? styles.collapsed : ''} ${styles.main_panel}`}>
              <div
                className={
                  `${styles.inner_wrapper} flex-100 ` +
                  'layout-row layout-wrap layout-align-start-start'
                }
              >
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
                      {feeHash.trucking_pre.total ? (
                        <h4 className="flex-100 no_m letter_3 center">
                          {feeHash.trucking_pre.total.currency}
                        </h4>
                      ) : (
                        <h4 className="flex-100 no_m letter_3 center" style={{ opacity: '0' }}>
                          None
                        </h4>
                      )}
                      <h3 className="flex-100 no_m letter_3 center">
                        {shipment.has_pre_carriage
                          ? `${feeHash.trucking_pre.total.value.toFixed(2)}`
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
                      <h5 className="flex-none letter_3">On Carriage</h5>
                    </div>
                    <div className="flex-100 layout-row layout-align-center-center layout-wrap">
                      {feeHash.trucking_on.total ? (
                        <h4 className="flex-100 no_m letter_3 center">
                          {feeHash.trucking_on.total.currency}
                        </h4>
                      ) : (
                        <h4 className="flex-100 no_m letter_3 center" style={{ opacity: '0' }}>
                          None
                        </h4>
                      )}
                      <h3 className="flex-100 no_m letter_3 center">
                        {shipment.has_on_carriage
                          ? `${feeHash.trucking_on.total.value.toFixed(2)}`
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
                      <h5 className="flex-none letter_3">Insurance</h5>
                    </div>
                    <div className="flex-100 layout-row layout-align-center-center layout-wrap">
                      {feeHash.insurance && feeHash.insurance.val ? (
                        <h4 className="flex-100 no_m letter_3 center">
                          {feeHash.insurance.currency}
                        </h4>
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
                      {feeHash.customs && feeHash.customs.val ? (
                        <h4 className="flex-100 no_m letter_3 center">
                          {feeHash.customs.currency}
                        </h4>
                      ) : (
                        <h4 className="flex-100 no_m letter_3 center" style={{ opacity: '0' }}>
                          None
                        </h4>
                      )}
                      <h3 className="flex-100 no_m letter_3 center">
                        {feeHash.customs && feeHash.customs.val
                          ? `${feeHash.customs.val.toFixed(2)}`
                          : 'None'}
                      </h3>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            className={
              `${styles.shipment_card} flex-100 ` +
              'layout-row layout-align-space-between-center layout-wrap'
            }
          >
            <div
              style={themeTitled}
              className={`${
                styles.heading_style
              } flex-100 layout-row layout-align-space-between-center`}
            >
              <TextHeading theme={theme} color="white" size={3} text="Contact Details" />
              <div
                className="flex-10 layout-row layout-align-center-center"
                onClick={() => this.handleCollapser('contacts')}
              >
                {collapser.contacts ? (
                  <i className="fa fa-chevron-down pointy" />
                ) : (
                  <i className="fa fa-chevron-up pointy" />
                )}
              </div>
            </div>
            <div className={`${collapser.contacts ? styles.collapsed : ''} ${styles.main_panel}`}>
              <div
                className={
                  `${styles.inner_wrapper} flex-100 ` +
                  'layout-row layout-wrap layout-align-start-start'
                }
              >
                <div
                  className={
                    `${styles.b_summ_top} flex-100 ` +
                    'layout-row layout-align-space-around-stretch'
                  }
                >
                  {shipperAndConsignee}
                </div>
                <div className="flex-100 layout-row layout-align-space-around-center layout-wrap">
                  {' '}
                  {notifyeesJSX}{' '}
                </div>
              </div>
            </div>
          </div>
          <div
            className={
              `${styles.shipment_card} flex-100 ` +
              'layout-row layout-align-space-between-center layout-wrap'
            }
          >
            <div
              style={themeTitled}
              className={`${
                styles.heading_style
              } flex-100 layout-row layout-align-space-between-center`}
            >
              <TextHeading theme={theme} color="white" size={3} text="Cargo Details" />
              <div
                className="flex-10 layout-row layout-align-center-center"
                onClick={() => this.handleCollapser('cargo')}
              >
                {collapser.cargo ? (
                  <i className="fa fa-chevron-down pointy" />
                ) : (
                  <i className="fa fa-chevron-up pointy" />
                )}
              </div>
            </div>
            <div className={`${collapser.cargo ? styles.collapsed : ''} ${styles.main_panel}`}>
              <div
                className={`${
                  styles.inner_wrapper
                } flex-100 layout-row layout-wrap layout-align-start-start`}
              >
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                  {cargoView}
                </div>
              </div>
            </div>
          </div>
          <div
            className={
              `${styles.shipment_card} flex-100 ` +
              'layout-row layout-align-space-between-center layout-wrap'
            }
          >
            <div
              style={themeTitled}
              className={`${
                styles.heading_style
              } flex-100 layout-row layout-align-space-between-center`}
            >
              <TextHeading theme={theme} color="white" size={3} text="Documents" />
              <div
                className="flex-10 layout-row layout-align-center-center"
                onClick={() => this.handleCollapser('documents')}
              >
                {collapser.documents ? (
                  <i className="fa fa-chevron-down pointy" />
                ) : (
                  <i className="fa fa-chevron-up pointy" />
                )}
              </div>
            </div>
            <div className={`${collapser.documents ? styles.collapsed : ''} ${styles.main_panel}`}>
              <div
                className={
                  `${styles.inner_wrapper} flex-100 ` +
                  'layout-row layout-wrap layout-align-start-start'
                }
              >
                <div className="flex-100 layout-row layout-wrap layout-align-start-center">
                  {docView}
                </div>
              </div>
            </div>
          </div>

          <div
            className={
              `${styles.shipment_card} flex-100 ` +
              'layout-row layout-align-space-between-center layout-wrap'
            }
          >
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
              <div
                style={themeTitled}
                className={
                  `${styles.heading_style} flex-100 ` +
                  'layout-row layout-align-space-between-center'
                }
              >
                <TextHeading theme={theme} color="white" size={3} text="Agree and Submit" />
              </div>
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
              <div className="flex-33 layout-row layout-align-end-center">
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
                iconClass="fa-angle-left"
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
  // user: PropTypes.user.isRequired,
  shipmentDispatch: PropTypes.shape({
    toDashboard: PropTypes.func
  }).isRequired
}

BookingConfirmation.defaultProps = {
  theme: null
}

export default BookingConfirmation
