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
  ALIGN_BETWEEN,
  ALIGN_CENTER,
  ALIGN_CENTER_START,
  ALIGN_START,
  ALIGN_START_CENTER,
  ROW_100,
  ALIGN_END,
  ROW_CONTENT,
  ROW_NONE,
  WRAP_ROW,
  WRAP_START
} from '../../classNames'

const ACCEPT = 'flex-33 layout-row layout-align-end-end height_100'
const AFTER_CONTAINER = `flex-none ${WRAP_ROW} ${ALIGN_CENTER_START} content_width_booking`
const BACK_TO_DASHBOARD = `${styles.back_to_dash_sec} flex-100 ${WRAP_ROW} layout-align-center`
const BACK_TO_DASHBOARD_CELL = `${defaults.content_width} flex-none ${ROW_CONTENT} ${ALIGN_START_CENTER}`
const BOOKING = `flex-none content_width_booking layout-row ${ALIGN_CENTER}`
const BUTTON = `${ROW_NONE} ${ALIGN_END}`
const CHECKBOX = 'flex-65 layout-row layout-align-start-center'
const CHECKBOX_CELL = `flex-15 layout-row ${ALIGN_CENTER}`
const COLLAPSER = `flex-10 layout-row ${ALIGN_CENTER}`
const CONTAINER = `flex-100 ${WRAP_ROW} ${ALIGN_CENTER_START}`
const HEADING = `${styles.heading_style} ${ROW_100} ${ALIGN_BETWEEN}`
const INNER_WRAPPER = `${styles.inner_wrapper} flex-100 ${WRAP_ROW} layout-align-start-start`
const INNER_WRAPPER_CELL = `${ROW_100} layout-wrap layout-align-space-between-start`
const ITINERARY = `${styles.shipment_card_itinerary} ${ROW_100} ${ALIGN_BETWEEN} layout-wrap`
const LAYOUT_WRAP = `flex-100 ${WRAP_ROW} layout-align-start-center`
const MISSING_DOCS = `flex-25 layout-row layout-align-start-center ${styles.no_doc}`
const SHIPMENT_CARD = `${styles.shipment_card} ${ROW_100} ${ALIGN_BETWEEN} layout-wrap`
const SHIPMENT_CARD_CONTAINER = `${styles.shipment_card} ${ROW_100} ${ALIGN_BETWEEN} layout-wrap`
const SUBTITLE = `${styles.sec_subtitle_text} flex-none offset-5`
const SUBTITLE_NORMAL = `${styles.sec_subtitle_text_normal} flex-none`
const SUMM_TOP = `${styles.b_summ_top} flex-100 layout-row layout-align-space-around-stretch`
const TOTAL_ROW = `${styles.total_row} flex-100 ${WRAP_ROW} layout-align-space-around-center`

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
  toggleAcceptTerms () {
    this.setState({ acceptTerms: !this.state.acceptTerms })
  }
  deleteDoc (doc) {
    this.props.shipmentDispatch.deleteDocument(doc.id)
  }
  requestShipment () {
    this.props.shipmentDispatch.requestShipment(this.props.shipmentData.shipment.id)
  }
  fileFn (file) {
    const { shipmentData, shipmentDispatch } = this.props
    const { shipment } = shipmentData
    const type = file.doc_type
    const url = `/shipments/${shipment.id}/upload/${type}`

    shipmentDispatch.uploadDocument(file, type, url)
  }
  collapser (key) {
    this.setState({
      collapser: {
        ...this.state.collapser,
        [key]: !this.state.collapser[key]
      }
    })
  }
  render () {
    const {
      theme,
      shipmentData,
      shipmentDispatch,
      tenant
    } = this.props

    if (!shipmentData) {
      return <h1>Loading</h1>
    }

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

    if (!shipment || !locations || !cargoItemTypes) {
      return <h1> Loading</h1>
    }

    const { acceptTerms, collapser } = this.state
    const hubsObj = { startHub: locations.startHub, endHub: locations.endHub }

    const terms = getTerms(tenant)
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

    const TextHeadingFactory = TextHeadingFactoryFn(theme)
    const Terms = TermsFactory({ theme, terms })
    const LocationsOrigin = LocationsOriginFactory({ shipment, locations })
    const LocationsDestination = LocationsDestinationFactory({ shipment, locations })

    const arrivalTime = `${moment(shipment.planned_eta).format('DD/MM/YYYY | HH:mm')}`
    const totalPrice = getTotalPrice(shipment)

    return (
      <div className={CONTAINER}>
        <div className={AFTER_CONTAINER}>
          <div className={SHIPMENT_CARD_CONTAINER}>

            <div style={themeTitled} className={HEADING}>
              {TextHeadingFactory('Overview')}
              <div className={COLLAPSER} onClick={() => this.collapser('overview')}>
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

          <div className={ITINERARY}>

            <div style={themeTitled} className={HEADING}>
              {TextHeadingFactory('Itinerary')}
              <div className={COLLAPSER} onClick={() => this.collapser('itinerary')}>
                {getChevronIcon(collapser.itinerary)}
              </div>
            </div>

            <div className={getPanelStyle(collapser.itinerary)}>
              <div className={INNER_WRAPPER}>

                <RouteHubBox hubs={hubsObj} route={schedules} theme={theme} />

                <div
                  className={`${ROW_100} ${ALIGN_BETWEEN}`}
                  style={{ position: 'relative' }}
                >

                  <div className={`flex-40 ${WRAP_ROW} ${ALIGN_CENTER}`}>
                    <div className={`${ROW_100} ${ALIGN_CENTER_START} layout-wrap`}>
                      <p className="flex-100 center letter_3">
                        {expectedTime}
                      </p>
                      <p className="flex-none letter_3">
                        {plannedTime}
                      </p>
                    </div>
                    {LocationsOrigin}
                  </div>

                  <div className={`flex-40 ${WRAP_ROW} ${ALIGN_CENTER}`}>
                    <div className={`${ROW_100} ${ALIGN_CENTER_START} layout-wrap`}>
                      <p className="flex-100 center letter_3"> Expected Time of Arrival:</p>
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

          <div className={SHIPMENT_CARD}>

            <div style={themeTitled} className={HEADING}>
              {TextHeadingFactory('Fares & Fees')}
              <div className={COLLAPSER} onClick={() => this.collapser('charges')}>
                {getChevronIcon(collapser.charges)}
              </div>
            </div>

            <div className={TOTAL_ROW}>
              <h3 className="flex-70 letter_3">Shipment Total:</h3>
              <div className="flex-30 layout-row layout-align-end-center">
                <h3 className="flex-none letter_3">
                  {totalPrice}
                </h3>
              </div>
            </div>

            <div className={getPanelStyle(collapser.charges)}>
              <div className={INNER_WRAPPER}>
                <div className={`${ROW_100} ${ALIGN_CENTER}`}>
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

          <div className={SHIPMENT_CARD}>

            <div style={themeTitled} className={HEADING}>
              {TextHeadingFactory('Additional Services')}
              <div className={COLLAPSER} onClick={() => this.collapser('extras')}>
                {getChevronIcon(collapser.extras)}
              </div>
            </div>

            <div className={getPanelStyle(collapser.extras)}>
              <div className={INNER_WRAPPER}>
                <div className={`${ROW_100} ${ALIGN_CENTER}`}>
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

          <div className={SHIPMENT_CARD}>

            <div style={themeTitled} className={HEADING} >
              {TextHeadingFactory('Contact Details')}
              <div className={COLLAPSER} onClick={() => this.collapser('contacts')}>
                {getChevronIcon(collapser.contacts)}
              </div>
            </div>

            <div className={getPanelStyle(collapser.contacts)}>
              <div className={INNER_WRAPPER}>
                <div className={SUMM_TOP}>
                  {shipperAndConsignee}
                </div>
                <div className={`${ROW_100} layout-align-space-around-center layout-wrap`}>
                  {' '}
                  {notifyeesJSX}{' '}
                </div>
              </div>
            </div>

          </div>

          <div className={SHIPMENT_CARD}>
            <div style={themeTitled} className={HEADING} >
              {TextHeadingFactory('Cargo Details')}
              <div className={COLLAPSER} onClick={() => this.collapser('cargo')}>
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

          <div className={SHIPMENT_CARD}>
            <div style={themeTitled} className={HEADING}>
              {TextHeadingFactory('Additional Information')}
              <div
                className={`flex-10 layout-row ${ALIGN_CENTER}`}
                onClick={() => this.collapser('extraInfo')}
              >
                {getChevronIcon(collapser.extraInfo)}
              </div>
            </div>

            <div className={getPanelStyle(collapser.extraInfo)}>
              <div className={INNER_WRAPPER}>

                <div className={LAYOUT_WRAP}>
                  <div className="flex-100 layout-row layout-align-start-center">
                    {TotalGoodsValue(shipment)}
                    {Eori(shipment)}
                  </div>

                  <div className="flex-100 layout-row layout-align-space-around-center">
                    {DescriptionGoods(shipment)}
                    {Notes(shipment)}
                    {Incoterm(shipment)}
                  </div>
                </div>

              </div>
            </div>

          </div>

          <div className={SHIPMENT_CARD}>

            <div style={themeTitled} className={HEADING}>
              {TextHeadingFactory('Documents')}
              <div className={COLLAPSER} onClick={() => this.collapser('documents')}>
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

          <div className={SHIPMENT_CARD}>
            <div className={LAYOUT_WRAP}>

              <div style={themeTitled} className={HEADING}>
                {TextHeadingFactory('Agree and Submit')}
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

      docView.push(<div className="flex-45 layout-row" style={{ padding: '10px' }}>
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
    `You agree to our Terms and Conditions and the General Conditions of the
                        Nordic Association of Freight Forwarders (NSAB) and those of 
                        {tenant.name}`,
    'You agree to pay the price of the shipment as stated above upon arrival of the invoice'
  ]
}

function getTerms (tenant) {
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

function getTermBullets (terms) {
  return terms.map(singleTerm => <li> {singleTerm}</li>)
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

  const notifyeesJSX = notifyees.map(singleNotifyee => (
    <div key={v4()} className="flex-40 layout-row">
      <div className="flex-15 layout-column layout-align-start-center">
        <i className={`${styles.icon} fa fa-envelope-open-o flex-none`} style={textStyle} />
      </div>
      <div className="flex-85 layout-row layout-wrap layout-align-start-start">
        <div className="flex-100">
          <h3 style={{ fontWeight: 'normal' }}>Notifyee</h3>
        </div>
        <p style={{ marginTop: 0 }}>
          {singleNotifyee.first_name} {singleNotifyee.last_name}
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

function TextHeadingFactoryFn (theme) {
  return text => <TextHeading theme={theme} color="white" size={3} text={text} />
}

function TermsFactory ({ theme, terms }) {
  const termBullets = getTermBullets(terms)

  return (
    <div className="flex layout-row layout-align-start-center">
      <div className="flex-5" />
      <div className="flex-95 layout-row layout-wrap layout-align-start-center">
        <div className={`${ROW_100} layout-align-start-center`}>
          <TextHeading theme={theme} text="By checking this box" size={4} />
        </div>
        <div className={`${ROW_100} layout-align-start-start`}>
          <ul className={`flex-100 ${styles.terms_list}`}>{termBullets}</ul>
        </div>
      </div>
    </div>
  )
}

function LocationsDestinationFactory ({ shipment, locations }) {
  return shipment.has_on_carriage ? (
    <div className={`${ROW_100} ${ALIGN_START}`}>
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
  )
}
function LocationsOriginFactory ({ shipment, locations }) {
  return shipment.has_pre_carriage ? (
    <div className={`${ROW_100} ${ALIGN_START}`}>
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

function getTotalPrice (shipment) {
  const { currency } = shipment.total_price
  const price = parseFloat(shipment.total_price.value).toFixed(2)

  return `${currency} ${price} `
}

function TotalGoodsValue (shipment) {
  return shipment.total_goods_value ? (
    <div
      className={`flex-45 layout-row offset-5 ${WRAP_START}`}
    >
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
    <div
      className={`flex-45 layout-row offset-10 ${WRAP_START}`}
    >
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
    <div
      className="flex-45 offset-5 layout-row layout-align-start-start layout-wrap"
    >
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
    <div
      className="flex-45 offset-5 layout-row layout-align-start-start layout-wrap"
    >
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
    <div
      className="flex-45 offset-5 layout-row layout-align-start-start layout-wrap"
    >
      <p className="flex-100">
        <b>Incoterm:</b>
      </p>
      <p className="flex-100 no_m">{shipment.incoterm_text}</p>
    </div>
  ) : (
    ''
  )
}

export default BookingConfirmation
