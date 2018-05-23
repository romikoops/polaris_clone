/* eslint react/prop-types: "off" */
import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import { pick, uniqWith } from 'lodash'
import { moment, documentTypes, shipmentStatii } from '../../constants'
import styles from './BookingConfirmation.scss'
import { RouteHubBox } from '../RouteHubBox/RouteHubBox'
import { RoundButton } from '../RoundButton/RoundButton'
import defaults from '../../styles/default_classes.scss'
import { TextHeading } from '../TextHeading/TextHeading'
import { gradientTextGenerator } from '../../helpers'
import { Checkbox } from '../Checkbox/Checkbox'
import { CargoItemGroup } from '../Cargo/Item/Group'
import CargoItemGroupAggregated from '../Cargo/Item/Group/Aggregated'
import { CargoContainerGroup } from '../Cargo/Container/Group'
import DocumentsForm from '../Documents/Form'
import Contact from '../Contact/Contact'
import { IncotermRow } from '../Incoterm/Row'
import { IncotermExtras } from '../Incoterm/Extras'

import {
  ALIGN_AROUND_CENTER,
  ALIGN_AROUND_STRETCH,
  ALIGN_BETWEEN_CENTER,
  ALIGN_BETWEEN_START,
  ALIGN_CENTER,
  ALIGN_CENTER_START,
  ALIGN_END,
  ALIGN_START,
  ALIGN_START_CENTER,
  COLUMN_15,
  ROW,
  WRAP_ROW
} from '../../classNames'

const ACCEPT = `${ROW(33)} ${ALIGN_END} height_100`
// eslint-disable-next-line
const AFTER_CONTAINER = `${WRAP_ROW('NONE')} ${ALIGN_CENTER_START} content_width_booking`
// eslint-disable-next-line
const BACK_TO_DASHBOARD = `${styles.back_to_dash_sec} ${WRAP_ROW(100)} layout-align-center`
// eslint-disable-next-line
const BACK_TO_DASHBOARD_CELL = `${defaults.content_width} flex-none ${ROW('CONTENT')} ${ALIGN_START_CENTER}`
const BOOKING = `${ROW('NONE')} content_width_booking ${ALIGN_CENTER}`
const BUTTON = `${ROW('NONE')} ${ALIGN_END}`
const CHECKBOX = `${ROW(65)} ${ALIGN_START_CENTER}`
const CHECKBOX_CELL = `${ROW(15)} ${ALIGN_CENTER}`
const COLLAPSER = `${ROW(10)} ${ALIGN_CENTER}`

/**
 * Prepend with `BOOKING_CONFIRMATION` to make e2e test easier to write
 */
const CONTAINER = `BOOKING_CONFIRMATION ${WRAP_ROW(100)} ${ALIGN_CENTER_START}`

const HEADING = `${styles.heading_style} ${ROW(100)} ${ALIGN_BETWEEN_CENTER}`
const INNER_WRAPPER = `${styles.inner_wrapper} ${WRAP_ROW(100)} ${ALIGN_START}`
const INNER_WRAPPER_CELL = `${WRAP_ROW(100)} ${ALIGN_BETWEEN_START}`
// eslint-disable-next-line
const ITINERARY = `${styles.shipment_card_itinerary} ${WRAP_ROW(100)} ${ALIGN_BETWEEN_CENTER}`
const LAYOUT_WRAP = `${WRAP_ROW(100)} ${ALIGN_START_CENTER}`
const MISSING_DOCS = `${ROW(25)} ${ALIGN_START_CENTER} ${styles.no_doc}`
// eslint-disable-next-line
const SHIPMENT_CARD = `${styles.shipment_card} ${WRAP_ROW(100)} ${ALIGN_BETWEEN_CENTER}`
// eslint-disable-next-line
const SHIPMENT_CARD_CONTAINER = `${styles.shipment_card} ${WRAP_ROW(100)} ${ALIGN_BETWEEN_CENTER}`
const SUBTITLE = `${styles.sec_subtitle_text} flex-none offset-5`
const SUBTITLE_NORMAL = `${styles.sec_subtitle_text_normal} flex-none`
const SUMM_TOP = `${styles.b_summ_top} ${ROW(100)} ${ALIGN_AROUND_STRETCH}`
const TOTAL_ROW = `${styles.total_row} ${WRAP_ROW(100)} ${ALIGN_AROUND_CENTER}`

const acceptStyle = { height: '150px', marginBottom: '15px' }

export class BookingConfirmation extends Component {
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
  setCollapser (key) {
    this.setState({
      collapser: {
        ...this.state.collapser,
        [key]: !this.state.collapser[key]
      }
    })
  }
  fileFn (file) {
    const { shipmentData, shipmentDispatch } = this.props
    const { shipment } = shipmentData
    const type = file.doc_type
    const url = `/shipments/${shipment.id}/upload/${type}`

    shipmentDispatch.uploadDocument(file, type, url)
  }
  deleteDoc (doc) {
    this.props.shipmentDispatch.deleteDocument(doc.id)
  }
  toggleAcceptTerms () {
    this.setState({ acceptTerms: !this.state.acceptTerms })
  }
  requestShipment () {
    this.props.shipmentDispatch.requestShipment(this.props.shipmentData.shipment.id)
  }
  render () {
    const {
      theme,
      shipmentData,
      shipmentDispatch,
      tenant
    } = this.props

    if (!shipmentData) return <h1>Loading</h1>

    const {
      aggregatedCargo,
      cargoItemTypes,
      cargoItems,
      consignee,
      containers,
      documents,
      locations,
      notifyees,
      schedules,
      shipment,
      shipper
    } = shipmentData

    if (!shipment || !locations || !cargoItemTypes) return <h1> Loading</h1>

    const { acceptTerms, collapser } = this.state
    const hubsObj = { startHub: locations.startHub, endHub: locations.endHub }
    const terms = getTenantTerms(tenant)
    const textStyle = getTextStyle(theme)
    const createdDate = getCreatedDate(shipment)

    /**
     * if series instead of if/else is not very common
     */
    let cargoView = ''
    if (containers) {
      cargoView = prepContainerGroups(containers, this.props)
    }
    if (cargoItems.length > 0) {
      cargoView = prepCargoItemGroups(cargoItems, this.props)
    }
    if (aggregatedCargo) {
      cargoView = <CargoItemGroupAggregated group={aggregatedCargo} />
    }

    const shipperAndConsignee = getShipperAndConsignee({
      shipper, consignee, textStyle, shipment
    })
    const notifyeesJSX = getNotifyeesJSX({ notifyees, textStyle })
    const nonAcceptedBtn = getNonAcceptedBtn(theme)
    const acceptedBtn = getAcceptedBtn({
      theme,
      handleNext: this.requestShipment
    })

    const feeHash = shipment.schedules_charges[schedules[0].hub_route_key]
    const { docView, missingDocs } = getDocs({
      documents,
      theme,
      dispatchFn: this.fileFn,
      deleteFn: this.deleteDoc
    })

    const themeTitled = getThemeTitled(theme)
    const status = shipmentStatii[shipment.status]
    const expectedTime = shipment.has_pre_carriage
      ? 'Expected Time of Collection:'
      : 'Expected Time of Departure:'

    const plannedTime = shipment.has_pre_carriage
      ? `${moment(shipment.closing_date)
        .subtract(3, 'days')
        .format('DD/MM/YYYY')}`
      : `${moment(shipment.planned_etd).format('DD/MM/YYYY')}`

    const Terms = getTerms({ theme, terms })
    const HeadingFactory = HeadingFactoryFn(theme)
    const LocationsOrigin = getLocationsOrigin({ shipment, locations })
    const LocationsDestination = getLocationsDestination({ shipment, locations })
    const arrivalTime = getArrivalTime(shipment)
    const totalPrice = getTotalPrice(shipment)

    const ShipmentCard = (
      <div className={SHIPMENT_CARD_CONTAINER}>
        <div style={themeTitled} className={HEADING}>
          {HeadingFactory('Overview')}
          <div className={COLLAPSER} onClick={() => this.setCollapser('overview')}>
            {getChevronIcon(collapser.overview)}
          </div>
        </div>
        <div className={getPanelStyle(collapser.overview)}>
          <div className={INNER_WRAPPER}>

            <div className={INNER_WRAPPER_CELL}>
              <h4 className="flex-none">Shipment Reference:</h4>
              <h4 className="clip flex-none offset-5" style={textStyle}>
                {shipment.imc_reference}
              </h4>
            </div>

            <div className={INNER_WRAPPER_CELL}>
              <p className={SUBTITLE_NORMAL}>Status:</p>
              <p className={SUBTITLE}>
                {status}
              </p>
            </div>

            <div className={INNER_WRAPPER_CELL}>
              <p className={SUBTITLE_NORMAL}>Created at:</p>
              <p className={SUBTITLE}>
                {createdDate}
              </p>
            </div>

          </div>
        </div>
      </div>
    )

    const Itinerary = (
      <div className={ITINERARY}>
        <div style={themeTitled} className={HEADING}>
          {HeadingFactory('Itinerary')}
          <div className={COLLAPSER} onClick={() => this.setCollapser('itinerary')}>
            {getChevronIcon(collapser.itinerary)}
          </div>
        </div>

        <div className={getPanelStyle(collapser.itinerary)}>
          <div className={INNER_WRAPPER}>
            <RouteHubBox hubs={hubsObj} route={schedules} theme={theme} />
            <div
              className={`${ROW(100)} ${ALIGN_BETWEEN_CENTER}`}
              style={{ position: 'relative' }}
            >
              <div className={`flex-40 ${WRAP_ROW()} ${ALIGN_CENTER}`}>
                <div className={`${ROW(100)} ${ALIGN_CENTER_START} layout-wrap`}>
                  <p className="flex-100 center letter_3">
                    {expectedTime}
                  </p>
                  <p className="flex-none letter_3">
                    {plannedTime}
                  </p>
                </div>
                {LocationsOrigin}
              </div>
              <div className={`${WRAP_ROW(40)} ${ALIGN_CENTER}`}>
                <div className={`${ROW(100)} ${ALIGN_CENTER_START} layout-wrap`}>
                  <p
                    className="flex-100 center letter_3"
                  > Expected Time of Arrival:</p>
                  <p className="flex-none letter_3">
                    {arrivalTime}
                  </p>
                </div>
                {LocationsDestination}
              </div>
            </div>
          </div>
        </div>
      </div>
    )

    const FaresAndFees = (
      <div className={SHIPMENT_CARD}>

        <div style={themeTitled} className={HEADING}>
          {HeadingFactory('Fares & Fees')}
          <div className={COLLAPSER} onClick={() => this.setCollapser('charges')}>
            {getChevronIcon(collapser.charges)}
          </div>
        </div>

        <div className={TOTAL_ROW}>
          <h3 className="flex-70 letter_3">Shipment Total:</h3>
          <div className={`${ROW(30)} layout-align-end-center`}>
            <h3 className="flex-none letter_3">
              {totalPrice}
            </h3>
          </div>
        </div>

        <div className={getPanelStyle(collapser.charges)}>
          <div className={INNER_WRAPPER}>
            <div className={`${ROW(100)} ${ALIGN_CENTER}`}>
              <div className={BOOKING}>
                <IncotermRow
                  theme={theme}
                  preCarriage={shipment.has_pre_carriage}
                  onCarriage={shipment.has_on_carriage}
                  originFees={shipment.has_pre_carriage}
                  destinationFees={shipment.has_on_carriage}
                  feeHash={feeHash}
                  tenant={{ data: tenant }}
                />
              </div>
            </div>
          </div>
        </div>

      </div>
    )

    const AdditionalServices = (
      <div className={SHIPMENT_CARD}>

        <div style={themeTitled} className={HEADING}>
          {HeadingFactory('Additional Services')}
          <div className={COLLAPSER} onClick={() => this.setCollapser('extras')}>
            {getChevronIcon(collapser.extras)}
          </div>
        </div>

        <div className={getPanelStyle(collapser.extras)}>
          <div className={INNER_WRAPPER}>
            <div className={`${ROW(100)} ${ALIGN_CENTER}`}>
              <div className={BOOKING}>
                <IncotermExtras
                  theme={theme}
                  feeHash={feeHash}
                  tenant={{ data: tenant }}
                />
              </div>
            </div>
          </div>
        </div>

      </div>
    )

    const ContactDetails = (
      <div className={SHIPMENT_CARD}>

        <div style={themeTitled} className={HEADING} >
          {HeadingFactory('Contact Details')}
          <div className={COLLAPSER} onClick={() => this.setCollapser('contacts')}>
            {getChevronIcon(collapser.contacts)}
          </div>
        </div>

        <div className={getPanelStyle(collapser.contacts)}>
          <div className={INNER_WRAPPER}>
            <div className={SUMM_TOP}>
              {shipperAndConsignee}
            </div>
            <div className={`${WRAP_ROW(100)} ${ALIGN_AROUND_CENTER}`}>
              {' '}
              {notifyeesJSX}{' '}
            </div>
          </div>
        </div>

      </div>
    )

    const CargoDetails = (
      <div className={SHIPMENT_CARD}>

        <div style={themeTitled} className={HEADING} >
          {HeadingFactory('Cargo Details')}
          <div className={COLLAPSER} onClick={() => this.setCollapser('cargo')}>
            {getChevronIcon(collapser.cargo)}
          </div>
        </div>

        <div className={getPanelStyle(collapser.cargo)}>
          <div className={INNER_WRAPPER}>
            <div className={LAYOUT_WRAP}>
              {cargoView}
            </div>
          </div>
        </div>

      </div>
    )

    const AdditionalInformation = (
      <div className={SHIPMENT_CARD}>

        <div style={themeTitled} className={HEADING}>
          {HeadingFactory('Additional Information')}
          <div
            className={`${ROW(10)} ${ALIGN_CENTER}`}
            onClick={() => this.setCollapser('extraInfo')}
          >
            {getChevronIcon(collapser.extraInfo)}
          </div>
        </div>

        <div className={getPanelStyle(collapser.extraInfo)}>
          <div className={INNER_WRAPPER}>
            <div className={LAYOUT_WRAP}>
              <div className={`${ROW(100)} ${ALIGN_START_CENTER}`}>
                {TotalGoodsValue(shipment)}
                {Eori(shipment)}
              </div>
              <div className={`${ROW(100)} ${ALIGN_AROUND_CENTER}`}>
                {DescriptionGoods(shipment)}
                {Notes(shipment)}
                {Incoterm(shipment)}
              </div>
            </div>
          </div>
        </div>

      </div>
    )

    const Documents = (
      <div className={SHIPMENT_CARD}>

        <div style={themeTitled} className={HEADING}>
          {HeadingFactory('Documents')}
          <div className={COLLAPSER} onClick={() => this.setCollapser('documents')}>
            {getChevronIcon(collapser.documents)}
          </div>
        </div>

        <div className={getPanelStyle(collapser.documents)}>
          <div className={INNER_WRAPPER}>
            <div className={LAYOUT_WRAP}>
              {docView}
            </div>
            <div className={LAYOUT_WRAP}>
              {missingDocs}
            </div>
          </div>
        </div>

      </div>
    )

    const AgreeAndSubmit = (
      <div className={SHIPMENT_CARD}>
        <div className={LAYOUT_WRAP}>

          <div style={themeTitled} className={HEADING}>
            {HeadingFactory('Agree and Submit')}
          </div>

          <div className={CHECKBOX}>
            <div className={CHECKBOX_CELL}>
              <Checkbox
                onChange={this.toggleAcceptTerms}
                checked={this.state.acceptTerms}
                theme={theme}
              />
            </div>
            {Terms}
          </div>

          <div className={ACCEPT} style={acceptStyle}>
            {acceptTerms ? acceptedBtn : nonAcceptedBtn}
          </div>

        </div>
      </div>
    )

    return (
      <div className={CONTAINER}>
        <div className={AFTER_CONTAINER}>
          {ShipmentCard}

          {Itinerary}

          {FaresAndFees}

          {AdditionalServices}

          {ContactDetails}

          {CargoDetails}

          {AdditionalInformation}

          {Documents}

          {AgreeAndSubmit}

          <hr className={`${styles.sec_break} flex-100`} />

          <div className={BACK_TO_DASHBOARD}>
            <div className={BACK_TO_DASHBOARD_CELL}>
              <RoundButton
                theme={theme}
                text="Back to dashboard"
                back
                iconClass="fa-angle-left"
                handleNext={shipmentDispatch.toDashboard}
              />
            </div>
          </div>

        </div>
      </div>
    )
  }
}

function prepContainerGroups (cargos, props) {
  const uniqCargos = uniqWith(
    cargos,
    (x, y) => x.id === y.id
  )
  const cargoGroups = {}

  uniqCargos.forEach((singleCargo, i) => {
    const parsedPayload = parseFloat(singleCargo.payload_in_kg)
    const parsedQuantity = parseInt(singleCargo.quantity, 10)
    const payload = parsedPayload * parsedQuantity

    const parsedTare = parseFloat(singleCargo.tare_weight)
    const tare = parsedTare * parsedQuantity

    const parsedGross = parseFloat(singleCargo.gross_weight)
    const gross = parsedGross * parsedQuantity

    const base = pick(
      singleCargo,
      ['size_class', 'quantity']
    )

    cargoGroups[singleCargo.id] = {
      ...base,
      cargo_group_id: singleCargo.id,
      gross_weight: gross,
      groupAlias: i + 1,
      hsCodes: singleCargo.hs_codes,
      hsText: singleCargo.customs_text,
      items: [],
      payload_in_kg: payload,
      tare_weight: tare
    }
  })

  return Object.keys(cargoGroups).map(prop =>
    (<CargoContainerGroup
      group={cargoGroups[prop]}
      theme={props.theme}
      hsCodes={props.shipmentData.hsCodes}
    />))
}

function prepCargoItemGroups (cargos, props) {
  const { cargoItemTypes, hsCodes } = props.shipmentData
  const uniqCargos = uniqWith(
    cargos,
    (x, y) => x.id === y.id
  )
  const cargoGroups = {}

  uniqCargos.forEach((singleCargo, i) => {
    const parsedQuantity = parseInt(singleCargo.quantity, 10)
    const parsedX = parseFloat(singleCargo.dimension_x)
    const parsedY = parseFloat(singleCargo.dimension_y)
    const parsedZ = parseFloat(singleCargo.dimension_z)
    const parsedPayload = parseFloat(singleCargo.payload_in_kg)
    const parsedChargable = parseFloat(singleCargo.chargeable_weight)

    const x = parsedX * parsedQuantity
    const y = parsedY * parsedQuantity
    const z = parsedZ * parsedQuantity
    const payload = parsedPayload * parsedQuantity
    const chargable = parsedChargable * parsedQuantity

    const volume = parsedY * parsedX * parsedY / 1000000 * parsedQuantity
    const cargoType = cargoItemTypes[singleCargo.cargo_item_type_id]
    const items = Array(parsedQuantity).fill(singleCargo)

    cargoGroups[singleCargo.id] = {
      cargoType,
      cargo_group_id: singleCargo.id,
      chargeable_weight: chargable,
      dimension_x: x,
      dimension_y: y,
      dimension_z: z,
      groupAlias: i + 1,
      hsCodes: singleCargo.hs_codes,
      hsText: singleCargo.hs_text,
      items,
      payload_in_kg: payload,
      quantity: singleCargo.quantity,
      volume
    }
  })

  return Object.keys(cargoGroups).map(prop =>
    (<CargoItemGroup
      group={cargoGroups[prop]}
      theme={props.theme}
      hsCodes={hsCodes}
    />))
}

function getDocs ({
  documents,
  theme,
  dispatchFn,
  deleteFn
}) {
  const docChecker = {
    packing_sheet: false,
    commercial_invoice: false,
    customs_declaration: false,
    customs_value_declaration: false,
    eori: false,
    certificate_of_origin: false,
    dangerous_goods: false,
    bill_of_lading: false,
    invoice: false
  }
  const docView = []
  const missingDocs = []

  if (documents) {
    documents.forEach((doc) => {
      docChecker[doc.doc_type] = true

      docView.push(<div className={ROW(45)} style={{ padding: '10px' }}>
        <DocumentsForm
          theme={theme}
          type={doc.doc_type}
          dispatchFn={dispatchFn}
          text={documentTypes[doc.doc_type]}
          doc={doc}
          viewer
          deleteFn={deleteFn}
        />
      </div>)
    })
  }

  Object.keys(docChecker).forEach((key) => {
    if (!docChecker[key]) {
      missingDocs.push(<div className={MISSING_DOCS}>
        <div className={`flex-none layout-row ${ALIGN_CENTER}`}>
          <i className="flex-none fa fa-ban" />
        </div>
        <div className="flex layout-align-start-center layout-row">
          <p className="flex-none">{`${documentTypes[key]}: Not Uploaded`}</p>
        </div>
      </div>)
    }
  })

  return { missingDocs, docView }
}

function getDefaultTerms (tenant) {
  return [
    'You verify that all the information provided above is true',
    // eslint-disable-next-line
    `You agree to our Terms and Conditions and the General Conditions of the
                        Nordic Association of Freight Forwarders (NSAB) and those of 
                        {tenant.name}`,
    // eslint-disable-next-line
    'You agree to pay the price of the shipment as stated above upon arrival of the invoice'
  ]
}

function getTenantTerms (tenant) {
  const defaultTerms = getDefaultTerms(tenant)

  return tenant.scope.terms.length > 0 ? tenant.scope.terms : defaultTerms
}

function getTextStyle (theme) {
  return theme
    ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
    : { color: 'black' }
}

function getCreatedDate (shipment) {
  return shipment
    ? moment(shipment.updated_at).format('DD-MM-YYYY | HH:mm A')
    : moment().format('DD-MM-YYYY | HH:mm A')
}

function getThemeTitled (theme) {
  return theme && theme.colors
    ? { background: theme.colors.primary, color: 'white' }
    : { background: 'rgba(0,0,0,0.25)', color: 'white' }
}

function getNotifyeesJSX ({ notifyees, textStyle }) {
  if (!notifyees) {
    return []
  }

  const notifyeesJSX = notifyees.map(notifyee => (
    <div key={v4()} className={ROW(40)}>
      <div className={`${COLUMN_15} ${ALIGN_START_CENTER}`}>
        <i
          className={`${styles.icon} fa fa-envelope-open-o flex-none`}
          style={textStyle}
        />
      </div>
      <div className={`${WRAP_ROW(85)} ${ALIGN_START}`}>
        <div className="flex-100">
          <h3 style={{ fontWeight: 'normal' }}>Notifyee</h3>
        </div>
        <p style={{ marginTop: 0 }}>
          {notifyee.first_name} {notifyee.last_name}
        </p>
      </div>
    </div>
  ))

  if (notifyeesJSX.length % 2 === 1) {
    notifyeesJSX.push(<div className="flex-40" />)
  }

  return notifyeesJSX
}

function getAcceptedBtn ({ theme, handleNext }) {
  return (
    <div className={BUTTON}>
      <RoundButton
        theme={theme}
        text="Finish Booking Request"
        handleNext={handleNext}
        active
      />
    </div>
  )
}

function getNonAcceptedBtn (theme) {
  return (
    <div className={BUTTON}>
      <RoundButton
        theme={theme}
        text="Finish Booking Request"
        handleNext={e => e.preventDefault()}
      />
    </div>
  )
}

function getShipperAndConsignee ({
  shipper,
  consignee,
  textStyle,
  shipment
}) {
  const els = [
    <Contact contact={shipper} contactType="Shipper" textStyle={textStyle} />,
    <Contact contact={consignee} contactType="Consignee" textStyle={textStyle} />
  ]

  if (shipment.direction === 'import') {
    els.reverse()
  }

  return els
}

function getTerms ({ theme, terms }) {
  const termBullets = terms.map(singleTerm => <li> {singleTerm}</li>)

  return (
    <div className={`${ROW()} ${ALIGN_START_CENTER}`}>
      <div className="flex-5" />
      <div className={`${WRAP_ROW(95)} ${ALIGN_START_CENTER}`}>
        <div className={`${ROW(100)} ${ALIGN_START_CENTER}`}>
          <TextHeading theme={theme} text="By checking this box" size={4} />
        </div>
        <div className={`${ROW(100)} ${ALIGN_START}`}>
          <ul className={`flex-100 ${styles.terms_list}`}>{termBullets}</ul>
        </div>
      </div>
    </div>
  )
}

function getLocationsDestination ({ shipment, locations }) {
  return shipment.has_on_carriage ? (
    <div className={`${ROW(100)} ${ALIGN_START}`}>
      <address className="flex-none">
        {/* eslint-disable-next-line */}
        {`${locations.destination.street_number} ${locations.destination.street}`}{' '}
        <br />
        {`${locations.destination.city}`} <br />
        {`${locations.destination.zip_code}`} <br />
        {`${locations.destination.country}`} <br />
      </address>
    </div>
  ) : (
    ''
  )
}

function getLocationsOrigin ({ shipment, locations }) {
  return shipment.has_pre_carriage ? (
    <div className={`${ROW(100)} ${ALIGN_START}`}>
      <address className="flex-none">
        {`${locations.origin.street_number} ${locations.origin.street}`} <br />
        {`${locations.origin.city}`} <br />
        {`${locations.origin.zip_code}`} <br />
        {`${locations.origin.country}`} <br />
      </address>
    </div>
  ) : (
    ''
  )
}

function getChevronIcon (flag) {
  return flag
    ? <i className="fa fa-chevron-down pointy" />
    : <i className="fa fa-chevron-up pointy" />
}

function getPanelStyle (flag) {
  return `${flag ? styles.collapsed : ''} ${styles.main_panel}`
}

function getArrivalTime (shipment) {
  const format = 'DD/MM/YYYY | HH:mm'

  return `${moment(shipment.planned_eta).format(format)}`
}

function getTotalPrice (shipment) {
  const { currency } = shipment.total_price
  const price = parseFloat(shipment.total_price.value).toFixed(2)

  return `${currency} ${price} `
}

function TotalGoodsValue (shipment) {
  return shipment.total_goods_value ? (
    <div className={`${WRAP_ROW(45)} offset-5 ${ALIGN_START}`}>
      <p className="flex-100">
        <b>Total Value of Goods:</b>
      </p>
      <p className="flex-100 no_m">{`${shipment.total_goods_value.currency} ${
        shipment.total_goods_value.value
      }`}</p>
    </div>
  ) : (
    ''
  )
}

function Eori (shipment) {
  return shipment.eori ? (
    <div className={`${WRAP_ROW(45)} offset-10 ${ALIGN_START}`}>
      <p className="flex-100">
        <b>EORI number:</b>
      </p>
      <p className="flex-100 no_m">{shipment.eori}</p>
    </div>
  ) : (
    ''
  )
}

function DescriptionGoods (shipment) {
  return shipment.cargo_notes ? (
    <div className={`${WRAP_ROW(45)} offset-5 ${ALIGN_START}`}>
      <p className="flex-100">
        <b>Description of Goods:</b>
      </p>
      <p className="flex-100 no_m">{shipment.cargo_notes}</p>
    </div>
  ) : (
    ''
  )
}

function Notes (shipment) {
  return shipment.notes ? (
    <div className={`${WRAP_ROW(45)} offset-5 ${ALIGN_START}`}>
      <p className="flex-100">
        <b>Notes:</b>
      </p>
      <p className="flex-100 no_m">{shipment.notes}</p>
    </div>
  ) : (
    ''
  )
}

function Incoterm (shipment) {
  return shipment.incoterm_text ? (
    <div className={`${WRAP_ROW(45)} offset-5 ${ALIGN_START}`}>
      <p className="flex-100">
        <b>Incoterm:</b>
      </p>
      <p className="flex-100 no_m">{shipment.incoterm_text}</p>
    </div>
  ) : (
    ''
  )
}

function HeadingFactoryFn (theme) {
  return text => (
    <TextHeading
      theme={theme}
      color="white"
      size={3}
      text={text}
    />
  )
}

export default BookingConfirmation
