import React, { Component } from 'react'
import { v4 } from 'uuid'
import { withNamespaces } from 'react-i18next'
import { pick, uniqWith } from 'lodash'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import { formatDate, parseDate } from 'react-day-picker/moment'
import CargoItemGroup from '../../Cargo/Item/Group'
import CargoItemGroupAggregated from '../../Cargo/Item/Group/Aggregated'
import PropTypes from '../../../prop-types'
import { moment } from '../../../constants'
import adminStyles from '../Admin.scss'
import styles from '../AdminShipments.scss'
import GradientBorder from '../../GradientBorder'
import DocumentsDownloader from '../../Documents/Downloader'
import {
  gradientTextGenerator,
  gradientGenerator,
  gradientBorderGenerator,
  switchIcon,
  totalPrice,
  isRequested,
  formattedDate,
  isQuote
} from '../../../helpers'
import CargoContainerGroup from '../../Cargo/Container/Group'
import AdminShipmentContent from './AdminShipmentContent'
import ShipmentQuotationContent from '../../UserAccount/ShipmentQuotationContent'
import StatusSelectButton from '../../StatusSelectButton'

class AdminShipmentView extends Component {
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
        },
        pickupDate: {
          day: new Date(moment(shipment.planned_pickup_date).format())
        },
        originDropOffDate: {
          day: new Date(moment(shipment.planned_origin_drop_off_date).format())
        },
        deliveryDate: {
          day: new Date(moment(shipment.planned_delivery_date).format())
        },
        destinationCollectionDate: {
          day: new Date(moment(shipment.planned_destination_collection_date).format())
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

  handlePriceChange (key, value) {
    this.setState(prevState => ({
      newPrices: {
        ...prevState.newPrices,
        [key]: {
          ...prevState.newPrices[key],
          value
        }
      }
    }))
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
    const { scope, theme, shipmentData } = this.props
    const { cargoItemTypes, hsCodes, shipment } = shipmentData
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
            parseFloat(c.dimension_z) /
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
        shipment={shipment}
        group={cargoGroups[k]}
        theme={theme}
        hsCodes={hsCodes}
        scope={scope}
        hideUnits={scope.cargo_overview_only}
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

    return Object.keys(cargoGroups).map(prop => (
      <CargoContainerGroup
        key={v4()}
        group={cargoGroups[prop]}
        theme={theme}
        hsCodes={hsCodes}
        shipment={shipment}
      />
    ))
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
    const newPickupDate = moment(newTimes.pickupDate.day)
      .startOf('day')
      .format('lll')
    const newOriginDropOffDate = moment(newTimes.originDropOffDate.day)
      .startOf('day')
      .format('lll')
    const newDeliveryDate = moment(newTimes.deliveryDate.day)
      .startOf('day')
      .format('lll')
    const newDestinationCollectionDate = moment(newTimes.destinationCollectionDate.day)
      .startOf('day')
      .format('lll')

    const timeObj = {
      newEta,
      newEtd,
      newPickupDate,
      newOriginDropOffDate,
      newDeliveryDate,
      newDestinationCollectionDate

    }

    shipment.planned_eta = moment(newTimes.eta.day)
    shipment.planned_etd = moment(newTimes.etd.day)
    shipment.planned_pickup_date = moment(newTimes.pickupDate.day)
    shipment.planned_origin_drop_off_date = moment(newTimes.originDropOffDate.day)
    shipment.planned_delivery_date = moment(newTimes.deliveryDate.day)
    shipment.planned_destination_collection_date = moment(newTimes.destinationCollectionDate.day)
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
      theme, hubs, shipmentData, clients, t, adminDispatch, scope, remarkDispatch
    } = this.props

    if (!shipmentData || !hubs || !clients) {
      return <h1>NO DATA</h1>
    }
    const {
      shipment,
      cargoItems,
      containers,
      aggregatedCargo
    } = shipmentData
    const {
      showEditTime, showEditServicePrice, newTimes, newPrices, currentStatus
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
    const background = {
      bg1,
      bg2
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

    const statusRequested =
      (isRequested(shipment.status)) ? (
        <div style={gradientStyle} className={`layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25 layout-align-center-center ${adminStyles.header_margin_buffer}  ${styles.status_box_process}`}>
          <p className="layout-align-center-center layout-row">
            {' '}
            {t('common:requested')}
            {' '}
          </p>
        </div>) : (
        ''
      )

    const statusInProcess = (shipment.status === 'confirmed') ? (
      <div style={gradientStyle} className={`layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25 layout-align-center-center ${adminStyles.header_margin_buffer}  ${styles.status_box_process}`}>
        <p className="layout-align-center-center layout-row">
          {' '}
          {t('common:inProcess')}
          {' '}
        </p>
      </div>
    ) : (
      ''
    )

    const statusFinished = (shipment.status === 'finished') ? (
      <div className={`${adminStyles.border_box} layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25 layout-align-center-center ${adminStyles.header_margin_buffer}  ${styles.status_box}`}>
        <p className="layout-align-center-center layout-row">
          {' '}
          {t('common:finished')}
          {' '}
        </p>
      </div>
    ) : (
      ''
    )

    const statusArchived = (shipment.status === 'archived') ? (
      <div className={`${adminStyles.border_box} layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25 layout-align-center-center ${adminStyles.header_margin_buffer}  ${styles.status_box}`}>
        <p className="layout-align-center-center layout-row">
          {' '}
          {t('common:archived')}
          {' '}
        </p>
      </div>
    ) : (
      ''
    )

    const statusRejected = (shipment.status === 'ignored') ? (
      <GradientBorder
        wrapperClassName={`
          layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25
          ${adminStyles.header_margin_buffer} ${styles.status_box_requested}`}
        gradient={gradientBorderStyle}
        className="layout-row flex-100 layout-align-center-center"
        content={(
          <p className="layout-align-center-center layout-row">
            {' '}
            {t('common:rejected')}
            {' '}
          </p>
        )}
      />
    ) : (
      ''
    )


    const actionDropDown = isQuote({scope}) ? '' : (
      <div className="layout-row flex-15 flex-md-20 flex-sm-25 flex-xs-30 layout-align-center-center ">
        <StatusSelectButton
          options={this.statusOptions}

          gradient
          theme={theme}
          wrapperStyles={` ${styles.status_box}`}
        />
      </div>

    )

    const feeHash = shipment.selected_offer

    const dayPickerPropsPickupDate = {
      disabledDays: {
        after: newTimes.etd.day
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

    const dayPickerPropsOriginDropOffDate = {
      disabledDays: {
        after: newTimes.etd.day
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

    const dayPickerPropsEtd = {
      disabledDays: {
        after: newTimes.eta.day,
        before: (newTimes.originDropOffDate.day || newTimes.pickupDate.day)
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
        before: newTimes.etd.day,
        after: (newTimes.destinationCollectionDate.day || newTimes.deliveryDate.day)
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

    const dayPickerPropsDestinationCollectionDate = {
      disabledDays: {
        before: newTimes.eta.day
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

    const dayPickerPropsDeliveryDate = {
      disabledDays: {
        before: newTimes.eta.day
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

    const pickupDate = showEditTime && shipment.planned_pickup_date ? (
      <div className="layout-row flex-100">
        <div className="flex-65 layout-row">
          <DayPickerInput
            name="dayPicker"
            placeholder="DD/MM/YYYY"
            format="DD/MM/YYYY"
            formatDate={formatDate}
            parseDate={parseDate}
            value={newTimes.pickupDate.day}
            onDayChange={e => this.handleDayChange(e, 'pickupDate')}
            dayPickerProps={dayPickerPropsPickupDate}
          />
        </div>
      </div>
    ) : (
      <p className={`flex-none letter_3 ${styles.date}`}>
        {`${formattedDate(shipment.planned_pickup_date)}`}
      </p>
    )

    const originDropOffDate = showEditTime && shipment.planned_origin_drop_off_date ? (
      <div className="layout-row flex-100">
        <div className="flex-65 layout-row">
          <DayPickerInput
            name="dayPicker"
            placeholder="DD/MM/YYYY"
            format="DD/MM/YYYY"
            formatDate={formatDate}
            parseDate={parseDate}
            value={newTimes.originDropOffDate.day}
            onDayChange={e => this.handleDayChange(e, 'originDropOffDate')}
            dayPickerProps={dayPickerPropsOriginDropOffDate}
          />
        </div>
      </div>
    ) : (
      <p className={`flex-none letter_3 ${styles.date}`}>
        {`${formattedDate(shipment.planned_origin_drop_off_date)}`}
      </p>
    )

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
        {`${formattedDate(shipment.planned_etd)}`}
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
        {`${formattedDate(shipment.planned_eta)}`}
      </p>
    )
    const estimatedTimes = {
      etdJSX,
      etaJSX
    }

    const destinationCollectionDate = showEditTime && shipment.planned_destination_collection_date ? (
      <div className="layout-row flex-100">
        <div className="flex-65 layout-row">
          <DayPickerInput
            name="dayPicker"
            placeholder="DD/MM/YYYY"
            format="DD/MM/YYYY"
            formatDate={formatDate}
            parseDate={parseDate}
            value={newTimes.destinationCollectionDate.day}
            onDayChange={e => this.handleDayChange(e, 'destinationCollectionDate')}
            dayPickerProps={dayPickerPropsDestinationCollectionDate}
          />
        </div>
      </div>
    ) : (
      <p className={`flex-none letter_3 ${styles.date}`}>
        from
        {' '}
        {`${formattedDate(moment(shipment.planned_destination_collection_date))}`}
      </p>
    )

    const deliveryDate = showEditTime && shipment.planned_delivery_date ? (
      <div className="layout-row flex-100">
        <div className="flex-65 layout-row">
          <DayPickerInput
            name="dayPicker"
            placeholder="DD/MM/YYYY"
            format="DD/MM/YYYY"
            formatDate={formatDate}
            parseDate={parseDate}
            value={newTimes.deliveryDate.day}
            onDayChange={e => this.handleDayChange(e, 'deliveryTime')}
            dayPickerProps={dayPickerPropsDeliveryDate}
          />
        </div>
      </div>
    ) : (
      <p className={`flex-none letter_3 ${styles.date}`}>
        {`${formattedDate(shipment.planned_delivery_date)}`}
      </p>
    )
    const dnrEditKeys = ['in_process', 'finished', 'confirmed']

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start header_buffer">
        <div className={`${adminStyles.margin_box_right} layout-row flex-100 layout-wrap layout-align-center-stretch margin_bottom`}>
          <div className={`layout-row flex flex-sm-100 layout-align-space-between-center ${adminStyles.title_shipment_grey}`}>
            <p className="layout-align-start-center layout-row">
Ref:&nbsp;
              {' '}
              <span>{shipment.imc_reference}</span>
            </p>
            <p className="layout-row layout-align-end-end">
              <strong>Placed at:&nbsp;</strong>
              {' '}
              {createdDate}
            </p>
          </div>
          {statusRequested}
          {statusInProcess}
          {statusFinished}
          {statusRejected}
          {statusArchived}
          {actionDropDown}
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-start-start padding_top">
          {shipment.status !== 'quoted' ? (
            <AdminShipmentContent
              theme={theme}
              gradientBorderStyle={gradientBorderStyle}
              gradientStyle={gradientStyle}
              switchIcon={switchIcon}
              estimatedTimes={estimatedTimes}
              pickupDate={pickupDate}
              deliveryDate={deliveryDate}
              originDropOffDate={originDropOffDate}
              destinationCollectionDate={destinationCollectionDate}
              totalPrice={totalPrice}
              background={background}
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
              cargoView={cargoView}
              shipmentData={shipmentData}
              handlePriceChange={this.handlePriceChange}
              saveNewEditedPrice={this.saveNewEditedPrice}
              adminDispatch={adminDispatch}
              remarkDispatch={remarkDispatch}
              scope={scope}
            />
          ) : (
            <ShipmentQuotationContent
              theme={theme}
              gradientBorderStyle={gradientBorderStyle}
              gradientStyle={gradientStyle}
              estimatedTimes={estimatedTimes}
              showBreakdowns
              scope={scope}
              shipment={shipment}
              background={background}
              selectedStyle={selectedStyle}
              deselectedStyle={deselectedStyle}
              feeHash={feeHash}
              cargo={cargoItems || containers}
              cargoView={cargoView}
              remarkDispatch={remarkDispatch}
            />
          )}

        </div>

        {shipment.status !== 'quoted' ? (
          <div className="flex-100 layout-row layout-wrap">
            <div className="layout-row flex-100 layout-wrap layout-align-center-center" style={{ paddingTop: '30px' }}>
              <p
                className="flex-100 layout-row layout-align-center-center"
                style={{ paddingBottom: '14px', textAlign: 'center' }}
              >
                Download shipment pdf
              </p>
              <DocumentsDownloader
                theme={theme}
                target="shipment_recap"
                options={{ shipment }}
                size="full"
                shipment={shipment}
              />
            </div>
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
  match: PropTypes.match.isRequired,
  t: PropTypes.func,
  scope: PropTypes.objectOf(PropTypes.any)
}

AdminShipmentView.defaultProps = {
  theme: null,
  hubs: [],
  clients: [],
  shipmentData: null,
  loading: false,
  t: null,
  scope: {}
}

export default withNamespaces('common')(AdminShipmentView)
