/* eslint react/prop-types: "off" */
import React, { Component } from 'react'
import { v4 } from 'uuid'
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
import DocumentsForm from '../Documents/Form'
import Contact from '../Contact/Contact'
import { IncotermRow } from '../Incoterm/Row'
import { IncotermExtras } from '../Incoterm/Extras'

import {
  ALIGN_AROUND_CENTER,
  ALIGN_AROUND_STRETCH,
  ALIGN_BETWEEN_CENTER,
  ALIGN_BETWEEN_START,
  ALIGN_END_CENTER,
  ALIGN_CENTER,
  ALIGN_CENTER_START,
  ALIGN_END,
  ALIGN_START,
  ALIGN_START_CENTER,
  COLUMN_15,
  ROW,
  WRAP_ROW
} from '../../classNames'
import { CargoContainerGroup } from '../Cargo/Container/Group'

const ACCEPT = `${ROW(33)} ${ALIGN_END} height_100`

const AFTER_CONTAINER =
  `${WRAP_ROW('NONE')} ${ALIGN_CENTER_START} content_width_booking`

const BACK_TO_DASHBOARD =
  `${styles.back_to_dash_sec} ${WRAP_ROW(100)} layout-align-center`

const BACK_TO_DASHBOARD_CELL =
  `${defaults.content_width} flex-none ${ROW('CONTENT')} ${ALIGN_START_CENTER}`
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

const ITINERARY =
  `${styles.shipment_card_itinerary} ${WRAP_ROW(100)} ${ALIGN_BETWEEN_CENTER}`
const LAYOUT_WRAP = `${WRAP_ROW(100)} ${ALIGN_START_CENTER}`
const MISSING_DOCS = `${ROW(25)} ${ALIGN_START_CENTER} ${styles.no_doc}`

const SHIPMENT_CARD = `${styles.shipment_card} ${WRAP_ROW(100)} ${ALIGN_BETWEEN_CENTER}`

const SHIPMENT_CARD_CONTAINER =
  `${styles.shipment_card} ${WRAP_ROW(100)} ${ALIGN_BETWEEN_CENTER}`
const SUBTITLE = `${styles.sec_subtitle_text} flex-none offset-5`
const SUBTITLE_NORMAL = `${styles.sec_subtitle_text_normal} flex-none`
const SUMM_TOP = `${styles.b_summ_top} ${ROW(100)} ${ALIGN_AROUND_STRETCH}`
const TOTAL_ROW = `${styles.total_row} ${WRAP_ROW(100)} ${ALIGN_AROUND_CENTER}`

const acceptStyle = { height: '150px', marginBottom: '15px' }

export function calcFareTotals (feeHash) {
  if (!feeHash) return 0

  const total = feeHash.total && +feeHash.total.value

  return Object.keys(feeHash).reduce((sum, k) => (
    feeHash[k] && ['customs', 'insurance']
      .includes(k) && feeHash[k].total ? sum - feeHash[k].total.value : sum
  ), total).toFixed(2)
}
export function calcExtraTotals (feeHash) {
  let res1 = 0
  if (feeHash &&
    feeHash.customs &&
    feeHash.customs &&
    feeHash.customs.total &&
    feeHash.customs.total.value) {
    res1 += parseFloat(feeHash.customs.total.value)
  }
  if (feeHash &&
    feeHash.insurance &&
    feeHash.insurance.total &&
    feeHash.insurance.total.value) {
    res1 += parseFloat(feeHash.insurance.total.value)
  }

  return res1.toFixed(2)
}

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
  handleCollapser (key) {
    this.setState({
      collapser: {
        ...this.state.collapser,
        [key]: !this.state.collapser[key]
      }
    })
  }
  requestShipment () {
    const { shipmentData, shipmentDispatch } = this.props
    const { shipment } = shipmentData
    shipmentDispatch.requestShipment(shipment.id)
  }
  fileFn (file) {
    const { shipmentData, shipmentDispatch } = this.props
    const { shipment } = shipmentData
    const type = file.doc_type
    const url = `/shipments/${shipment.id}/upload/${type}`
    shipmentDispatch.uploadDocument(file, type, url)
  }
  deleteDoc (doc) {
    const { shipmentDispatch } = this.props
    shipmentDispatch.deleteDocument(doc.id)
  }
  toggleAcceptTerms () {
    this.setState({ acceptTerms: !this.state.acceptTerms })
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
      shipment,
      shipper
    } = shipmentData

    if (!shipment || !locations || !cargoItemTypes) return <h1> Loading</h1>

    const { acceptTerms, collapser } = this.state
    const terms = getTenantTerms(tenant)
    const textStyle = getTextStyle(theme)
    const createdDate = getCreatedDate(shipment)

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
    const feeHash = shipment.selected_offer

    const acceptedBtn = (
      <div className={BUTTON}>
        <RoundButton
          theme={theme}
          text="Finish Booking Request"
          handleNext={() => this.requestShipment()}
          active
        />
      </div>
    )
    const nonAcceptedBtn = (
      <div className={BUTTON}>
        <RoundButton
          theme={theme}
          text="Finish Booking Request"
          handleNext={e => e.preventDefault()}
        />
      </div>
    )

    const themeTitled = getThemeTitled(theme)
    const { docView, missingDocs } = getDocs({
      documents,
      theme,
      dispatchFn: this.fileFn,
      deleteFn: this.deleteDoc
    })

    const HeadingFactory = HeadingFactoryFn(theme)
    const Terms = getTerms({ theme, terms })
    const LocationsOrigin = getLocationsOrigin({ shipment, locations })
    const LocationsDestination = getLocationsDestination({ shipment, locations })
    const arrivalTime = getArrivalTime(shipment)
    const totalPrice = getTotalPrice(shipment)
    const status = shipmentStatii[shipment.status]

    const expectedTime = shipment.has_pre_carriage
      ? 'Expected Time of Collection:'
      : 'Expected Time of Departure:'

    const plannedTime = shipment.has_pre_carriage
      ? `${moment(shipment.closing_date)
        .subtract(3, 'days')
        .format('DD/MM/YYYY')}`
      : `${moment(shipment.planned_etd).format('DD/MM/YYYY')}`

    const ShipmentCard = (
      <div className={SHIPMENT_CARD_CONTAINER}>
        <div style={themeTitled} className={HEADING}>
          {HeadingFactory('Overview')}
          <div className={COLLAPSER} onClick={() => this.handleCollapser('overview')}>
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
          <div className={COLLAPSER} onClick={() => this.handleCollapser('itinerary')}>
            {getChevronIcon(collapser.itinerary)}
          </div>
        </div>

        <div className={getPanelStyle(collapser.itinerary)}>
          <div className={INNER_WRAPPER}>
            <RouteHubBox shipment={shipment} theme={theme} />
            <div
              className={`${ROW(100)} ${ALIGN_BETWEEN_CENTER}`}
              style={{ position: 'relative' }}
            >
              <div className={`flex-40 ${WRAP_ROW()} ${ALIGN_CENTER}`}>
                <div className={`${WRAP_ROW(80)} ${ALIGN_START}`}>
                  <p className="flex-100 letter_3">
                    {expectedTime}
                  </p>
                  <p className="flex-90 offset-10 margin_5">
                    {plannedTime}
                  </p>
                </div>
                {LocationsOrigin}
              </div>

              <div className={`${WRAP_ROW(40)} ${ALIGN_CENTER}`}>
                <div className={`${WRAP_ROW(80)} ${ALIGN_START}`}>
                  <p className="flex-100 letter_3"> Expected Time of Arrival:</p>
                  <p className="flex-90 offset-10 margin_5">{arrivalTime}</p>
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
          <div className={COLLAPSER} onClick={() => this.handleCollapser('charges')}>
            {getChevronIcon(collapser.charges)}
          </div>
        </div>

        <div className={getPanelStyle(collapser.charges)}>
          <div className={INNER_WRAPPER}>
            <div className={`${WRAP_ROW(100)} ${ALIGN_CENTER}`}>
              <div className={`${ROW(100)} ${ALIGN_START_CENTER}`}>
                <div className={`${ROW(70)} ${ALIGN_START_CENTER}`}>
                  <TextHeading
                    theme={theme}
                    color="white"
                    size={4}
                    text="Freight, Duties & Carriage: "
                  />
                </div>
                <div className={`${ROW(30)} ${ALIGN_END_CENTER}`}>
                  <h5 className="flex-none letter_3">
                    {`${shipment.total_price.currency} ${calcFareTotals(feeHash)}`}
                  </h5>
                </div>
              </div>
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
            <div className={`${WRAP_ROW(100)} ${ALIGN_CENTER}`}>
              <div className={`${ROW(100)} ${ALIGN_START_CENTER}`}>
                <div className={`${ROW(70)} ${ALIGN_START_CENTER}`}>
                  <TextHeading
                    theme={theme}
                    color="white"
                    size={4}
                    text="Additional Services: "
                  />
                </div>
                <div className={`${WRAP_ROW(30)} ${ALIGN_END_CENTER}`}>
                  <h5 className="flex-none letter_3">{`${
                    shipment.total_price.currency
                  } ${calcExtraTotals(feeHash)} `}</h5>
                  { feeHash.customs && feeHash.customs.hasUnknown && (
                    <div className={`${ROW(100)} ${ALIGN_END_CENTER}`}>
                      <p className="flex-none center no_m" style={{ fontSize: '10px' }}>
                            ( excl. charges subject to local regulations )
                      </p>
                    </div>
                  )}
                </div>
              </div>

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
        <div className={TOTAL_ROW}>
          <div className={`${ROW(70)} ${ALIGN_START_CENTER}`}>
            <h3 className="flex-none letter_3">Shipment Total: </h3>
          </div>
          <div className={`${WRAP_ROW(30)} ${ALIGN_END_CENTER}`}>
            <h3 className="flex-none letter_3">{totalPrice}</h3>
            <div className={`${ROW(100)} ${ALIGN_END_CENTER}`}>
              <p className="flex-none center no_m" style={{ fontSize: '12px' }}>
                {' '}
                    ( incl. Quoted Additional Services )
              </p>
            </div>
          </div>
        </div>
      </div>
    )

    const ContactDetails = (
      <div className={SHIPMENT_CARD}>
        <div style={themeTitled} className={HEADING}>
          {HeadingFactory('Contact Details')}
          <div
            className={`${ROW(10)} ${ALIGN_CENTER}`}
            onClick={() => this.handleCollapser('contacts')}
          >
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
          <div className={COLLAPSER} onClick={() => this.handleCollapser('cargo')}>
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
            onClick={() => this.handleCollapser('extraInfo')}
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

                {shipment.cargo_notes ? (
                  <div className={`${WRAP_ROW(45)} offset-5 ${ALIGN_START}`}>
                    <p className="flex-100">
                      <b>Description of Goods:</b>
                    </p>
                    <p className="flex-100 no_m">{shipment.cargo_notes}</p>
                  </div>
                ) : (
                  ''
                )}
                {shipment.notes ? (
                  <div className={`${WRAP_ROW(45)} offset-5 ${ALIGN_START}`}>
                    <p className="flex-100">
                      <b>Notes:</b>
                    </p>
                    <p className="flex-100 no_m">{shipment.notes}</p>
                  </div>
                ) : (
                  ''
                )}
                {shipment.incoterm_text ? (
                  <div className={`${WRAP_ROW(45)} offset-5 ${ALIGN_START}`}>
                    <p className="flex-100">
                      <b>Incoterm:</b>
                    </p>
                    <p className="flex-100 no_m">{shipment.incoterm_text}</p>
                  </div>
                ) : (
                  ''
                )}
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
          <div className={COLLAPSER} onClick={() => this.handleCollapser('documents')}>
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
                handleNext={() => shipmentDispatch.toDashboard()}
              />
            </div>
          </div>
        </div>
      </div>
    )
  }
}

function prepContainerGroups (cargos, props) {
  const { hsCodes, shipment } = props.shipmentData
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
    const items = Array(parsedQuantity).fill(singleCargo)
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
      items,
      payload_in_kg: payload,
      tare_weight: tare
    }
  })

  return Object.keys(cargoGroups).map(prop =>
    (<CargoContainerGroup
      key={v4()}
      group={cargoGroups[prop]}
      theme={props.theme}
      hsCodes={hsCodes}
      shipment={shipment}
    />))
}

function prepCargoItemGroups (cargos, props) {
  const { cargoItemTypes, hsCodes, shipment } = props.shipmentData
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
      key={v4()}
      group={cargoGroups[prop]}
      theme={props.theme}
      hsCodes={hsCodes}
      shipment={shipment}
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
      missingDocs.push(<div key={v4()} className={MISSING_DOCS}>
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
    `You agree to our Terms and Conditions and the General Conditions of the
                        Nordic Association of Freight Forwarders (NSAB) and those of 
                        {tenant.name}`,
    `You agree to pay the price of the
    shipment as stated above upon arrival of the invoice`
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

function getShipperAndConsignee ({
  shipper,
  consignee,
  textStyle,
  shipment
}) {
  const els = [
    <Contact key={v4()} contact={shipper} contactType="Shipper" textStyle={textStyle} />,
    <Contact
      key={v4()}
      contact={consignee}
      contactType="Consignee"
      textStyle={textStyle}
    />
  ]

  if (shipment.direction === 'import') {
    els.reverse()
  }

  return els
}

function getTerms ({ theme, terms }) {
  const termBullets = terms.map(t => <li key={v4()}> {t}</li>)

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
        {`${locations.destination.street_number} ${locations.destination.street}`}{' '}
        ,
        {`${locations.destination.city}`},
        {`${locations.destination.zip_code}`},
        {`${locations.destination.country}`}
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
        {`${locations.origin.street_number} ${locations.origin.street}`},
        {`${locations.origin.city}`},
        {`${locations.origin.zip_code}`},
        {`${locations.origin.country}`}
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
      <p className="flex-100 no_m">{`${
        shipment.total_goods_value.currency
      } ${parseFloat(shipment.total_goods_value.value).toFixed(2)}`}</p>
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
