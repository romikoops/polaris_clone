import React, { Component } from 'react'
import { v4 } from 'uuid'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import { formatDate, parseDate } from 'react-day-picker/moment'
import { CargoItemGroup } from '../../Cargo/Item/Group'
import CargoItemGroupAggregated from '../../Cargo/Item/Group/Aggregated'
import { CargoContainerGroup } from '../../Cargo/Container/Group'
import PropTypes from '../../../prop-types'
// import { RoundButton } from '../RoundButton/RoundButton'
import { moment, documentTypes } from '../../../constants'
import { gradientTextGenerator, gradientGenerator, switchIcon } from '../../../helpers'
import adminStyles from '../Admin.scss'
// import { NamedSelect } from '../NamedSelect/NamedSelect'
// import { IncotermRow } from '../Incoterm/Row'
// import ShipmentCard from '../ShipmentCard/ShipmentCard'
// import { IncotermExtras } from '../Incoterm/Extras'
import DocumentsForm from '../../Documents/Form'
import styles from '../AdminShipments.scss'
// import admin from '../../reducers/admin.reducer'

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
  constructor (props) {
    super(props)
    this.state = {
      showEditPrice: false,
      newTotal: 0,
      showEditTime: false,
      newTimes: {
        eta: {
          day: new Date(moment(this.props.shipmentData.shipment.planned_eta).format())
        },
        etd: {
          day: new Date(moment(this.props.shipmentData.shipment.planned_etd).format())
        }
      }
    }
    this.handleDeny = this.handleDeny.bind(this)
    this.handleAccept = this.handleAccept.bind(this)
    this.toggleEditPrice = this.toggleEditPrice.bind(this)
    this.toggleEditTime = this.toggleEditTime.bind(this)
    this.saveNewPrice = this.saveNewPrice.bind(this)
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
  toggleEditPrice () {
    this.setState({ showEditPrice: !this.state.showEditPrice })
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
      showEditTime, newTimes
    } = this.state
    const hubsObj = {
      startHub: {
        data: locations.origin
      },
      endHub: {
        data: locations.destination
      }
    }

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
      ...gradientTextGenerator('rgb(0, 0, 0)', 'rgb(25, 25, 25)'),
      opacity: '0.5'
    }

    const nArray = []
    const docView = []
    let shipperContact = ''
    let consigneeContact = ''
    if (contacts) {
      contacts.forEach((n) => {
        if (n.type === 'notifyee') {
          nArray.push(<div className={`${styles.contact_box} ${styles.notifyee_box} flex-100 layout-wrap layout-column`}>
            <div className="layout-column flex">
              <div className={`${styles.info_row} flex-100 layout-row`}>
                <i className={`${adminStyles.icon} fa fa-user flex-none`} style={selectedStyle} />
                <h4>{n.contact.first_name} {n.contact.last_name}</h4>
              </div>
              <div className={`${styles.info_row} flex-100 layout-row`}>
                <i className={`${adminStyles.icon} fa fa-building flex-none`} style={selectedStyle} />
                <p>{n.contact.company_name}</p>
              </div>
            </div>
          </div>)
          if (nArray.length % 2 === 1) {
            nArray.push(<div key={v4()} className="flex-45 layout-row" />)
          }
        }
        if (n.type === 'shipper') {
          shipperContact = (
            <div className={`${styles.contact_box} flex-100 layout-wrap layout-column`}>
              <div className="layout-column layout-sm-row flex-sm-100">
                <div className="layout-sm-column flex-sm-30">
                  <div className={`${styles.info_row} flex-100 layout-row`}>
                    <i className={`${adminStyles.icon} fa fa-user flex-none`} style={selectedStyle} />
                    <h4>{n.contact.first_name} {n.contact.last_name}</h4>
                  </div>
                  <div className={`${styles.info_row} ${styles.padding_bottom_contact} flex-100 layout-row`}>
                    <i className={`${adminStyles.icon} fa fa-building flex-none`} style={selectedStyle} />
                    <p>{n.contact.company_name}</p>
                  </div>
                </div>
                <div className="layout-sm-column flex-sm-40">
                  <div className={`${styles.info_row} flex-100 layout-row`}>
                    <i className={`${adminStyles.icon} fa fa-envelope flex-none`} style={selectedStyle} />
                    <p>{n.contact.email}</p>
                  </div>
                  <div className={`${styles.info_row} flex-100 layout-row`}>
                    <i className={`${adminStyles.icon} fa fa-phone flex-none`} style={selectedStyle} />
                    <p>{n.contact.phone}</p>
                  </div>
                </div>
                <div className={`${styles.info_row} ${styles.last_margin} flex-100 layout-row layout-align-sm-center-center flex-sm-30`}>
                  <i className={`${adminStyles.icon} fa fa-map flex-none`} style={selectedStyle} />
                  <p>{n.location ? `${n.location.street} ${n.location.street_number}` : ''} <br />
                    <strong>{n.location ? `${n.location.zip_code} ${n.location.city}` : ''}</strong> <br />
                    {/* {n.location ? `${n.location.country}` : ''} */}
                  </p>
                </div>
              </div>
            </div>
          )
        }
        if (n.type === 'consignee') {
          consigneeContact = (
            <div className={`${styles.contact_box} flex-100 layout-wrap layout-column`}>
              <div className="layout-column layout-sm-row flex-sm-100">
                <div className="layout-sm-column flex-sm-30">
                  <div className={`${styles.info_row} flex-100 layout-row`}>
                    <i className={`${adminStyles.icon} fa fa-user flex-none layout-align-center-center`} style={selectedStyle} />
                    <h4>{n.contact.first_name} {n.contact.last_name}</h4>
                  </div>
                  <div className={`${styles.info_row} ${styles.padding_bottom_contact} flex-100 layout-row`}>
                    <i className={`${adminStyles.icon} fa fa-building flex-none`} style={selectedStyle} />
                    <p>{n.contact.company_name}</p>
                  </div>
                </div>
                <div className="layout-sm-column flex-sm-40">
                  <div className={`${styles.info_row} flex-100 layout-row`}>
                    <i className={`${adminStyles.icon} fa fa-envelope flex-none`} style={selectedStyle} />
                    <p>{n.contact.email}</p>
                  </div>
                  <div className={`${styles.info_row} flex-100 layout-row`}>
                    <i className={`${adminStyles.icon} fa fa-phone flex-none`} style={selectedStyle} />
                    <p>{n.contact.phone}</p>
                  </div>
                </div>
                <div className={`${styles.info_row} ${styles.last_margin} flex-100 layout-row layout-align-sm-center-center flex-sm-30`}>
                  <i className={`${adminStyles.icon} fa fa-map flex-none`} style={selectedStyle} />
                  <p>{n.location ? `${n.location.street} ${n.location.street_number}` : ''} <br />
                    <strong>{n.location ? `${n.location.zip_code} ${n.location.city}` : ''}</strong> <br />
                    {/* {n.location ? `${n.location.country}` : ''} */}
                  </p>
                </div>
              </div>
            </div>
          )
        }
      })
    }
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
      <div style={gradientStyle} className={`layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25 layout-align-center-center ${styles.status_box_requested}`}>
        <p className="layout-align-center-center layout-row"> {shipment.status} </p>
        <div className="lol" />
      </div>
    ) : (
      ''
    )

    const statusInProcess = (shipment.status === 'in_process') ? (
      <div style={gradientStyle} className={`layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25 layout-align-center-center ${styles.status_box_process}`}>
        <p className="layout-align-center-center layout-row"> {shipment.status} </p>
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
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className={`${adminStyles.margin_box_right} layout-row flex-100`}>
          <div className={`layout-row flex-85 flex-md-75 flex-sm-70 flex-xs-40 layout-align-start-center ${adminStyles.title_grey}`}>
            <p className="layout-align-start-center layout-row">Shipment</p>
          </div>
          {statusRequested}
          {statusInProcess}
          {statusFinished}
          <div className={`layout-row flex-5 flex-md-10 flex-sm-10 flex-xs-15 layout-align-space-around-center ${adminStyles.border_box}`}>
            <i className={`fa fa-check ${styles.light_green}`} onClick={this.handleAccept} />
            <i className={`fa fa-trash ${styles.light_red}`} onClick={this.handleDeny} />
          </div>
        </div>

        <div className={`flex-100 layout-row layout-wrap layout-align-center-center ${styles.ref_row}`}>
          <p className="layout-row flex-md-30 flex-20">Ref:&nbsp; <span>{shipment.imc_reference}</span></p>
          <hr className="layout-row flex-md-40 flex-55" />
          <p className="layout-row flex-md-30 flex-25 layout-align-end-center"><strong>Placed at:&nbsp;</strong> {createdDate}</p>
        </div>
        <div className={`layout-row flex-100 ${adminStyles.margin_bottom}`}>
          <div className={`layout-row flex-40 ${styles.hub_box_shipment}`}>
            <div className={`${styles.info_hub_box} flex-60 layout-column`}>
              <h3>{hubsObj.startHub.data.name}</h3>
              <p className={styles.address}>{hubsObj.startHub.data.geocoded_address}</p>
              <div className="layout-row layout-align-start-center">
                <div className="layout-column flex-60 layout-align-center-start">
                  <span>
                    ETD
                  </span>
                  <div className="layout-row layout-align-start-center">
                    {etdJSX}
                  </div>
                </div>
                <div className="layout-row flex-40 layout-align-center-stretch">
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
            <div className={`layout-column flex-40 ${styles.image}`} style={bg1} />
            <div className="flex-30 layout-row">
              <i className="flex-none fa fa-check-square" />
              <h4>Pick-up</h4>
            </div>
          </div>
          <div className="layout-row flex-20 layout-align-center-center">
            <div className={`layout-column flex layout-align-center-center ${styles.font_adjustaments}`}>
              <div className="layout-align-center-center layout-row" style={gradientStyle}>
                {switchIcon()}
              </div>
              <p className="">Estimated time delivery</p>
              <h5>{moment(schedules[0].eta).diff(moment(schedules[0].etd), 'days')} days{' '}</h5>
            </div>
          </div>
          <div className={`layout-row flex-40 ${styles.hub_box_shipment}`}>
            <div className={`${styles.info_hub_box} flex-60 layout-column`}>
              <h3>{hubsObj.endHub.data.name}</h3>
              <p className={styles.address}>{hubsObj.endHub.data.geocoded_address}</p>
              <div className="layout-row layout-align-start-center">
                <div className="layout-column flex-60 layout-align-center-start">
                  <span>ETA</span>
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
        </div>

        <div className={`flex-100 layout-row layout-align-space-between-start ${styles.info_delivery} ${adminStyles.margin_bottom}`}>
          <div className="layout-column flex-60 layout-align-center-stretch">
            <div className="layout-row flex-100 layout-align-start-start">
              <i className="flex-5 fa fa-check-square" style={shipment.pickup_address ? selectedStyle : { color: '#E0E0E0' }} />
              <div className="flex-95 layout-column">
                <h4>Pick-up</h4>
                <div className="layout-row flex-100 layout-align-start-start">
                  {shipment.pickup_address ? (
                    <div
                      className="layout-row flex-offset-10 flex-50 flex-md-60
                          flex-sm-80 layout-align-start-center"
                    >
                      <i className={`fa fa-map-marker ${styles.markerIcon}`} style={selectedStyle} />
                      <span className={`${styles.smallText}`}>
                        {shipment.pickup_address}
                      </span>
                    </div>
                  ) : ''}
                </div>
              </div>
            </div>
          </div>
          <div className="layout-column flex-40 layout-align-center-stretch">
            <div className="layout-row flex-100 layout-align-start-center">
              <i className="flex-5 fa fa-check-square" style={shipment.delivery_address ? selectedStyle : { color: '#E0E0E0' }} />
              <div className="flex-95 layout-column">
                <h4>Delivery</h4>
                <div className="layout-row flex-100 layout-align-start-start">
                  {shipment.delivery_address ? (
                    <div
                      className="layout-row flex-offset-10 flex-50 flex-md-60
                          flex-sm-80 layout-align-start-center"
                    >
                      <i className={`fa fa-map-marker ${styles.markerIcon}`} style={selectedStyle} />
                      <span className={`${styles.smallText}`}>
                        {shipment.delivery_address}
                      </span>
                    </div>
                  ) : ''}
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className={`${adminStyles.border_box} ${adminStyles.margin_bottom} layout-sm-column layout-xs-column layout-row flex-100`}>
          <div className={`flex-50 flex-sm-100 flex-xs-100 layout-row ${styles.services_box}`}>
            <div className="layout-column flex-100">
              <h3>Freight, Duties & Carriage:</h3>
              <div className="layout-wrap layout-row flex">
                <div className={`layout-row flex-50 ${adminStyles.margin_bottom}`}>
                  <i className="fa fa-truck clip flex-none layout-align-center-center" style={shipment.has_pre_carriage ? selectedStyle : deselectedStyle} />
                  <p>Pre-Carriage</p>
                </div>
                <div className={`layout-row flex-50 ${adminStyles.margin_bottom}`}>
                  <i className="fa fa-truck clip flex-none layout-align-center-center" style={shipment.has_on_carriage ? selectedStyle : deselectedStyle} />
                  <p>On-Carriage</p>
                </div>
                <div className={`layout-row flex-50 ${adminStyles.margin_bottom}`}>
                  <i className="fa fa-file-text clip flex-none layout-align-center-center" style={shipment.has_pre_carriage ? selectedStyle : deselectedStyle} />
                  <p>Origin Documentation</p>
                </div>
                <div className={`layout-row flex-50 ${adminStyles.margin_bottom}`}>
                  <i className="fa fa-file-text-o clip flex-none layout-align-center-center" style={shipment.has_on_carriage ? selectedStyle : deselectedStyle} />
                  <p>Destination Documentation</p>
                </div>
                <div className={`layout-row flex-50 ${adminStyles.margin_bottom}`}>
                  <i className="fa fa-ship clip flex-none layout-align-center-center" style={selectedStyle} />
                  <p>Freight</p>
                </div>
              </div>
            </div>
          </div>
          <div className={`flex-30 layout-row flex-sm-100 flex-xs-100 ${styles.additional_services} ${styles.services_box} ${styles.border_right}`}>
            <div className="layout-column flex-100">
              <h3>Additional Services</h3>
              <div className="">
                <div className={`layout-row flex-50 ${adminStyles.margin_bottom}`}>
                  <i className="fa fa-id-card clip flex-none" style={tenant.data.detailed_billing && feeHash.customs ? selectedStyle : deselectedStyle} />
                  <p>Customs</p>
                </div>
                <div className={`layout-row flex-50 ${adminStyles.margin_bottom}`}>
                  <i className="fa fa-umbrella clip flex-none" style={tenant.data.detailed_billing && feeHash.customs ? selectedStyle : deselectedStyle} />
                  <p>Insurance</p>
                </div>
              </div>
            </div>
          </div>
          <div className={`flex-20 flex-sm-100 flex-xs-100 layout-row layout-align-center-center layout-padding ${styles.services_box}`}>
            <div className="layout-column flex-100">
              <div className="layout-row layout-align-sm-end-center layout-align-xs-end-center flex-100">
                <span style={gradientStyle} className={`layout-align-center-center layout-row flex-20 flex-sm-5 flex-xs-5 ${styles.quantity_square}`}>x1</span>
                <p className="layout-align-sm-end-center layout-align-xs-end-center">Cargo items</p>
              </div>
              <h2 className="layout-align-end-center layout-row flex">{(+feeHash.total.value).toFixed(2)} {shipment.total_goods_value.currency}</h2>
            </div>
          </div>
        </div>

        <div className={`layout-row layout-xs-column layout-sm-column ${adminStyles.margin_bottom} ${adminStyles.margin_box_right}`}>
          <div className={`${adminStyles.border_box} layout-row flex-lg-40 flex-gt-sm-100`}>
            <div className="layout-row layout-wrap flex-100">
              <p className={`layout-align-start-center flex-100 layout-row ${adminStyles.title_grey}`}>Shipper</p>
              {shipperContact}
            </div>
          </div>
          <div className={`${adminStyles.border_box} layout-row flex-lg-40 flex-gt-sm-100`}>
            <div className="layout-row layout-wrap flex-100">
              <p className={`layout-align-start-center flex-100 layout-row ${adminStyles.title_grey}`}>Consignee</p>
              {consigneeContact}
            </div>
          </div>
          <div className={`${adminStyles.border_box} layout-row flex-lg-20 flex-gt-sm-100`}>
            <div className="layout-row layout-wrap flex-100">
              <p className={`layout-align-start-center flex-100 layout-row ${adminStyles.title_grey}`}>Notifyees</p>
              {nArray}
            </div>
          </div>
        </div>
        <div className={`layout-row flex-100 ${adminStyles.border_box} ${adminStyles.no_margin_box_right}`}>
          <div className="layout-column flex">
            <p className={`layout-align-start-center flex layout-row ${adminStyles.title_grey}`}>Cargo Details</p>
            <div className="flex-100 layout-row layout-wrap layout-align-start-stretch">
              {cargoView}
            </div>
          </div>
        </div>
        <div className={`layout-row layout-wrap layout-sm-column layout-xs-column flex-100 ${adminStyles.border_box} ${styles.no_border_top} ${adminStyles.margin_bottom} ${adminStyles.no_margin_box_right}`}>
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
        <div className={`layout-row flex-100 ${adminStyles.border_box} ${adminStyles.no_margin_box_right}`}>
          <div className="layout-column flex">
            <p className={`layout-align-start-center flex layout-row ${adminStyles.title_grey}`}>Documents</p>
            <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${adminStyles.padding_left}`}>
              {missingDocs}
            </div>
          </div>
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
        <div className={`flex-100 layout-row layout-align-center-center ${adminStyles.button_row}`}>
          <button style={gradientStyle} onClick={this.handleAccept}>Accept</button>
          <button onClick={this.handleDeny}>Refuse</button>
        </div>
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
