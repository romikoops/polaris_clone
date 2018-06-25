import React, { Component } from 'react'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import { formatDate, parseDate } from 'react-day-picker/moment'
import { CargoItemGroup } from '../../Cargo/Item/Group'
import CargoItemGroupAggregated from '../../Cargo/Item/Group/Aggregated'
import { CargoContainerGroup } from '../../Cargo/Container/Group'
import PropTypes from '../../../prop-types'
import { moment, documentTypes } from '../../../constants'
import {
  gradientTextGenerator,
  gradientGenerator,
  gradientBorderGenerator,
  switchIcon
} from '../../../helpers'
import adminStyles from '../Admin.scss'
import styles from '../AdminShipments.scss'
import DocumentsForm from '../../Documents/Form'
import GradientBorder from '../../GradientBorder'
import ShipmentOverviewShowCard from './ShipmentOverviewShowCard'
import ContactDetailsRow from './ContactDetailsRow'
import AlternativeGreyBox from '../../GreyBox/AlternativeGreyBox'

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
    if (loadType === 'cargo_item' && cargoCount > 2) {
      noun = 'Cargo Items'
    } else if (loadType === 'cargo_item' && cargoCount === 2) {
      noun = 'Cargo Item'
    } else if (loadType === 'container' && cargoCount > 2) {
      noun = 'Containers'
    } else if (loadType === 'container' && cargoCount === 2) {
      noun = 'Container'
    }

    return `${noun}`
  }
  constructor (props) {
    super(props)
    this.state = {
      showEditPrice: false,
      showEditServicePrice: false,
      newTotal: 0,
      showEditTime: false,
      currency: this.props.shipmentData.shipment.selected_offer.total.currency,
      newTimes: {
        eta: {
          day: new Date(moment(this.props.shipmentData.shipment.planned_eta).format())
        },
        etd: {
          day: new Date(moment(this.props.shipmentData.shipment.planned_etd).format())
        }
      },
      newPrices: {
        trucking_pre: this.props.shipmentData.shipment.selected_offer.trucking_pre.edited_total
          ? this.props.shipmentData.shipment.selected_offer.trucking_pre.edited_total.value
          : this.props.shipmentData.shipment.selected_offer.trucking_pre.total.value,
        trucking_on: this.props.shipmentData.shipment.selected_offer.trucking_on.edited_total
          ? this.props.shipmentData.shipment.selected_offer.trucking_on.edited_total.value
          : this.props.shipmentData.shipment.selected_offer.trucking_pre.total.value,
        cargo: this.props.shipmentData.shipment.selected_offer.cargo.edited_total
          ? this.props.shipmentData.shipment.selected_offer.cargo.edited_total.value
          : this.props.shipmentData.shipment.selected_offer.trucking_pre.total.value,
        insurance: this.props.shipmentData.shipment.selected_offer.insurance.edited_total
          ? this.props.shipmentData.shipment.selected_offer.insurance.edited_total.value
          : this.props.shipmentData.shipment.selected_offer.trucking_pre.total.value
      },
      totalPrice: this.props.shipmentData.shipment.total_price.value
    }
    this.handleDeny = this.handleDeny.bind(this)
    this.handleAccept = this.handleAccept.bind(this)
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
    const { shipmentData, handleShipmentAction } = this.props
    handleShipmentAction(shipmentData.shipment.id, 'decline')
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
        [key]: value
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
      resultArray
        .push(<CargoContainerGroup group={cargoGroups[k]} theme={theme} hsCodes={hsCodes} />)
    })

    return resultArray
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

    let difference = 0

    Object.keys(newPrices).forEach((k) => {
      const service = shipmentData.shipment.selected_offer[k]

      if (newPrices[k] !== 0 && service.total && service.total.value &&
        newPrices[k] !== service.total.value) {
        difference += (newPrices[k] - service.total.value)

        adminDispatch.editShipmentServicePrice(shipmentData.shipment.id, {
          value: newPrices[k],
          currency,
          charge_category: k
        })
      }
    })

    this.setState({
      totalPrice: parseFloat(shipmentData.shipment.total_price.value) + difference
    })

    this.toggleEditServicePrice()
  }
  handleNewTotalChange (event) {
    const { value } = event.target
    this.setState({ newTotal: +value })
  }
  render () {
    const {
      theme, hubs, shipmentData, clients, tenant
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
      schedules,
      locations
    } = shipmentData
    const {
      showEditTime, showEditServicePrice, newTimes, newPrices, currency, totalPrice
    } = this.state
    const hubsObj = {
      startHub: {
        data: locations.origin
      },
      endHub: {
        data: locations.destination
      }
    }

    console.log('shipmentData', shipmentData)

    hubs.forEach((c) => {
      if (String(c.data.id) === schedules[0].origin_hub_id) {
        hubsObj.startHub = c
      }
      if (String(c.data.id) === schedules[0].destination_hub_id) {
        hubsObj.endHub = c
      }
    })
    const createdDate = shipment
      ? moment(shipment.updated_at).format('DD-MM-YYYY | HH:mm A')
      : moment().format('DD-MM-YYYY | HH:mm A')
    const bg1 =
      hubsObj.startHub && hubsObj.startHub.location && hubsObj.startHub.location.photo
        ? { backgroundImage: `url(${hubsObj.startHub.location.photo})` }
        : {
          backgroundImage:
            'url("https://assets.itsmycargo.com/assets/default_images/crane_sm.jpg")'
        }
    const bg2 =
      hubsObj.endHub && hubsObj.endHub.location && hubsObj.endHub.location.photo
        ? { backgroundImage: `url(${hubsObj.endHub.location.photo})` }
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
        wrapperClassName={`layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25 ${styles.status_box_requested}`}
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
      <div style={gradientStyle} className={`layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25 layout-align-center-center ${styles.status_box_process}`}>
        <p className="layout-align-center-center layout-row"> In process </p>
      </div>
    ) : (
      ''
    )

    const statusFinished = (shipment.status === 'finished') ? (
      <div style={gradientStyle} className={`layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25 layout-align-center-center ${styles.status_box}`}>
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
        docView.push(<div className="flex-25 layout-padding layout-align-start-center layout-row" style={{ padding: '10px' }}>
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

    const cargoCount = Object.keys(feeHash.cargo).length

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className={`${adminStyles.margin_box_right} layout-row flex-100 layout-align-center-stretch`}>
          <div className={`layout-row flex-85 flex-md-75 flex-sm-70 flex-xs-40 layout-align-start-center ${adminStyles.title_grey}`}>
            <p className="layout-align-start-center layout-row">Shipment</p>
          </div>
          {statusRequested}
          {statusInProcess}
          {statusFinished}
          <div className={`layout-row flex-5 flex-md-10 flex-sm-10 flex-xs-15 layout-align-space-around-center ${adminStyles.border_box} ${adminStyles.action_icons}`}>
            {shipment.status === 'requested' ? (
              <i className={`fa fa-check ${styles.light_green}`} onClick={this.handleAccept} />
            ) : (
              ''
            )}
            <i className={`fa fa-trash ${styles.light_red}`} onClick={this.handleDeny} />
          </div>
        </div>

        <div className={`flex-100 layout-row layout-wrap layout-align-center-center ${styles.ref_row}`}>
          <p className="layout-row flex-md-30 flex-20">Ref:&nbsp; <span>{shipment.imc_reference}</span></p>
          <hr className="layout-row flex-md-40 flex-55" />
          <p className="layout-row flex-md-30 flex-25 layout-align-end-center"><strong>Placed at:&nbsp;</strong> {createdDate}</p>
        </div>
        <div className={`layout-row flex-100 ${adminStyles.margin_bottom}`}>

          <GradientBorder
            wrapperClassName={`layout-row flex-40 ${styles.hub_box_shipment}`}
            gradient={gradientBorderStyle}
            className="layout-row flex"
            content={(
              <div className="layout-row flex-100">
                <ShipmentOverviewShowCard
                  et={etdJSX}
                  hubs={hubsObj}
                  bg={bg1}
                  editTime={this.state.showEditTime}
                  handleSaveTime={this.saveNewTime}
                  toggleEditTime={this.toggleEditTime}
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
              <h5>{moment(schedules[0].eta).diff(moment(schedules[0].etd), 'days')} days{' '}</h5>
            </div>
          </div>

          <GradientBorder
            wrapperClassName={`layout-row flex-40 ${styles.hub_box_shipment}`}
            gradient={gradientBorderStyle}
            className="layout-row flex"
            content={(
              <div className="layout-row flex-100">
                <div className={`${styles.info_hub_box} flex-60 layout-column`}>
                  <h3>{hubsObj.endHub.data.name}</h3>
                  <p className={styles.address}>{hubsObj.endHub.data.geocoded_address}</p>
                  <div className="layout-row layout-align-start-center">
                    <div className="layout-column flex-60 layout-align-center-start">
                      <span>
                        ETD
                      </span>
                      <div className="layout-row layout-align-start-center">
                        {etaJSX}
                      </div>
                    </div>
                    <div className="layout-row flex-40 layout-align-center-center">
                      {this.state.showEditTime ? (
                        <span className="layout-column flex-100 layout-align-center-stretch">
                          <div
                            onClick={this.saveNewTime}
                            className={`layout-row flex-50 ${styles.save} layout-align-center-center`}
                          >
                            <i className="fa fa-check" />
                          </div>
                          <div
                            onClick={this.toggleEditTime}
                            className={`layout-row flex-50 ${styles.cancel} layout-align-center-center`}
                          >
                            <i className="fa fa-times" />
                          </div>
                        </span>
                      ) : (
                        <i onClick={this.toggleEditTime} className={`fa fa-edit ${styles.editIcon}`} />
                      )}
                    </div>
                  </div>
                </div>
                <div className={`layout-column flex-40 ${styles.image}`} style={bg2} />
              </div>
            )}
          />
        </div>

        <div className={`flex-100 layout-row layout-align-space-between-start ${styles.info_delivery} ${adminStyles.margin_bottom}`}>
          <div className="layout-column flex-60 layout-align-center-stretch">
            <div className="layout-row flex-100 layout-align-start-center">
              <i className={`flex-none fa fa-check-square clip ${styles.check_square}`} style={shipment.pickup_address ? selectedStyle : { color: '#E0E0E0' }} />
              <h4 className="flex-95 layout-row">Pick-up</h4>
            </div>
            {shipment.pickup_address ? (
              <div className="flex-100 layout-row">
                <div className="flex-5 layout-row" />
                <hr className="flex-35 layout-row" style={{ border: '1px solid #E0E0E0', width: '100%' }} />
                <div className="flex-60 layout-row" />
              </div>
            ) : (
              ''
            )}
            <div className="flex-100 layout-row">
              <div className="flex-5 layout-row" />
              {shipment.pickup_address ? (
                <div className={`layout-row flex-95 layout-align-start-center ${styles.carriage_address}`}>
                  {/* <i className={`fa fa-map-marker clip ${styles.markerIcon}`} style={selectedStyle} /> */}
                  <p>{shipment.pickup_address.street}
                    {shipment.pickup_address.street_number},&nbsp;
                    <strong>{shipment.pickup_address.city},&nbsp;
                      {shipment.pickup_address.country.name} </strong>
                  </p>
                </div>
              ) : ''}
            </div>
          </div>

          <div className="layout-column flex-40 layout-align-center-stretch">
            <div className="layout-row flex-100 layout-align-start-center">
              <i className={`flex-none fa fa-check-square clip ${styles.check_square}`} style={shipment.delivery_address ? selectedStyle : deselectedStyle} />
              <h4 className="flex-95 layout-row">Delivery</h4>
            </div>
            {shipment.delivery_address ? (
              <div className="flex-100 layout-row">
                <div className="flex-5 layout-row" />
                <hr className="flex-60 layout-row" style={{ border: '1px solid #E0E0E0', width: '100%' }} />
                <div className="flex-30 layout-row" />
              </div>
            ) : (
              ''
            )}
            <div className="flex-100 layout-row">
              <div className="flex-5 layout-row" />
              {shipment.delivery_address ? (
                <div className={`layout-row flex-95 layout-align-start-center ${styles.carriage_address}`}>
                  {/* <i className={`fa fa-map-marker clip ${styles.markerIcon}`} style={selectedStyle} /> */}
                  <p>{shipment.delivery_address.street}
                    {shipment.delivery_address.street_number},&nbsp;
                    <strong>{shipment.delivery_address.city},&nbsp;
                      {shipment.delivery_address.country.name} </strong>

                  </p>
                </div>
              ) : ''}
            </div>
          </div>
        </div>

        <div className={`${adminStyles.border_box} ${adminStyles.margin_bottom} layout-sm-column layout-xs-column layout-row flex-100`}>
          <div className={`flex-50 flex-sm-100 flex-xs-100 layout-row ${styles.services_box}`}>
            <div className="layout-column flex-100">
              <h3>Freight, Duties & Carriage:</h3>
              <div className="layout-wrap layout-row flex">
                <div className={`layout-column flex-45 ${adminStyles.margin_bottom}`}>
                  <div className="layout-row">
                    <i className="fa fa-truck clip flex-none layout-align-center-center" style={shipment.has_pre_carriage ? selectedStyle : deselectedStyle} />
                    <p>Pre-Carriage</p>
                  </div>
                  {showEditServicePrice && shipment.selected_offer.trucking_pre ? (
                    <div className={`layout-row layout-align-end-stretch ${styles.greyborder}`}>
                      <span
                        className={
                          `layout-row flex layout-padding
                          layout-align-center-center ${styles.greybg}`
                        }
                      >
                        {currency}
                      </span>
                      <input
                        type="number"
                        onChange={e => this.handlePriceChange('trucking_pre', e.target.value)}
                        value={Number(newPrices.trucking_pre).toFixed(2)}
                        className="layout-padding flex-initial"
                      />
                    </div>
                  ) : (
                    ''
                  )}
                </div>
                <div className={`layout-column flex-offset-10 flex-45 ${adminStyles.margin_bottom}`}>
                  <div className="layout-row">
                    <i
                      className="fa fa-truck clip flex-none layout-align-center-center"
                      style={shipment.has_on_carriage ? selectedStyle : deselectedStyle}
                    />
                    <p>On-Carriage</p>
                  </div>
                  {showEditServicePrice && shipment.selected_offer.trucking_on ? (
                    <div className={`layout-row layout-align-end-stretch ${styles.greyborder}`}>
                      <span
                        className={
                          `layout-row flex layout-padding
                          layout-align-center-center ${styles.greybg}`
                        }
                      >
                        {currency}
                      </span>
                      <input
                        type="number"
                        onChange={e => this.handlePriceChange('trucking_on', e.target.value)}
                        value={Number(newPrices.trucking_on).toFixed(2)}
                        className="layout-padding flex-initial"
                      />
                    </div>
                  ) : (
                    ''
                  )}
                </div>
                <div className={`layout-column flex-45 ${adminStyles.margin_bottom}`}>
                  <div className="layout-row">
                    <i
                      className="fa fa-file-text clip flex-none layout-align-center-center"
                      style={shipment.has_pre_carriage ? selectedStyle : deselectedStyle}
                    />
                    <p>
                      Origin<br />
                      Documentation
                    </p>
                  </div>
                </div>
                <div
                  className={`layout-column flex-offset-10 flex-45 ${adminStyles.margin_bottom}`}
                >
                  <div className="layout-row">
                    <i
                      className="fa fa-file-text-o clip flex-none layout-align-center-center"
                      style={shipment.has_on_carriage ? selectedStyle : deselectedStyle}
                    />
                    <p>
                      Destination<br />
                      Documentation
                    </p>
                  </div>
                </div>
                <div className={`layout-column flex-45 ${adminStyles.margin_bottom}`}>
                  <div className="layout-row">
                    <i
                      className="fa fa-ship clip flex-none layout-align-center-center"
                      style={selectedStyle}
                    />
                    <p>Freight</p>
                  </div>
                  {showEditServicePrice && shipment.selected_offer.cargo ? (
                    <div className={`layout-row layout-align-end-stretch ${styles.greyborder}`}>
                      <span
                        className={
                          `layout-row flex layout-padding
                          layout-align-center-center ${styles.greybg}`
                        }
                      >
                        {currency}
                      </span>
                      <input
                        type="number"
                        onChange={e => this.handlePriceChange('cargo', e.target.value)}
                        value={Number(newPrices.cargo).toFixed(2)}
                        className="layout-padding flex-initial"
                      />
                    </div>
                  ) : (
                    ''
                  )}
                </div>
              </div>
            </div>
          </div>
          <div className={`flex-30 layout-row flex-sm-100 flex-xs-100 ${styles.additional_services} ${styles.services_box} ${styles.border_right}`}>
            <div className="layout-column flex-80">
              <h3>Additional Services</h3>
              <div className="">
                <div className={`layout-column flex-100 ${adminStyles.margin_bottom}`}>
                  <div className="layout-row">
                    <i className="fa fa-id-card clip flex-none" style={tenant.data.detailed_billing && feeHash.customs ? selectedStyle : deselectedStyle} />
                    <p>Customs</p>
                  </div>
                </div>
                <div className={`layout-column flex-100 ${adminStyles.margin_bottom}`}>
                  <div className="layout-row">
                    <i className="fa fa-umbrella clip flex-none" style={tenant.data.detailed_billing && feeHash.customs ? selectedStyle : deselectedStyle} />
                    <p>Insurance</p>
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
          <div className={`flex-20 flex-sm-100 flex-xs-100 layout-row layout-align-center-center layout-padding ${styles.services_box}`}>
            <div className="layout-column flex-100">
              <div className="layout-row layout-align-sm-end-center layout-align-xs-center-center flex-100">
                <div className="layout-align-center-center layout-row flex">
                  <span style={gradientStyle} className={`layout-align-center-center layout-row flex-20 flex-sm-5 flex-xs-5 ${styles.quantity_square}`}>x&nbsp;{cargoCount}</span>
                  <p className="layout-align-sm-end-center layout-align-xs-end-center">{AdminShipmentView.calcCargoLoad(feeHash, shipment.load_type)}</p>
                </div>
              </div>
              <h2 className="layout-align-end-center layout-row flex">
                {(+totalPrice).toFixed(2)} {shipment.total_goods_value.currency}
              </h2>
            </div>
          </div>
        </div>

        <ContactDetailsRow
          contacts={contacts}
          style={selectedStyle}
        />

        <AlternativeGreyBox
          title="Cargo Details"
          wrapperClassName={`layout-row flex-100 ${adminStyles.no_margin_box_right}`}
          contentClassName="layout-column flex"
          content={cargoView}
        />

        <AlternativeGreyBox
          wrapperClassName={`layout-row layout-wrap layout-sm-column layout-xs-column flex-100
            ${styles.no_border_top} ${adminStyles.margin_bottom} ${adminStyles.no_margin_box_right}`}
          contentClassName="layout-row flex-100"
          content={(
            <div className="layout-column flex-100">
              <div className={`layout-row flex-100 flex-sm-100 flex-xs-100 ${styles.column_info}`}>
                <div className={`flex-33 layout-row offset-5 layout-align-start-center layout-wrap ${styles.border_right}`}>
                  {shipment.total_goods_value ? (
                    <div className="flex-100 layout-xs-column layout-row layout-align-start-start">
                      <span className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row">Total Value of Goods:</span>
                      <p className="flex-60 flex-xs-100 layout-align-xs-start-center layout-row">
                        {shipment.total_goods_value.value}
                        {shipment.total_goods_value.currency}
                      </p>
                    </div>
                  ) : (
                    <div className="flex-100 layout-xs-column layout-row layout-align-start-start">
                      <span className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row">Total Value of Goods:</span>
                      <p className="flex-60 flex-xs-100 layout-align-xs-start-center layout-row">
                          -
                      </p>
                    </div>
                  )}
                </div>
                <div className={`flex-33 layout-row offset-5 layout-align-start-center layout-wrap ${styles.border_right}`}>
                  {shipment.eori ? (
                    <div className="flex-100 layout-xs-column layout-row layout-align-start-start">
                      <span className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row">EORI number:</span>
                      <p className="flex-60 flex-xs-100 layout-align-xs-start-center layout-row">
                        {shipment.eori}
                      </p>
                    </div>
                  ) : (
                    <div className="flex-100 layout-xs-column layout-row layout-align-start-start">
                      <span className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row">EORI number:</span>
                      <p className="flex-60 flex-xs-100 layout-align-xs-start-center layout-row">
                          -
                      </p>
                    </div>
                  )}
                </div>
                <div className="flex-33 layout-row offset-5 layout-align-start-start layout-wrap">
                  {shipment.incoterm_text ? (
                    <div className="flex-100 layout-column layout-align-start-start">
                      <span className="flex-40 flex-xs-100 layout-align-start-center layout-row">Incoterm:</span>
                      <p className="flex-60 flex-xs-100 layout-align-xs-start-center layout-row">
                        {shipment.incoterm_text}
                      </p>
                    </div>
                  ) : (
                    <div className="flex-100 layout-column layout-align-start-start">
                      <span className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row">Incoterm:</span>
                      <p className="flex-60 flex-xs-100 layout-align-xs-start-center layout-row">
                          -
                      </p>
                    </div>
                  )}
                </div>
              </div>
              <div className={`layout-column flex-100 flex-sm-100 flex-xs-100 ${styles.column_info}`}>
                <div className={`${styles.border_bottom} flex-100 flex-sm-100 flex-xs-100 layout-row offset-5 layout-align-start-start layout-wrap`}>
                  {shipment.cargo_notes ? (
                    <div className="flex-100 layout-row layout-align-start-center">
                      <span className="flex-20 layout-row">Description of Goods:</span>
                      <p className="flex-80 layout-padding layout-row">
                        {shipment.cargo_notes}
                      </p>
                    </div>
                  ) : (
                    <div className="flex-100 layout-row layout-align-start-center">
                      <span className="flex-20 layout-row">Description of Goods:</span>
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

        <AlternativeGreyBox
          title="Documents"
          wrapperClassName={`layout-row flex-100 ${adminStyles.no_margin_box_right} ${adminStyles.margin_bottom}`}
          contentClassName="layout-column flex"
          content={(
            <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${adminStyles.padding_left}`}>
              {missingDocs}
            </div>
          )}
        />

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
  match: PropTypes.match.isRequired,
  tenant: PropTypes.tenant
}

AdminShipmentView.defaultProps = {
  theme: null,
  hubs: [],
  clients: [],
  shipmentData: null,
  loading: false,
  tenant: {}
}

export default AdminShipmentView
