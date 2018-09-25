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
import {
  gradientTextGenerator,
  gradientGenerator,
  gradientBorderGenerator,
  switchIcon,
  totalPrice
} from '../../../helpers'
import { CargoContainerGroup } from '../../Cargo/Container/Group'
import { AdminShipmentContent } from './AdminShipmentContent'
import { ShipmentQuotationContent } from '../../UserAccount/ShipmentQuotationContent'

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
        customs: AdminShipmentView.checkSelectedOffer(shipment.selected_offer.customs),
        import: AdminShipmentView.checkSelectedOffer(shipment.selected_offer.import),
        export: AdminShipmentView.checkSelectedOffer(shipment.selected_offer.export)
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
    this.handlePriceChange = this.handlePriceChange.bind(this)
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
      <div className="flex-100 layout-row layout-wrap layout-align-start-start header_buffer">
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
          {shipment.status !== 'quoted' ? (
            <AdminShipmentContent
              theme={theme}
              gradientBorderStyle={gradientBorderStyle}
              gradientStyle={gradientStyle}
              switchIcon={switchIcon}
              etdJSX={etdJSX}
              etaJSX={etaJSX}
              shipment={shipment}
              bg1={bg1}
              bg2={bg2}
              dnrEditKeys={dnrEditKeys}
              showEditTime={this.state.showEditTime}
              saveNewTime={this.saveNewTime}
              toggleEditTime={this.toggleEditTime}
              feeHash={feeHash}
              toggleEditServicePrice={this.toggleEditServicePrice}
              showEditServicePrice={showEditServicePrice}
              newPrices={newPrices}
              selectedStyle={selectedStyle}
              deselectedStyle={deselectedStyle}
              cargoCount={cargoCount}
              cargoView={cargoView}
              calcCargoLoad={AdminShipmentView.calcCargoLoad(feeHash, shipment.load_type)}
              contacts={contacts}
              missingDocs={missingDocs}
              docView={docView}
              accountHolder={accountHolder}
              handlePriceChange={this.handlePriceChange}
              saveNewEditedPrice={this.saveNewEditedPrice}
            />
          ) : (
            <ShipmentQuotationContent
              theme={theme}
              gradientBorderStyle={gradientBorderStyle}
              gradientStyle={gradientStyle}
              etdJSX={etdJSX}
              etaJSX={etaJSX}
              shipment={shipment}
              bg1={bg1}
              bg2={bg2}
              selectedStyle={selectedStyle}
              deselectedStyle={deselectedStyle}
              feeHash={feeHash}
              cargoView={cargoView}
            />
          )}

        </div>

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
