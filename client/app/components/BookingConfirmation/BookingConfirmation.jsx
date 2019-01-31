/* eslint react/prop-types: "off" */
import React, { Component } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import { pick, uniqWith } from 'lodash'
import { moment, documentTypes, shipmentStatii } from '../../constants'
import styles from './BookingConfirmation.scss'
import RouteHubBox from '../RouteHubBox/RouteHubBox'
import { RoundButton } from '../RoundButton/RoundButton'
import defaults from '../../styles/default_classes.scss'
import TextHeading from '../TextHeading/TextHeading'
import {
  gradientTextGenerator, totalPriceString, totalPrice, numberSpacing
} from '../../helpers'
import { remarkActions } from '../../actions'
import Checkbox from '../Checkbox/Checkbox'
import CargoItemGroup from '../Cargo/Item/Group'
import CargoItemGroupAggregated from '../Cargo/Item/Group/Aggregated'
import Contact from '../Contact/Contact'
import IncotermRow from '../Incoterm/Row'
import IncotermExtras from '../Incoterm/Extras'
import CargoItemSummary from '../Cargo/Item/Summary'
import CargoContainerSummary from '../Cargo/Container/Summary'

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
  ALIGN_START_START,
  COLUMN,
  ROW,
  WRAP_ROW
} from '../../classNames'
import CargoContainerGroup from '../Cargo/Container/Group'
import CollapsingBar from '../CollapsingBar/CollapsingBar'

const AFTER_CONTAINER =
  `${WRAP_ROW('NONE')} ${ALIGN_CENTER_START} content_width_booking`

const BACK_TO_DASHBOARD =
  `${styles.back_to_dash_sec} ${WRAP_ROW(100)} layout-align-center`

const BACK_TO_DASHBOARD_CELL =
  `${defaults.content_width} flex-none ${ROW('CONTENT')} ${ALIGN_START_CENTER}`
const BOOKING = `${ROW('NONE')} content_width_booking ${ALIGN_CENTER}`
const BUTTON = `${ROW('NONE')} ${ALIGN_END}`

/**
 * Prepend with `BOOKING_CONFIRMATION` to make e2e test easier to write
 */
const CONTAINER = `BOOKING_CONFIRMATION ${WRAP_ROW(100)} ${ALIGN_CENTER_START}`

const INNER_WRAPPER = `${styles.inner_wrapper} ${WRAP_ROW(100)} ${ALIGN_START}`
const INNER_WRAPPER_CELL = `${WRAP_ROW(100)} ${ALIGN_BETWEEN_START}`

const LAYOUT_WRAP = `${WRAP_ROW(100)} ${ALIGN_START_CENTER}`
const UPLOADED_DOCS = `${ROW(35)} layout-wrap ${ALIGN_START} ${styles.uploaded_doc}`
const MISSING_DOCS = `${ROW(35)} layout-wrap ${ALIGN_START} ${styles.no_doc}`

const SUBTITLE = `${styles.sec_subtitle_text} flex-none offset-5`
const SUBTITLE_NORMAL = `${styles.sec_subtitle_text_normal} flex-none`
const SUMM_TOP = `${styles.b_summ_top} ${ROW(100)} ${ALIGN_AROUND_STRETCH}`
const TOTAL_ROW = `${styles.total_row} ${WRAP_ROW(100)} ${ALIGN_AROUND_CENTER}`

const acceptStyle = { marginBottom: '15px' }

export function calcFareTotals (feeHash) {
  if (!feeHash) return 0

  const total = feeHash.total && +feeHash.total.value

  return Object.keys(feeHash).reduce((sum, k) => (
    feeHash[k] && ['customs', 'insurance', 'addons']
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
  if (feeHash &&
    feeHash.addons &&
    feeHash.addons.customs_export_paper &&
    feeHash.addons.customs_export_paper.value) {
    res1 += parseFloat(feeHash.addons.customs_export_paper.value)
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
    this.getRemarks = this.getRemarks.bind(this)
  }

  componentDidMount () {
    const { setStage, match, bookingHasCompleted } = this.props
    setStage(5)
    this.getRemarks()
    window.scrollTo(0, 0)
    bookingHasCompleted(match.params.shipmentId)
  }

  getRemarks () {
    const { remarkDispatch } = this.props
    remarkDispatch.getRemarks()
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
      t,
      tenant,
      remark
    } = this.props

    if (!shipmentData) return <h1>{t('bookconf:loading')}</h1>
    const {
      aggregatedCargo,
      cargoItemTypes,
      cargoItems,
      consignee,
      containers,
      documents,
      addresses,
      notifyees,
      shipment,
      shipper
    } = shipmentData

    if (!shipment || !addresses || !cargoItemTypes) return <h1>{t('bookconf:loading')}</h1>

    const { acceptTerms } = this.state
    const terms = getTenantTerms(tenant, t)
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
    const notifyeesJSX = getNotifyeesJSX({ notifyees, textStyle, t })
    const feeHash = shipment.selected_offer

    const remarkBody = remark.quotation ? remark.quotation.shipment.map(_remark => (
      <li>
        {_remark.body}
      </li>
    )) : ''
    const showCargoSummary = !aggregatedCargo
    let cargoSummary
    if (showCargoSummary && cargoItems.length) {
      cargoSummary = <CargoItemSummary items={cargoItems} t={t} />
    } else if (showCargoSummary && containers.length) {
      cargoSummary = <CargoContainerSummary items={containers} t={t} />
    }

    const acceptedBtn = (
      <div className={BUTTON}>
        <RoundButton
          theme={theme}
          text={t('bookconf:finishRequest')}
          handleNext={() => this.requestShipment()}
          active
        />
      </div>
    )
    const nonAcceptedBtn = (
      <div className={BUTTON}>
        <RoundButton
          theme={theme}
          text={t('bookconf:finishRequest')}
          handleNext={e => e.preventDefault()}
        />
      </div>
    )

    const themeTitled = getThemeTitled(theme)
    const { docView, missingDocs } = getDocs({
      documents,
      theme,
      dispatchFn: this.fileFn,
      deleteFn: this.deleteDoc,
      t
    })

    const Terms = getTerms({ theme, terms, t })
    const status = shipmentStatii[shipment.status]

    const ShipmentCard = (

      <CollapsingBar
        text={t('common:overview')}
        parentClass={styles.shipment_card_border}
        showArrow
        hideIcon
      >
        <div className={INNER_WRAPPER}>

          <div className={INNER_WRAPPER_CELL}>
            <h4 className="flex-none">{`${t('bookconf:shipmentReference')}:`}</h4>
            <h4 className="clip flex-none offset-5" style={textStyle}>
              {shipment.imc_reference}
            </h4>
          </div>

          <div className={INNER_WRAPPER_CELL}>
            <p className={SUBTITLE_NORMAL}>{`${t('common:status')}:`}</p>
            <p className={SUBTITLE}>
              {status}
            </p>
          </div>

          <div className={INNER_WRAPPER_CELL}>
            <p className={SUBTITLE_NORMAL}>{`${t('common:createdAt')}:`}</p>
            <p className={SUBTITLE}>
              {createdDate}
            </p>
          </div>
        </div>
      </CollapsingBar>
    )

    const Itinerary = (
      <CollapsingBar
        text={t('common:itinerary')}
        parentClass={styles.shipment_card_border}
        showArrow
      >
        <div className={INNER_WRAPPER}>
          <RouteHubBox shipment={shipment} theme={theme} />
        </div>
      </CollapsingBar>
    )

    const FaresAndFees = (
      <CollapsingBar
        text={t('common:faresFees')}
        parentClass={styles.shipment_card_border}
        showArrow
      >
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
                  {`${totalPrice(shipment).currency} ${calcFareTotals(feeHash)}`}
                </h5>
              </div>
            </div>
            <div className={BOOKING}>
              <IncotermRow
                theme={theme}
                preCarriage={shipment.has_pre_carriage}
                onCarriage={shipment.has_on_carriage}
                originFees={shipment.selected_offer.export}
                destinationFees={shipment.selected_offer.import}
                feeHash={feeHash}
                mot={shipment.mode_of_transport}
                tenant={tenant}
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
                <h5 className="flex-none letter_3">
                  {`${
                    totalPrice(shipment).currency
                  } ${calcExtraTotals(feeHash)} `}
                </h5>
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
                shipment={shipment}
                tenant={tenant}
              />
            </div>
          </div>
        </div>
        <div className={TOTAL_ROW}>
          <div className={`${ROW(70)} ${ALIGN_START_CENTER}`}>
            <h3 className="flex-none letter_3">Shipment Total: </h3>
          </div>
          <div className={`${WRAP_ROW(30)} ${ALIGN_END_CENTER}`}>
            <h3 className="flex-none letter_3">{totalPriceString(shipment)}</h3>
            <div className={`${ROW(100)} ${ALIGN_END_CENTER}`}>
              <p className="flex-none center no_m" style={{ fontSize: '12px' }}>
                {' '}
                    ( incl. Quoted Additional Services )
              </p>
            </div>
          </div>
        </div>
      </CollapsingBar>

    )

    const ContactDetails = (
      <CollapsingBar
        text={t('bookconf:contact')}
        parentClass={styles.shipment_card_border}
        showArrow
      >
        <div className={INNER_WRAPPER}>
          <div className={SUMM_TOP}>
            {shipperAndConsignee}
          </div>
          <div className={`${WRAP_ROW(100)} ${ALIGN_AROUND_CENTER}`}>
            {' '}
            {notifyeesJSX}
            {' '}
          </div>
        </div>
      </CollapsingBar>

    )

    const CargoDetails = (
      <CollapsingBar
        text={t('bookconf:cargo')}
        parentClass={styles.shipment_card_border}
        showArrow
      >
      {showCargoSummary ? cargoSummary : '' }
        <div className={INNER_WRAPPER}>
          <div className={LAYOUT_WRAP}>
            
            {cargoView}
          </div>
        </div>
      </CollapsingBar>

    )

    const AdditionalInformation = (
      <CollapsingBar
        text={t('common:additional')}
        parentClass={styles.shipment_card_border}
        showArrow
      >
        <div className={INNER_WRAPPER}>
          <div className={LAYOUT_WRAP}>
            <div className={`${ROW(100)} ${ALIGN_START_START}`}>
              {TotalGoodsValue(shipment, t)}
              {Eori(shipment, t)}

              {shipment.cargo_notes ? (
                <div className={`${WRAP_ROW(45)} ${ALIGN_START}`}>
                  <p className="flex-100">
                    <b>{`${t('bookconf:description')}:`}</b>
                  </p>
                  <p className="flex-100 no_m">{shipment.cargo_notes}</p>
                </div>
              ) : (
                ''
              )}
              {shipment.route_notes || shipment.notes ? (
                <div className={`${WRAP_ROW(45)} ${ALIGN_START} padding_top`}>
                  <p className="flex-100">
                    <b>{`${t('common:notes')}:`}</b>
                  </p>
                  {shipment.route_notes ? <p className="flex-100 no_m">{shipment.route_notes}</p> : ''}
                  {shipment.notes ? <p className="flex-100 no_m">{shipment.notes}</p> : ''}
                </div>
              ) : (
                ''
              )}
              {shipment.incoterm_text ? (
                <div className={`${WRAP_ROW(45)} ${ALIGN_START} padding_top`}>
                  <p className="flex-100">
                    <b>{`${t('common:incoterm')}:`}</b>
                  </p>
                  <p className="flex-100 no_m">{shipment.incoterm_text}</p>
                </div>
              ) : (
                ''
              )}
            </div>
            {remarkBody ? (
              <div className={`${WRAP_ROW(45)} ${ALIGN_START} padding_top`}>
                <h4>{`${t('shipment:remarks')}:`}</h4>
                <ul>
                  {remarkBody}
                </ul>
              </div>
            ) : ''}
          </div>
        </div>
      </CollapsingBar>

    )

    const Documents = (
      <CollapsingBar
        text={t('common:documents')}
        parentClass={styles.shipment_card_border}
        showArrow
      >
        <div className={INNER_WRAPPER}>
          <div className="flex-100 layout-row layout-wrap layout-align-start-start">
            {docView}
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-start-start">
            {missingDocs}
          </div>
        </div>
      </CollapsingBar>

    )

    const AgreeAndSubmit = (
      <CollapsingBar
        text={t('common:agree')}
        parentClass={styles.shipment_card_border}
        showArrow
        hideIcon
      >
        <div className="layout-row layout-align-space-between-start layout-wrap flex-100">
          <div className="layout-row layout-align-start-start flex-100">
            <div className={`${ROW(15)} layout-align-end-center`} style={{ marginTop: '1.33em' }}>
              <Checkbox
                id="accept_terms"
                className="ccb_accept_terms"
                onChange={this.toggleAcceptTerms}
                checked={this.state.acceptTerms}
                theme={theme}
              />
            </div>
            <label htmlFor="accept_terms" className="pointy layout-align-center-start flex-85">
              {Terms}
            </label>
          </div>

          <div className="layout-row layout-align-start-end flex-33 offset-20" style={acceptStyle}>
            {acceptTerms ? acceptedBtn : nonAcceptedBtn}
          </div>
        </div>
      </CollapsingBar>
    )
    const compArray = [
      ShipmentCard,
      Itinerary,
      FaresAndFees,
      ContactDetails,
      CargoDetails,
      AdditionalInformation,
      Documents,
      AgreeAndSubmit]

    return (
      <div className={CONTAINER}>
        <div className={AFTER_CONTAINER}>
          {compArray.map(comp => (
            <div className="flex-100 layout-row layout-align-center-center padding_top">
              {comp}
            </div>
          ))}

          <hr className={`${styles.sec_break} flex-100`} />

          <div className={BACK_TO_DASHBOARD}>
            <div className={BACK_TO_DASHBOARD_CELL}>
              <RoundButton
                theme={theme}
                text={t('common:back')}
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
  const { tenant, shipmentData } = props
  const { hsCodes, shipment } = shipmentData
  const { scope } = tenant
  const uniqCargos = uniqWith(cargos, (x, y) => x.id === y.id)

  return uniqCargos.map((singleCargo, i) => {
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

    const group = {
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

    return (
      <CargoContainerGroup
        key={v4()}
        group={group}
        theme={props.theme}
        hsCodes={hsCodes}
        shipment={shipment}
        hideUnits={scope.cargo_overview_only}
      />
    )
  })
}

function prepCargoItemGroups (cargos, props) {
  const { tenant, shipmentData } = props
  const { cargoItemTypes, hsCodes, shipment } = shipmentData
  const { scope } = tenant
  const uniqCargos = uniqWith(cargos, (x, y) => x.id === y.id)

  return uniqCargos.map((singleCargo, i) => {
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

    const volume = (parsedY * parsedX * parsedZ / 1000000 * parsedQuantity)
    const cargoType = cargoItemTypes[singleCargo.cargo_item_type_id]
    const items = Array(parsedQuantity).fill(singleCargo)

    const group = {
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

    return (
      <CargoItemGroup
        key={v4()}
        group={group}
        theme={props.theme}
        hsCodes={hsCodes}
        scope={scope}
        shipment={shipment}
        hideUnits={scope.cargo_overview_only}
      />
    )
  })
}

function getDocs ({
  documents,
  theme,
  dispatchFn,
  deleteFn,
  t
}) {
  const docChecker = {
    packing_sheet: false,
    commercial_invoice: false
  }
  const docView = []
  const missingDocs = []

  const uploadedDocs = documents.reduce((docObj, item) => {
    docObj[item.doc_type] = docObj[item.doc_type] || []
    docObj[item.doc_type].push(item.text)

    return docObj
  }, {})
  if (documents) {
    Object.keys(uploadedDocs).forEach((key) => {
      docChecker[key] = true

      docView.push(<div className={UPLOADED_DOCS}>
        <i className="fa fa-check flex-none" />
        <div className="layout-row flex layout-wrap" style={{ marginBottom: '12px' }}>
          <h4 className="flex-100 layout-row">{documentTypes[key]}</h4>
          {uploadedDocs[key].map(text => (
            <p className="flex-100 layout-row">
              {text}
            </p>
          ))}
        </div>
      </div>)
    })
  }

  Object.keys(docChecker).forEach((key) => {
    if (!docChecker[key]) {
      missingDocs.push(<div key={v4()} className={MISSING_DOCS}>
        <i className="flex-none fa fa-ban" />
        <div className="flex layout-wrap layout-row">
          <h4 className="flex-100">{documentTypes[key]}</h4>
          <p>{t('bookconf:notUploaded')}</p>
        </div>
      </div>)
    }
  })

  return { missingDocs, docView }
}

function getDefaultTerms (tenant, t) {
  return [
    t('bookconf:termsFirst'),
    `${t('bookconf:termsSecond')} ${tenant.name}`,
    t('bookconf:termsThird')
  ]
}

function getTenantTerms (tenant, t) {
  const defaultTerms = getDefaultTerms(tenant, t)

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

function getNotifyeesJSX ({ notifyees, textStyle, t }) {
  if (!notifyees) {
    return []
  }

  const notifyeesJSX = notifyees.map(notifyee => (
    <div key={v4()} className={ROW(40)}>
      <div className={`${COLUMN(15)} ${ALIGN_START_CENTER}`}>
        <i
          className={`${styles.icon} fa fa-envelope-open-o flex-none`}
          style={textStyle}
        />
      </div>
      <div className={`${WRAP_ROW(85)} ${ALIGN_START}`}>
        <div className="flex-100">
          <h3 style={{ fontWeight: 'normal' }}>{t('common:notifyee')}</h3>
        </div>
        <p style={{ marginTop: 0 }}>
          {notifyee.first_name}
          {' '}
          {notifyee.last_name}
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

function getTerms ({ theme, terms, t }) {
  const termBullets = terms.map(term => (
    <li key={v4()}>
      {' '}
      {term}
    </li>
  ))

  return (
    <div className={`layout-row ${ALIGN_START_CENTER}`}>
      <div className="flex-5" />
      <div className={`${WRAP_ROW(95)} ${ALIGN_START_CENTER}`}>
        <div className={`${ROW(100)} ${ALIGN_START_CENTER}`}>
          <TextHeading
            theme={theme}
            text={t('common:checkBox')}
            size={4}
          />
        </div>
        <div className="flex-100 layout-column layout-align-start-start">
          <ul className={`flex-50 ${styles.terms_list}`}>{termBullets}</ul>
        </div>
      </div>
    </div>
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

function TotalGoodsValue (shipment, t) {
  return shipment.total_goods_value ? (
    <div className={`${WRAP_ROW(45)} ${ALIGN_START}`}>
      <p className="flex-100">
        <b>{`${t('bookconf:totalValue')}:`}</b>
      </p>
      <p className="flex-100 no_m">
        {`${
          shipment.total_goods_value.currency
        } ${numberSpacing(shipment.total_goods_value.value, 2)}`}
      </p>
    </div>
  ) : (
    ''
  )
}

function Eori (shipment, t) {
  return shipment.eori ? (
    <div className={`${WRAP_ROW(45)} offset-10 ${ALIGN_START}`}>
      <p className="flex-100">
        <b>{`${t('bookconf:eori')}:`}</b>
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

function mapStateToProps (state) {
  const {
    remark
  } = state

  return {
    remark
  }
}

function mapDispatchToProps (dispatch) {
  return {
    remarkDispatch: bindActionCreators(remarkActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['bookconf', 'common'])(BookingConfirmation))
