import React, { Component } from 'react'
import { v4 } from 'uuid'
import { pick, uniqWith } from 'lodash'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import { formatDate, parseDate } from 'react-day-picker/moment'
import { CargoItemGroup } from '../../Cargo/Item/Group'
import CargoItemGroupAggregated from '../../Cargo/Item/Group/Aggregated'
import PropTypes from '../../../prop-types'
import { moment, documentTypes } from '../../../constants'
import adminStyles from '../Admin.scss'
import styles from '../AdminShipments.scss'
import DocumentsForm from '../../Documents/Form'
import GradientBorder from '../../GradientBorder'
import ShipmentOverviewShowCard from './ShipmentOverviewShowCard'
import ContactDetailsRow from './ContactDetailsRow'
import GreyBox from '../../GreyBox/GreyBox'
import {
  gradientTextGenerator,
  gradientGenerator,
  gradientBorderGenerator,
  switchIcon,
  totalPrice,
  formattedPriceValue,
  checkPreCarriage
} from '../../../helpers'
import { CargoContainerGroup } from '../../Cargo/Container/Group'
import Tabs from '../../Tabs/Tabs'
import Tab from '../../Tabs/Tab'

export class AdminShipmentView extends Component {
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
      return { currency: ' ', total: 'None' }
    }

    return { currency: curr, total: total.toFixed(2) }
  }
  static calcCargoLoad (feeHash, loadType) {
    const cargoCount = Object.keys(feeHash.cargo).length
    let noun = ''
    if (loadType === 'cargo_item' && cargoCount > 3) {
      noun = 'Cargo Items'
    } else if (loadType === 'cargo_item' && cargoCount === 3) {
      noun = 'Cargo Item'
    } else if (loadType === 'container' && cargoCount > 3) {
      noun = 'Containers'
    } else if (loadType === 'container' && cargoCount === 3) {
      noun = 'Container'
    }

    return `${noun}`
  }
  static checkSelectedOffer (service) {
    let obj = {}
    if (service && service.total) {
      const total = service.edited_total || service.total
      obj = total
    }

    return obj
  }
  constructor (props) {
    super(props)

    const { shipment } = this.props.shipmentData
    this.state = {
      showEditPrice: false,
      showEditServicePrice: false,
      newTotal: 0,
      showEditTime: false,
      currency: totalPrice(shipment).currency,
      newTimes: {
        eta: {
          day: new Date(moment(shipment.planned_eta).format())
        },
        etd: {
          day: new Date(moment(shipment.planned_etd).format())
        }
      },
      newPrices: {
        trucking_pre: AdminShipmentView.checkSelectedOffer(shipment.selected_offer.trucking_pre),
        trucking_on: AdminShipmentView.checkSelectedOffer(shipment.selected_offer.trucking_on),
        cargo: AdminShipmentView.checkSelectedOffer(shipment.selected_offer.cargo),
        insurance: AdminShipmentView.checkSelectedOffer(shipment.selected_offer.insurance),
        customs: AdminShipmentView.checkSelectedOffer(shipment.selected_offer.customs)
      }
    }
    this.handleDeny = this.handleDeny.bind(this)
    this.handleAccept = this.handleAccept.bind(this)
    this.handleFinished = this.handleFinished.bind(this)
    this.toggleEditPrice = this.toggleEditPrice.bind(this)
    this.toggleEditServicePrice = this.toggleEditServicePrice.bind(this)
    this.toggleEditTime = this.toggleEditTime.bind(this)
    this.saveNewPrice = this.saveNewPrice.bind(this)
    this.saveNewEditedPrice = this.saveNewEditedPrice.bind(this)
    this.saveNewTime = this.saveNewTime.bind(this)
    this.handleNewTotalChange = this.handleNewTotalChange.bind(this)
    this.handleCurrencySelect = this.handleCurrencySelect.bind(this)
    this.handleDayChange = this.handleDayChange.bind(this)
    this.handleTimeChange = this.handleTimeChange.bind(this)
  }
  componentDidMount () {
    const {
      shipmentData, loading, adminDispatch, match
    } = this.props
    if (!shipmentData && !loading) {
      adminDispatch.getShipment(match.params.id, false)
    }
    window.scrollTo(0, 0)
  }
  handleDeny () {
    const { shipmentData, handleShipmentAction, adminDispatch } = this.props
    handleShipmentAction(shipmentData.shipment.id, 'decline')
    adminDispatch.getShipments(true)
  }

  handleCurrencySelect (selection) {
    this.setState({ currency: selection })
  }
  handleDayChange (event, target) {
    this.setState({
      newTimes: {
        ...this.state.newTimes,
        [target]: {
          ...this.state.newTimes[target],
          day: event
        }
      }
    })
  }
  handleTimeChange (event, target) {
    const { value } = event.target

    this.setState({
      newTimes: {
        ...this.state.newTimes,
        [target]: {
          ...this.state.newTimes[target],
          time: value
        }
      }
    })
  }

  handleAccept () {
    const { shipmentData, handleShipmentAction } = this.props
    handleShipmentAction(shipmentData.shipment.id, 'accept')
  }
  handleFinished () {
    const { shipmentData, handleShipmentAction } = this.props
    handleShipmentAction(shipmentData.shipment.id, 'finished')
  }
  handlePriceChange (key, value) {
    const { newPrices } = this.state
    this.setState({
      newPrices: {
        ...newPrices,
        [key]: {
          ...newPrices[key],
          value
        }
      }
    })
  }
  toggleEditPrice () {
    this.setState({ showEditPrice: !this.state.showEditPrice })
  }
  toggleEditServicePrice () {
    this.setState({ showEditServicePrice: !this.state.showEditServicePrice })
  }
  toggleEditTime () {
    this.setState({ showEditTime: !this.state.showEditTime })
  }

  deleteDoc (file) {
    const { adminDispatch } = this.props
    adminDispatch.deleteDocument(file.id)
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
      resultArray.push(<CargoItemGroup
        shipment={shipmentData.shipment}
        group={cargoGroups[k]}
        theme={theme}
        hsCodes={hsCodes}
      />)
    })

    return resultArray
  }
  prepContainerGroups (cargos) {
    const { theme, shipmentData } = this.props
    const { hsCodes, shipment } = shipmentData
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
        theme={theme}
        hsCodes={hsCodes}
        shipment={shipment}
      />))
  }
  saveNewTime () {
    const { newTimes } = this.state
    const { adminDispatch, shipmentData } = this.props
    const { shipment } = shipmentData

    const newEta = moment(newTimes.eta.day)
      .startOf('day')
      .format('lll')
    const newEtd = moment(newTimes.etd.day)
      .startOf('day')
      .format('lll')

    const timeObj = { newEta, newEtd }
    shipment.planned_eta = moment(newTimes.eta.day)
    shipment.planned_etd = moment(newTimes.etd.day)

    adminDispatch.editShipmentTime(shipmentData.shipment.id, timeObj)
    this.toggleEditTime()
  }
  saveNewPrice () {
    const { newTotal, currency } = this.state
    const { adminDispatch, shipmentData } = this.props
    adminDispatch.editShipmentPrice(shipmentData.shipment.id, {
      value: newTotal,
      currency: currency.value
    })
    this.toggleEditPrice()
  }
  saveNewEditedPrice () {
    const { newPrices, currency } = this.state
    const { adminDispatch, shipmentData } = this.props

    Object.keys(newPrices).forEach((k) => {
      const service = shipmentData.shipment.selected_offer[k]

      if (newPrices[k].value !== 0 && service && service.total && service.total.value &&
        newPrices[k].value !== service.total.value) {
        adminDispatch.editShipmentServicePrice(shipmentData.shipment.id, {
          price: {
            value: newPrices[k].value,
            currency
          },
          charge_category: k
        })
      }
    })

    this.toggleEditServicePrice()
  }
  handleNewTotalChange (event) {
    const { value } = event.target
    this.setState({ newTotal: +value })
  }
  fileFn (file) {
    const { shipmentData, adminDispatch } = this.props
    const { shipment } = shipmentData
    const type = file.doc_type
    const url = `/shipments/${shipment.id}/upload/${type}`
    adminDispatch.uploadDocument(file, type, url)
  }
  render () {
    const {
      theme, hubs, shipmentData, clients
    } = this.props

    if (!shipmentData || !hubs || !clients) {
      return <h1>NO DATA</h1>
    }
    const {
      contacts,
      shipment,
      documents,
      cargoItems,
      containers,
      aggregatedCargo,
      accountHolder
    } = shipmentData
    const {
      showEditTime, showEditServicePrice, newTimes, newPrices
    } = this.state

    const createdDate = shipment
      ? moment(shipment.updated_at).format('DD-MM-YYYY | HH:mm A')
      : moment().format('DD-MM-YYYY | HH:mm A')
    const bg1 =
      shipment.origin_hub && shipment.origin_hub.photo
        ? { backgroundImage: `url(${shipment.origin_hub.photo})` }
        : {
          backgroundImage:
            'url("https://assets.itsmycargo.com/assets/default_images/crane_sm.jpg")'
        }
    const bg2 =
      shipment.destination_hub && shipment.destination_hub.photo
        ? { backgroundImage: `url(${shipment.destination_hub.photo})` }
        : {
          backgroundImage:
            'url("https://assets.itsmycargo.com/assets/default_images/destination_sm.jpg")'
        }
    const gradientStyle =
      theme && theme.colors
        ? gradientGenerator(theme.colors.primary, theme.colors.secondary)
        : { background: 'black' }
    const selectedStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: '#E0E0E0' }
    const deselectedStyle = {
      ...gradientTextGenerator('#DCDBDC', '#DCDBDC')
    }
    const gradientBorderStyle =
      theme && theme.colors
        ? gradientBorderGenerator(theme.colors.primary, theme.colors.secondary)
        : { background: 'black' }

    const docView = []
    let cargoView = ''
    if (containers) {
      cargoView = this.prepContainerGroups(containers)
    }
    if (cargoItems.length > 0) {
      cargoView = this.prepCargoItemGroups(cargoItems)
    }
    if (aggregatedCargo) {
      cargoView = <CargoItemGroupAggregated group={aggregatedCargo} />
    }

    const statusRequested = (shipment.status === 'requested') ? (
      <GradientBorder
        wrapperClassName={`
          layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25
          ${adminStyles.header_margin_buffer} ${styles.status_box_requested}`}
        gradient={gradientBorderStyle}
        className="layout-row flex-100 layout-align-center-center"
        content={(
          <p className="layout-align-center-center layout-row"> {shipment.status} </p>
        )}
      />
    ) : (
      ''
    )

    const statusInProcess = (shipment.status === 'confirmed') ? (
      <div style={gradientStyle} className={`layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25 layout-align-center-center ${adminStyles.header_margin_buffer}  ${styles.status_box_process}`}>
        <p className="layout-align-center-center layout-row"> In process </p>
      </div>
    ) : (
      ''
    )

    const statusFinished = (shipment.status === 'finished') ? (
      <div className={`${adminStyles.border_box} layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25 layout-align-center-center ${adminStyles.header_margin_buffer}  ${styles.status_box}`}>
        <p className="layout-align-center-center layout-row"> {shipment.status} </p>
      </div>
    ) : (
      ''
    )

    const docChecker = {
      packing_sheet: false,
      commercial_invoice: false
      // ,
      // customs_declaration: false,
      // customs_value_declaration: false,
      // eori: false,
      // certificate_of_origin: false,
      // dangerous_goods: false,
      // bill_of_lading: false,
      // invoice: false
    }
    const missingDocs = []
    if (documents) {
      documents.forEach((doc) => {
        docChecker[doc.doc_type] = true
        docView.push(<div className="flex-xs-100 flex-sm-45 flex-33 flex-gt-lg-25 layout-align-start-center layout-row" style={{ padding: '10px' }}>
          <DocumentsForm
            theme={theme}
            type={doc.doc_type}
            dispatchFn={file => this.fileFn(file)}
            text={documentTypes[doc.doc_type]}
            doc={doc}
            viewer
            deleteFn={file => this.deleteDoc(file)}
          />
        </div>)
      })
    }
    Object.keys(docChecker).forEach((key) => {
      if (!docChecker[key]) {
        missingDocs.push(<div className={`flex-25 layout-padding layout-row layout-align-start-center ${adminStyles.no_doc}`}>
          <div className="flex-none layout-row layout-align-center-center">
            <i className="flex-none fa fa-ban" />
          </div>
          <div className="flex layout-align-start-center layout-row">
            <p className="flex-none">{`${documentTypes[key]}: Not Uploaded`}</p>
          </div>
        </div>)
      }
    })
    const feeHash = shipment.selected_offer

    const dayPickerPropsEtd = {
      disabledDays: {
        after: newTimes.eta.day,
        before: new Date()
      },
      month: new Date(
        moment()
          .add(7, 'days')
          .format('YYYY'),
        moment()
          .add(7, 'days')
          .format('M') - 1
      ),
      name: 'dayPicker'
    }

    const dayPickerPropsEta = {
      disabledDays: {
        before: newTimes.etd.day < new Date() ? new Date() : newTimes.etd.day
      },
      month: new Date(
        moment()
          .add(7, 'days')
          .format('YYYY'),
        moment()
          .add(7, 'days')
          .format('M') - 1
      ),
      name: 'dayPicker'
    }

    const etdJSX = showEditTime ? (
      <div className="layout-row flex-100">
        <div className="flex-65 layout-row">
          <DayPickerInput
            name="dayPicker"
            placeholder="DD/MM/YYYY"
            format="DD/MM/YYYY"
            formatDate={formatDate}
            parseDate={parseDate}
            value={newTimes.etd.day}
            onDayChange={e => this.handleDayChange(e, 'etd')}
            dayPickerProps={dayPickerPropsEtd}
          />
        </div>
      </div>
    ) : (
      <p className={`flex-none letter_3 ${styles.date}`}>
        {`${moment(shipment.planned_etd).format('DD/MM/YYYY | HH:mm')}`}
      </p>
    )

    const etaJSX = showEditTime ? (
      <div className="layout-row flex-100">
        <div className="flex-65 layout-row">
          <DayPickerInput
            name="dayPicker"
            placeholder="DD/MM/YYYY"
            format="DD/MM/YYYY"
            formatDate={formatDate}
            parseDate={parseDate}
            value={newTimes.eta.day}
            onDayChange={e => this.handleDayChange(e, 'eta')}
            dayPickerProps={dayPickerPropsEta}
          />
        </div>
      </div>
    ) : (
      <p className={`flex-none letter_3 ${styles.date}`}>
        {`${moment(shipment.planned_eta).format('DD/MM/YYYY | HH:mm')}`}
      </p>
    )
    const cargoCount = Object.keys(feeHash.cargo).length - 2
    const dnrEditKeys = ['in_process', 'finished', 'confirmed']

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className={`${adminStyles.margin_box_right} layout-row flex-100 layout-align-center-stretch margin_bottom`}>
          <div className={`layout-row flex layout-align-space-between-center ${adminStyles.title_shipment_grey}`}>
            <p className="layout-align-start-center layout-row">Ref:&nbsp; <span>{shipment.imc_reference}</span></p>
            <p className="layout-row layout-align-end-end"><strong>Placed at:&nbsp;</strong> {createdDate}</p>
          </div>
          {statusRequested}
          {statusInProcess}
          {statusFinished}
          <div className={`layout-row flex-none layout-align-space-around-center ${adminStyles.border_box} ${adminStyles.action_icons}`}>
            {shipment.status === 'requested' ? (
              <i className={`fa fa-check ${styles.light_green}`} onClick={this.handleAccept} />
            ) : (
              ''
            )}
            {shipment.status === 'confirmed' ? (
              <i className={`fa fa-check ${styles.light_green}`} onClick={this.handleFinished} />
            ) : (
              ''
            )}
            <i className={`fa fa-trash ${styles.light_red}`} onClick={this.handleDeny} />
          </div>
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-start-start padding_top">
          <Tabs
            wrapperTabs="layout-row flex-100 margin_bottom"
          >
            <Tab
              tabTitle="Overview"
              theme={theme}
            >
              <div className="flex-100 layout-row layout-wrap layout-align-center-center  padding_top">
                <div className="layout-row flex-100 margin_bottom">

                  <GradientBorder
                    wrapperClassName={`layout-row flex-40 ${styles.hub_box_shipment}`}
                    gradient={gradientBorderStyle}
                    className="layout-row flex"
                    content={(
                      <div className="layout-row flex-100">
                        <ShipmentOverviewShowCard
                          et={etdJSX}
                          text="ETD"
                          theme={theme}
                          hub={shipment.origin_hub}
                          shipment={shipment}
                          bg={bg1}
                          editTime={this.state.showEditTime}
                          handleSaveTime={this.saveNewTime}
                          toggleEditTime={this.toggleEditTime}
                          isAdmin={!dnrEditKeys.includes(shipment.status)}
                        />
                      </div>
                    )}
                  />
                  <div className="layout-row flex-20 layout-align-center-center">
                    <div className={`layout-column flex layout-align-center-center ${styles.font_adjustaments}`}>
                      <div className="layout-align-center-center layout-row" style={gradientStyle}>
                        {switchIcon()}
                      </div>
                      <p className="">Estimated time delivery</p>
                      <h5>{moment(shipment.planned_eta).diff(moment(shipment.planned_etd), 'days')} days{' '}</h5>
                    </div>
                  </div>

                  <GradientBorder
                    wrapperClassName={`layout-row flex-40 ${styles.hub_box_shipment}`}
                    gradient={gradientBorderStyle}
                    className="layout-row flex"
                    content={(
                      <div className="layout-row flex-100">
                        <ShipmentOverviewShowCard
                          et={etaJSX}
                          text="ETA"
                          theme={theme}
                          hub={shipment.destination_hub}
                          bg={bg2}
                          shipment={shipment}
                          editTime={this.state.showEditTime}
                          handleSaveTime={this.saveNewTime}
                          toggleEditTime={this.toggleEditTime}
                          isAdmin={!dnrEditKeys.includes(shipment.status)}
                        />
                      </div>
                    )}
                  />
                </div>
              </div>
            </Tab>
            <Tab
              tabTitle="Freight"
              theme={theme}
            >
              <div className="flex-100 layout-row layout-wrap layout-align-center-center  padding_top">
                <div className={`${adminStyles.border_box} margin_bottom layout-sm-column layout-xs-column layout-row flex-100 `}>
                  <div className={`flex-50 flex-sm-100 flex-xs-100 layout-row ${styles.services_box}`}>
                    <div className="layout-column flex-100">
                      <h3>Freight, Duties & Carriage:</h3>
                      <div className="layout-wrap layout-row flex">
                        <div className="flex-45 margin_bottom">
                          <div className="layout-row flex-100">
                            <div className="flex-100 layout-wrap layout-row">
                              <div className="flex-100 layout-row">
                                <i className="fa fa-truck clip flex-none layout-align-center-center" style={shipment.has_pre_carriage ? selectedStyle : deselectedStyle} />
                                <p>Pick-up</p>
                              </div>
                              {feeHash.trucking_pre ? <div className="flex-100 layout-row layout-align-end-center">
                                <p>
                                  {feeHash.trucking_pre ? feeHash.trucking_pre.total.currency : ''}
                                  { ' ' }
                                  {feeHash.trucking_pre.edited_total
                                    ? parseFloat(feeHash.trucking_pre.edited_total.value).toFixed(2)
                                    : parseFloat(feeHash.trucking_pre.total.value).toFixed(2)}
                                </p>
                              </div>
                                : '' }
                              {showEditServicePrice && shipment.selected_offer.trucking_pre ? (
                                <div className={`layout-row flex-100 layout-align-end-stretch ${styles.greyborder}`}>
                                  <span
                                    className={
                                      `layout-row flex-100 layout-padding
                          layout-align-center-center ${styles.greybg}`
                                    }
                                  >
                                    {newPrices.trucking_pre.currency}
                                  </span>
                                  <input
                                    type="number"
                                    onChange={e => this.handlePriceChange('trucking_pre', e.target.value)}
                                    value={Number(newPrices.trucking_pre.value).toFixed(2)}
                                    className="layout-padding flex-70 layout-row flex-initial"
                                  />
                                </div>
                              ) : (
                                ''
                              )}
                            </div>

                          </div>
                        </div>
                        <div className="flex-offset-10 flex-45 margin_bottom">
                          <div className="layout-row flex-100">
                            <div className="flex-100 layout-wrap layout-row">
                              <div className="flex-100 layout-row">
                                <i
                                  className="fa fa-truck clip flex-none layout-align-center-center"
                                  style={shipment.has_on_carriage ? selectedStyle : deselectedStyle}
                                />
                                <p>Delivery</p>
                              </div>
                              {feeHash.trucking_on ? <div className="flex-100 layout-row layout-align-end-center">
                                <p>
                                  {feeHash.trucking_on ? feeHash.trucking_on.total.currency : ''}
                                  { ' ' }
                                  {feeHash.trucking_on.edited_total
                                    ? parseFloat(feeHash.trucking_on.edited_total.value).toFixed(2)
                                    : parseFloat(feeHash.trucking_on.total.value).toFixed(2)}
                                </p>
                              </div>
                                : ''}
                              {showEditServicePrice && shipment.selected_offer.trucking_on ? (
                                <div className={`layout-row flex-100 layout-align-end-stretch ${styles.greyborder}`}>
                                  <span
                                    className={
                                      `layout-row flex-100 layout-padding
                          layout-align-center-center ${styles.greybg}`
                                    }
                                  >
                                    {newPrices.trucking_on.currency}
                                  </span>
                                  <input
                                    type="number"
                                    onChange={e => this.handlePriceChange('trucking_on', e.target.value)}
                                    value={Number(newPrices.trucking_on.value).toFixed(2)}
                                    className="layout-padding layout-row flex-70 flex-initial"
                                  />
                                </div>
                              ) : (
                                ''
                              )}
                            </div>

                          </div>

                        </div>
                        <div className="flex-45 margin_bottom">
                          <div className="layout-row flex-100">
                            <div className="flex-100 layout-wrap layout-row">
                              <div className="layout-row flex-100">
                                <i
                                  className="fa fa-file-text clip flex-none layout-align-center-center"
                                  style={shipment.has_pre_carriage ? selectedStyle : deselectedStyle}
                                />
                                <p>
                                Origin<br />
                                Documentation
                                </p>
                              </div>
                              {feeHash.export ? <div className="flex-100 layout-row layout-align-end-center">
                                <p>
                                  {feeHash.export ? feeHash.export.total.currency : ''}
                                  { ' ' }
                                  {feeHash.export.edited_total
                                    ? parseFloat(feeHash.export.edited_total.value).toFixed(2)
                                    : parseFloat(feeHash.export.total.value).toFixed(2)}
                                </p>
                              </div>
                                : ''}
                            </div>
                          </div>
                        </div>
                        <div
                          className="flex-offset-10 flex-45 margin_bottom"
                        >
                          <div className="layout-row flex-100">
                            <div className="layout-row flex-100 layout-wrap">
                              <div className="flex-100 layout-row">
                                <i
                                  className="fa fa-file-text-o clip flex-none layout-align-center-center"
                                  style={shipment.has_on_carriage ? selectedStyle : deselectedStyle}
                                />
                                <p>
                      Destination<br />
                      Documentation
                                </p>
                              </div>
                              {feeHash.import ? <div className="flex-100 layout-row layout-align-end-center">
                                <p>
                                  {feeHash.import ? feeHash.import.total.currency : ''}
                                  { ' ' }
                                  {feeHash.import.edited_total
                                    ? parseFloat(feeHash.import.edited_total.value).toFixed(2)
                                    : parseFloat(feeHash.import.total.value).toFixed(2)}
                                </p>
                              </div>
                                : ''}
                            </div>
                          </div>
                        </div>
                        <div className="flex-45 margin_bottom">
                          <div className="layout-row flex-100">
                            <div className="layout-row layout-wrap flex-100">
                              <div className="flex-100 layout-row">
                                <i
                                  className="fa fa-ship clip flex-none layout-align-center-center"
                                  style={selectedStyle}
                                />
                                <p>Freight</p>
                              </div>
                              {feeHash.cargo
                                ? <div className="flex-100 layout-row layout-align-end-center">
                                  <p>
                                    {feeHash.cargo ? feeHash.cargo.total.currency : ''}
                                    { ' ' }
                                    {feeHash.cargo.edited_total
                                      ? parseFloat(feeHash.cargo.edited_total.value).toFixed(2)
                                      : parseFloat(feeHash.cargo.total.value).toFixed(2)}
                                  </p>
                                </div>
                                : ''}
                              {showEditServicePrice && shipment.selected_offer.cargo ? (
                                <div className={`layout-row flex-100 layout-align-end-stretch ${styles.greyborder}`}>
                                  <span
                                    className={
                                      `layout-row flex-100 layout-padding
                          layout-align-center-center ${styles.greybg}`
                                    }
                                  >
                                    {newPrices.cargo.currency}
                                  </span>
                                  <input
                                    type="number"
                                    onChange={e => this.handlePriceChange('cargo', e.target.value)}
                                    value={Number(newPrices.cargo.value).toFixed(2)}
                                    className="layout-padding layout-row flex-70 flex-initial"
                                  />
                                </div>
                              ) : (
                                ''
                              )}
                            </div>

                          </div>

                        </div>
                      </div>
                    </div>
                  </div>
                  <div className={`flex-25 layout-row flex-sm-100 flex-xs-100 ${styles.additional_services} ${styles.services_box} ${styles.border_right}`}>
                    <div className="layout-column flex-80">
                      <h3>Additional Services</h3>
                      <div className="">
                        <div className="flex-100 margin_bottom">
                          <div className="layout-row flex-100">
                            <div className="layout-row flex-100 layout-wrap">
                              <div className="flex-100 layout-row">
                                <i className="fa fa-id-card clip flex-none" style={feeHash.customs ? selectedStyle : deselectedStyle} />
                                <p>Customs</p>
                              </div>
                              {feeHash.customs
                                ? <div className="flex-100 layout-row layout-align-end-center">
                                  <p>
                                    {feeHash.customs ? feeHash.customs.total.currency : ''}
                                    { ' ' }
                                    {feeHash.customs.edited_total
                                      ? parseFloat(feeHash.customs.edited_total.value).toFixed(2)
                                      : parseFloat(feeHash.customs.total.value).toFixed(2)}
                                  </p>
                                </div>
                                : '' }
                            </div>

                          </div>

                        </div>
                        <div className="flex-100 margin_bottom">
                          <div className="layout-row flex-100">
                            <div className="layout-row flex-100 layout-wrap">
                              <div className="flex-100 layout-row">
                                <i className="fa fa-umbrella clip flex-none" style={feeHash.customs ? selectedStyle : deselectedStyle} />
                                <p>Insurance</p>
                              </div>
                              {feeHash.insurance && (feeHash.insurance.value || feeHash.insurance.edited_total)
                                ? <div className="flex-100 layout-row layout-align-end-center">
                                  <p>
                                    {feeHash.insurance ? feeHash.insurance.currency : ''}
                                    { ' ' }
                                    {feeHash.insurance.edited_total
                                      ? parseFloat(feeHash.insurance.edited_total.value).toFixed(2)
                                      : ''}
                                    {feeHash.insurance.value
                                      ? parseFloat(feeHash.insurance.value).toFixed(2)
                                      : ''}
                                  </p>
                                </div>
                                : '' }
                              {feeHash.insurance && !feeHash.insurance.value && !feeHash.insurance.edited_total
                                ? <div className="flex-100 layout-row layout-align-end-center">
                                  <p>Requested  </p>
                                </div> : ''}
                              {showEditServicePrice && shipment.selected_offer.insurance ? (
                                <div className={`layout-row flex-100 layout-align-end-stretch ${styles.greyborder}`}>
                                  <span
                                    className={
                                      `layout-row flex-100 layout-padding
                          layout-align-center-center ${styles.greybg}`
                                    }
                                  >
                                    {newPrices.insurance.currency}
                                  </span>
                                  <input
                                    type="number"
                                    onChange={e => this.handlePriceChange('insurance', e.target.value)}
                                    value={Number(newPrices.insurance.value).toFixed(2)}
                                    className="layout-padding layout-row flex-70 flex-initial"
                                  />
                                </div>
                              ) : (
                                ''
                              )}
                            </div>

                          </div>

                        </div>
                      </div>
                    </div>
                    <div className="layout-row layout-padding flex-20 layout-align-center-start">
                      {showEditServicePrice ? (
                        <div className="layout-column layout-align-center-center">
                          <div className={`layout-row layout-align-center-center ${styles.save}`}>
                            <i onClick={this.saveNewEditedPrice} className="fa fa-check" />
                          </div>
                          <div className={`layout-row layout-align-center-center ${styles.cancel}`}>
                            <i onClick={this.toggleEditServicePrice} className="fa fa-trash" />
                          </div>
                        </div>
                      ) : (
                        <i onClick={this.toggleEditServicePrice} className={`fa fa-edit ${styles.editIcon}`} />
                      )}
                    </div>
                  </div>
                  <div className={`flex-25 flex-sm-100 flex-xs-100 layout-row layout-align-center-center layout-padding ${styles.services_box}`}>
                    <div className="layout-column flex-100">
                      <div className="layout-row layout-align-sm-end-center layout-align-xs-center-center flex-100">
                        <div className="layout-align-start-center layout-row flex">
                          <span style={gradientStyle} className={`layout-align-center-center layout-row flex-none ${styles.quantity_square}`}>x&nbsp;{cargoCount}</span>
                          <p className="layout-align-sm-end-center layout-align-xs-end-center">{AdminShipmentView.calcCargoLoad(feeHash, shipment.load_type)}</p>
                        </div>
                      </div>
                      <h2 className="layout-align-start-center layout-row flex">
                        {formattedPriceValue(totalPrice(shipment).value)} {totalPrice(shipment).currency}
                      </h2>
                    </div>
                  </div>
                </div>
              </div>

            </Tab>
            <Tab
              tabTitle="Contacts"
              theme={theme}
            >
              <div className="flex-100 layout-row layout-wrap layout-align-center-center  padding_top">
                <ContactDetailsRow
                  contacts={contacts}
                  style={selectedStyle}
                  accountId={shipment.user_id}
                  user={accountHolder}
                />
              </div>
            </Tab>
            <Tab
              tabTitle="Cargo Details"
              theme={theme}
            >
              <div className="flex-100 layout-row layout-wrap layout-align-center-center  padding_top">
                <GreyBox

                  wrapperClassName={`layout-row flex-100 ${adminStyles.no_margin_box_right}`}
                  contentClassName="layout-column flex"
                  content={cargoView}
                />
                <GreyBox
                  wrapperClassName={`layout-row layout-wrap layout-sm-column layout-xs-column flex-100
            ${styles.no_border_top} margin_bottom ${adminStyles.no_margin_box_right}`}
                  contentClassName="layout-row flex-100"
                  content={(
                    <div className="layout-column flex-100">
                      <div className={`layout-row flex-100 flex-sm-100 flex-xs-100 ${styles.column_info}`}>
                        <div className={`flex-33 layout-row offset-5 layout-align-start-center layout-wrap ${styles.border_right}`}>
                          {shipment.total_goods_value ? (
                            <div className="flex-100 layout-xs-column layout-row layout-align-start-start">
                              <span className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row">Total Value of Goods:</span>
                              <p className={`flex-60 flex-xs-100 layout-align-xs-start-center layout-row ${styles.info_values}`}>
                                {shipment.total_goods_value.value}
                                {shipment.total_goods_value.currency}
                              </p>
                            </div>
                          ) : (
                            <div className="flex-100 layout-xs-column layout-row layout-align-start-start">
                              <span className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row">Total Value of Goods:</span>
                              <p className={`flex-60 flex-xs-100 layout-align-xs-start-center layout-row ${styles.info_values}`}>
                          -
                              </p>
                            </div>
                          )}
                        </div>
                        <div className={`flex-33 layout-row offset-5 layout-align-start-center layout-wrap ${styles.border_right}`}>
                          {shipment.eori ? (
                            <div className="flex-100 layout-xs-column layout-row layout-align-start-start">
                              <span className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row">EORI number:</span>
                              <p className={`flex-60 flex-xs-100 layout-align-xs-start-center layout-row ${styles.info_values}`}>
                                {shipment.eori}
                              </p>
                            </div>
                          ) : (
                            <div className="flex-100 layout-xs-column layout-row layout-align-start-start">
                              <span className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row">EORI number:</span>
                              <p className={`flex-60 flex-xs-100 layout-align-xs-start-center layout-row ${styles.info_values}`}>
                          -
                              </p>
                            </div>
                          )}
                        </div>
                        <div className="flex-33 layout-row offset-5 layout-align-center-center layout-wrap">
                          {shipment.incoterm_text ? (
                            <div className="flex-100 layout-column layout-align-center-start">
                              <span className="flex-40 flex-xs-100 layout-align-center-center layout-row">Incoterm:</span>
                              <p className="flex-60 flex-xs-100 layout-align-xs-start-center layout-row">
                                {shipment.incoterm_text}
                              </p>
                            </div>
                          ) : (
                            <div className="flex-100 layout-column layout-align-start-start">
                              <span
                                className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row"
                              >
                        Incoterm:
                              </span>
                              <p
                                className="flex-60 flex-xs-100 layout-align-xs-start-center layout-row"
                              >
                          -
                              </p>
                            </div>
                          )}
                        </div>
                      </div>
                      <div className={`layout-column flex-100 flex-sm-100 flex-xs-100 ${styles.column_info}`}>
                        <div
                          className={`${styles.border_bottom}
                  flex-100 flex-sm-100 flex-xs-100 layout-row offset-5
                  layout-align-start-start layout-wrap`}
                        >
                          {shipment.cargo_notes ? (
                            <div className="flex-100 layout-row layout-align-start-center">
                              <span className="flex-30 layout-row">Description of Goods:</span>
                              <p className="flex-80 layout-padding layout-row">
                                {shipment.cargo_notes}
                              </p>
                            </div>
                          ) : (
                            <div className="flex-100 layout-row layout-align-start-center">
                              <span className="flex-30 layout-row">Description of Goods:</span>
                              <p className="flex-80 layout-padding layout-row">
                          -
                              </p>
                            </div>
                          )}
                        </div>
                        <div className="flex-100 flex-sm-100 flex-xs-100 layout-row offset-5 layout-align-start-start layout-wrap">
                          {shipment.notes ? (
                            <div className="flex-100 layout-row layout-align-start-center">
                              <span className="flex-20 layout-row">Notes:</span>
                              <p className="flex-80 layout-padding layout-row">
                                {shipment.notes}
                              </p>
                            </div>
                          ) : (
                            <div className="flex-100 layout-row layout-align-start-center">
                              <span className="flex-20 layout-row">Notes:</span>
                              <p className="flex-80 layout-padding layout-row">
                          -
                              </p>
                            </div>
                          )}
                        </div>
                      </div>
                    </div>

                  )}
                />
              </div>
            </Tab>
            <Tab
              tabTitle="Documents"
              theme={theme}
            >
              <div className="flex-100 layout-row layout-wrap layout-align-center-center  padding_top">
                <GreyBox

                  wrapperClassName={`layout-row flex-100 ${adminStyles.no_margin_box_right} margin_bottom `}
                  contentClassName="flex"
                  content={(
                    <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${adminStyles.padding_left}`}>
                      <div
                        className="flex-100 layout-row layout-wrap layout-align-start-center"
                        style={{ marginTop: '5px' }}
                      >
                        {docView}
                      </div>
                      <div
                        className="flex-100 layout-row layout-wrap layout-align-start-center"
                        style={{ marginTop: '5px' }}
                      >
                        {missingDocs}
                      </div>
                    </div>
                  )}
                />
              </div>
            </Tab>
          </Tabs>
        </div>

        {/* <ShipmentCard
          headingText="Documents"
          theme={theme}
          collapsed={collapser.documents}
          handleCollapser={() => this.handleCollapser('documents')}
          content={
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
              <div
                className="flex-100 layout-row layout-wrap layout-align-start-center"
                style={{ marginTop: '5px' }}
              >
                {docView}
              </div>
              <div
                className="flex-100 layout-row layout-wrap layout-align-start-center"
                style={{ marginTop: '5px' }}
              >
                {missingDocs}
              </div>
            </div>
          }
        /> */}

        {shipment.status === 'requested' ? (
          <div className={`flex-100 layout-row layout-align-center-center ${adminStyles.button_row}`}>
            <button style={gradientStyle} onClick={this.handleAccept}>Accept</button>
            <button onClick={this.handleDeny}>Refuse</button>
          </div>
        ) : (
          ''
        )}

      </div>
    )
  }
}

AdminShipmentView.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  shipmentData: PropTypes.shipmentData,
  clients: PropTypes.arrayOf(PropTypes.client),
  handleShipmentAction: PropTypes.func.isRequired,
  loading: PropTypes.bool,
  adminDispatch: PropTypes.shape({
    getShipment: PropTypes.func
  }).isRequired,
  match: PropTypes.match.isRequired
  // tenant: PropTypes.tenant
}

AdminShipmentView.defaultProps = {
  theme: null,
  hubs: [],
  clients: [],
  shipmentData: null,
  loading: false
  // tenant: {}
}

export default AdminShipmentView
