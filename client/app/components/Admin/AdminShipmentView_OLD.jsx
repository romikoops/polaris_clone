import React, { Component } from 'react'
import { v4 } from 'uuid'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import { formatDate, parseDate } from 'react-day-picker/moment'
import { CargoItemGroup } from '../Cargo/Item/Group'
import CargoItemGroupAggregated from '../Cargo/Item/Group/Aggregated'
import { CargoContainerGroup } from '../Cargo/Container/Group'
import PropTypes from '../../prop-types'
import { RoundButton } from '../RoundButton/RoundButton'
import { RouteHubBox } from '../RouteHubBox/RouteHubBox'
import { moment, currencyOptions, documentTypes } from '../../constants'
import { capitalize, gradientTextGenerator } from '../../helpers'
import styles from './Admin.scss'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import { IncotermRow } from '../Incoterm/Row'
import CollapsingBar from '../CollapsingBar/CollapsingBar'
import { IncotermExtras } from '../Incoterm/Extras'
import DocumentsForm from '../Documents/Form'

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
        eta: '',
        etd: ''
      },
      collapser: {}
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
  handleCollapser (key) {
    this.setState({
      collapser: {
        ...this.state.collapser,
        [key]: !this.state.collapser[key]
      }
    })
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
      resultArray.push(<CargoItemGroup group={cargoGroups[k]} theme={theme} hsCodes={hsCodes} />)
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
    const etaTimes = newTimes.eta.time.split(':').map(t => parseInt(t, 10))
    const etdTimes = newTimes.etd.time.split(':').map(t => parseInt(t, 10))
    const newEta = moment(newTimes.eta.day)
      .startOf('day')
      .add(etaTimes[0], 'hours')
      .add(etaTimes[1], 'minutes')
      .format('lll')
    const newEtd = moment(newTimes.etd.day)
      .startOf('day')
      .add(etdTimes[0], 'hours')
      .add(etdTimes[1], 'minutes')
      .format('lll')
    const timeObj = { newEta, newEtd }
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
      accountHolder
    } = shipmentData
    const {
      newTotal, showEditPrice, currency, showEditTime, newTimes, collapser
    } = this.state

    const dayPickerProps = {
      disabledDays: {
        before: new Date(moment()
          .add(7, 'days')
          .format())
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
    const createdDate = shipment
      ? moment(shipment.updated_at).format('DD-MM-YYYY | HH:mm A')
      : moment().format('DD-MM-YYYY | HH:mm A')
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }

    const nArray = []
    const docView = []
    const accountHolderBox = accountHolder ? (
      <div className="flex-50 layout-row" style={{ marginLeft: '2.5%' }}>
        <div className="flex-15 layout-column layout-align-start-center">
          <i className={`${styles.icon} fa fa-id-card-o flex-none`} style={textStyle} />
        </div>
        <div className="flex-85 layout-row layout-wrap layout-align-start-start">
          <div className="flex-100">
            <p className="flex-100">Account Holder</p>
          </div>
          <div className="flex-100 layout-row layout-wrap">
            <div className="flex-50 layout-row layout-align-space-around-center">
              <div className="flex-20 layout-row layout-align-center-center">
                <i className="fa clip fa-address-book-o flex-none" style={textStyle} />
              </div>
              <p className="flex-80">
                {accountHolder.first_name} {accountHolder.last_name}
              </p>
            </div>
            <div className="flex-50 layout-row layout-align-space-around-center">
              <div className="flex-20 layout-row layout-align-center-center">
                <i className="fa clip fa-building-o flex-none" style={textStyle} />
              </div>
              <p className="flex-80">{accountHolder.company_name}</p>{' '}
            </div>
            <div className="flex-50 layout-row layout-align-space-around-center">
              <div className="flex-20 layout-row layout-align-center-center">
                <i className="fa clip fa-envelope-o flex-none" style={textStyle} />
              </div>
              <p className="flex-80">{accountHolder.email}</p>{' '}
            </div>
            <div className="flex-50 layout-row layout-align-space-around-center">
              <div className="flex-20 layout-row layout-align-center-center">
                <i className="fa clip fa-mobile flex-none" style={textStyle} />
              </div>
              <p className="flex-80">{accountHolder.phone}</p>
            </div>
          </div>
        </div>
      </div>
    ) : (
      ''
    )
    let shipperContact = ''
    let consigneeContact = ''
    if (contacts) {
      contacts.forEach((n) => {
        if (n.type === 'notifyee') {
          nArray.push(<div key={v4()} className="flex-45 layout-row">
            <div className="flex-15 layout-column layout-align-start-center">
              <i className={` ${styles.icon} fa fa-user-circle-o flex-none`} style={textStyle} />
            </div>
            <div className="flex-85 layout-row layout-wrap layout-align-start-start">
              <p className="flex-100">Notifyee</p>
              <div className="flex-100 layout-row layout-align-space-between-start">
                <div className="flex-60 layout-row layout-wrap layout-align-center-start">
                  <p className={`${styles.contact_text} flex-100`}>
                    {n.contact.first_name} {n.contact.last_name}
                  </p>
                  <p className={`${styles.contact_text} flex-100`}>{n.contact.company_name}</p>
                  <p className={`${styles.contact_text} flex-100`}>{n.contact.email}</p>
                  <p className={`${styles.contact_text} flex-100`}>{n.contact.phone}</p>
                </div>
                <div className="flex-100 layout-row layout-align-space-between-start layout-wrap">
                  <address className={` ${styles.address} flex-100`}>
                    {n.location ? `${n.location.street} ${n.location.street_number}` : ''} <br />
                    {n.location ? `${n.location.zip_code} ${n.location.city}` : ''} <br />
                    {n.location ? `${n.location.country}` : ''}
                  </address>
                </div>
              </div>
            </div>
          </div>)
          if (nArray.length % 2 === 1) {
            nArray.push(<div key={v4()} className="flex-45 layout-row" />)
          }
        }
        if (n.type === 'shipper') {
          shipperContact = (
            <div className="flex-45 layout-row">
              <div className="flex-15 layout-column layout-align-start-center">
                <i className={`${styles.icon} fa fa-user-circle-o flex-none`} style={textStyle} />
              </div>
              <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                <p className="flex-100">Shipper</p>
                <div className="flex-100 layout-row layout-align-space-between-start">
                  <div className="flex-60 layout-row layout-wrap layout-align-center-start">
                    <p className={`${styles.contact_text} flex-100`}>
                      {n.contact.first_name} {n.contact.last_name}
                    </p>
                    <p className={`${styles.contact_text} flex-100`}>{n.contact.company_name}</p>
                    <p className={`${styles.contact_text} flex-100`}>{n.contact.email}</p>
                    <p className={`${styles.contact_text} flex-100`}>{n.contact.phone}</p>
                  </div>
                  <div className="flex-100 layout-row layout-align-space-between-start layout-wrap">
                    <p className={`${styles.contact_text} flex-100`}>Address</p>
                    <address className={` ${styles.address} flex-100`}>
                      {n.location ? `${n.location.street} ${n.location.street_number}` : ''} <br />
                      {n.location ? `${n.location.zip_code} ${n.location.city}` : ''} <br />
                      {n.location ? `${n.location.country}` : ''}
                    </address>
                  </div>
                </div>
              </div>
            </div>
          )
        }
        if (n.type === 'consignee') {
          consigneeContact = (
            <div className="flex-45 layout-row">
              <div className="flex-15 layout-column layout-align-start-center">
                <i className={` ${styles.icon} fa fa-user-circle-o flex-none`} style={textStyle} />
              </div>
              <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                <p className="flex-100">Consignee</p>
                <div className="flex-100 layout-row layout-align-space-between-start">
                  <div className="flex-60 layout-row layout-wrap layout-align-center-start">
                    <p className={`${styles.contact_text} flex-100`}>
                      {n.contact.first_name} {n.contact.last_name}
                    </p>
                    <p className={`${styles.contact_text} flex-100`}>{n.contact.company_name}</p>
                    <p className={`${styles.contact_text} flex-100`}>{n.contact.email}</p>
                    <p className={`${styles.contact_text} flex-100`}>{n.contact.phone}</p>
                  </div>
                  <div className="flex-100 layout-row layout-align-space-between-start layout-wrap">
                    <p className={`${styles.contact_text} flex-100`}>Address</p>
                    <address className={` ${styles.address} flex-100`}>
                      {n.location ? `${n.location.street} ${n.location.street_number}` : ''} <br />
                      {n.location ? `${n.location.zip_code} ${n.location.city}` : ''} <br />
                      {n.location ? `${n.location.country}` : ''}
                    </address>
                  </div>
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

    const docChecker = {
      packing_sheet: false,
      commercial_invoice: false
    }
    const missingDocs = []
    if (documents) {
      documents.forEach((doc) => {
        docChecker[doc.doc_type] = true
        docView.push(<div className="flex-45 layout-row" style={{ padding: '10px' }}>
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
        missingDocs.push(<div className={`flex-25 layout-row layout-align-start-center ${styles.no_doc}`}>
          <div className="flex-none layout-row layout-align-center-center">
            <i className="flex-none fa fa-ban" />
          </div>
          <div className="flex layout-align-start-center layout-row">
            <p className="flex-none">{`${documentTypes[key]}: Not Uploaded`}</p>
          </div>
        </div>)
      }
    })

    const actionsBox =
      shipment && shipment.status === 'requested' ? (
        <div className="flex-100 layout-row layout-align-space-between-center">
          <div className="flex-40 layout-row layout-align-start-center">
            <h4 className="flex-none letter_3">Actions</h4>
          </div>
          <div className="flex-40 layout-row layout-align-space-between-center">
            <div className="flex-none layout-row">
              <RoundButton
                theme={theme}
                size="small"
                text="Deny"
                iconClass="fa-trash"
                handleNext={this.handleDeny}
              />
            </div>
            <div className="flex-none offset-5 layout-row">
              <RoundButton
                theme={theme}
                size="small"
                text="Accept"
                iconClass="fa-check"
                active
                handleNext={this.handleAccept}
              />
            </div>
          </div>
        </div>
      ) : (
        <div className="flex-100 layout-row layout-align-space-between-center">
          <div className="flex-40 layout-row layout-align-start-center">
            <h4 className="flex-none letter_3">Actions</h4>
          </div>
          <div className="flex-30 layout-row layout-align-end-center">
            <div className="flex-none layout-row">
              <RoundButton
                theme={theme}
                size="small"
                text="Finished"
                iconClass="fa-check"
                active
                handleNext={() => this.handleFinished()}
              />
            </div>
          </div>
        </div>
      )
    const acceptDeny = shipment && shipment.status === 'finished' ? '' : actionsBox
    const feeHash = shipment.selected_offer
    const saveSection = (
      <div className={`${styles.time_edit_button}`}>
        {showEditTime ? (
          <div className="flex-100 layout-row layout-align-space-between">
            <div onClick={this.saveNewTime}>
              <i className="fa fa-check clip pointy" style={textStyle} />
            </div>
            <div onClick={this.toggleEditTime}>
              <i className="fa fa-times pointy" style={{ color: 'red' }} />
            </div>
          </div>
        ) : (
          <div className="flex-100 layout-row layout-align-end">
            <div onClick={this.toggleEditTime}>
              <i className="fa fa-pencil clip pointy" style={textStyle} />
            </div>
          </div>
        )}
      </div>
    )

    const etdJSX = showEditTime ? (
      <div className="flex-100 layout-row">
        <div className="flex-65 layout-row input_box_full">
          <DayPickerInput
            name="dayPicker"
            placeholder="DD/MM/YYYY"
            format="DD/MM/YYYY"
            formatDate={formatDate}
            parseDate={parseDate}
            value={newTimes.etd.day}
            onDayChange={e => this.handleDayChange(e, 'etd')}
            dayPickerProps={dayPickerProps}
          />
        </div>
        <div className="flex-35 layout-row input_box_full">
          <input
            type="time"
            value={newTimes.etd.time}
            onChange={e => this.handleTimeChange(e, 'etd')}
          />
        </div>
      </div>
    ) : (
      <p className="flex-none letter_3">
        {shipment.has_pre_carriage
          ? `${moment(shipment.planned_pickup_date).format('DD/MM/YYYY | HH:mm')}`
          : `${moment(shipment.planned_etd).format('DD/MM/YYYY | HH:mm')}`}
      </p>
    )

    const etaJSX = showEditTime ? (
      <div className="flex-100 layout-row">
        <div className="flex-65 layout-row input_box_full">
          <DayPickerInput
            name="dayPicker"
            placeholder="DD/MM/YYYY"
            format="DD/MM/YYYY"
            formatDate={formatDate}
            parseDate={parseDate}
            value={newTimes.eta.day}
            onDayChange={e => this.handleDayChange(e, 'eta')}
            dayPickerProps={dayPickerProps}
          />
        </div>
        <div className="flex-35 layout-row input_box_full">
          <input
            type="time"
            value={newTimes.eta.time}
            onChange={e => this.handleTimeChange(e, 'eta')}
          />
        </div>
      </div>
    ) : (
      <p className="flex-none letter_3">
        {`${moment(shipment.planned_eta).format('DD/MM/YYYY | HH:mm')}`}
      </p>
    )

    const totalPrice = showEditPrice ? (
      <div className="flex-30 layout-row">
        <div className="flex-40 layout-row input_box_full">
          <input type="number" value={newTotal} onChange={this.handleNewTotalChange} />
        </div>
        <div className="offset-5 flex-35 layout-row input_box_full">
          <NamedSelect
            name=""
            className="flex-100"
            placeholder="Currency"
            options={currencyOptions}
            value={currency}
            onChange={this.handleCurrencySelect}
          />
        </div>
        <div className="flex layout-row layout-align-space-around-center">
          <div onClick={this.saveNewPrice}>
            <i className="fa fa-check clip pointy" style={textStyle} />
          </div>
          <div onClick={this.toggleEditPrice}>
            <i className="fa fa-times pointy" style={{ color: 'red' }} />
          </div>
        </div>
      </div>
    ) : (
      <div className="flex-30 layout-row layout-align-end-center">
        <h3 className="flex-none letter_3">
          {parseFloat(shipment.total_price.value).toFixed(2)} {shipment.total_price.currency}
        </h3>
        <div
          className="flex-20 layout-row layout-align-center-center pointy"
          onClick={this.toggleEditPrice}
        >
          <i className="fa fa-pencil clip" style={textStyle} />
        </div>
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <CollapsingBar
          headingText="Overview"
          theme={theme}
          collapsed={collapser.overview}
          handleCollapser={() => this.handleCollapser('overview')}
          content={
            <div className="flex-100">
              <div className="flex-100 layout-row layout-wrap layout-align-space-between-start">
                <p className={`${styles.sec_title_text_normal} flex-none`}>Shipment:</p>
                <p className={`${styles.sec_title_text} flex-none offset-5`} style={textStyle}>
                  {shipment.imc_reference}
                </p>
              </div>
              <div className="flex-100 layout-row layout-wrap layout-align-space-between-start">
                <p className={`${styles.sec_subtitle_text_normal} flex-none`}>Status:</p>
                <p className={`${styles.sec_subtitle_text} flex-none offset-5 `}>
                  {capitalize(shipment.status)}
                </p>
              </div>
              <div className="flex-100 layout-row layout-wrap layout-align-space-between-start">
                <p className={`${styles.sec_subtitle_text_normal} flex-none`}>Created at:</p>
                <p className={`${styles.sec_subtitle_text} flex-none offset-5`}>{createdDate}</p>
              </div>
              {acceptDeny}
            </div>
          }
        />
        <CollapsingBar
          headingText="Itinerary"
          theme={theme}
          collapsed={collapser.itinerary}
          handleCollapser={() => this.handleCollapser('itinerary')}
          content={
            <div className="flex-100 layout-row layout-wrap" style={{ position: 'relative' }}>
              {saveSection}
              <RouteHubBox shipment={shipment} route={schedules} theme={theme} />
              <div className="flex-100 layout-row layout-align-space-between-center">
                <div className="flex-40 layout-row layout-wrap layout-align-center-start">
                  <div className="flex-100 layout-row layout-align-center-start layout-wrap">
                    <p className="flex-100 center letter_3">
                      {' '}
                      {shipment.has_pre_carriage
                        ? 'Expected Time of Collection:'
                        : 'Expected Time of Departure:'}
                    </p>
                    {etdJSX}
                  </div>
                </div>
                <div className="flex-40 layout-row layout-wrap layout-align-center-start">
                  <div className="flex-100 layout-row layout-align-center-start layout-wrap">
                    <p className="flex-100 center letter_3"> Expected Time of Arrival:</p>
                    {etaJSX}
                  </div>
                </div>
              </div>
            </div>
          }
        />
        <CollapsingBar
          headingText="Fares & Fees"
          theme={theme}
          collapsed={collapser.charges}
          handleCollapser={() => this.handleCollapser('charges')}
          content={
            <div className="flex-100">
              <div
                className={`${
                  styles.total_row
                } flex-100 layout-row layout-wrap layout-align-space-around-center`}
              >
                <h3 className="flex-70 letter_3">Shipment Total:</h3>
                {totalPrice}
              </div>

              <div className="flex-100 layout-row layout-align-center-center">
                <div
                  className="flex-none content_width_booking layout-row layout-align-center-center"
                >
                  <IncotermRow
                    theme={theme}
                    preCarriage={shipment.has_pre_carriage}
                    onCarriage={shipment.has_on_carriage}
                    originFees={shipment.has_pre_carriage}
                    destinationFees={shipment.has_on_carriage}
                    feeHash={feeHash}
                    tenant={tenant}
                  />
                </div>
              </div>
            </div>
          }
        />
        <CollapsingBar
          headingText="Additional Services"
          theme={theme}
          collapsed={collapser.extras}
          handleCollapser={() => this.handleCollapser('extras')}
          content={
            <div className="flex-100">
              <div className="flex-100 layout-row layout-align-center-center">
                <div
                  className="flex-none content_width_booking layout-row layout-align-center-center"
                >
                  <IncotermExtras theme={theme} feeHash={feeHash} tenant={tenant} />
                </div>
              </div>
            </div>
          }
        />
        <CollapsingBar
          headingText="Contact Details"
          theme={theme}
          collapsed={collapser.contacts}
          handleCollapser={() => this.handleCollapser('contacts')}
          content={
            <div className="flex-100 layout-row layout-wrap">
              <div
                className={`layout-row layout-align-start-center ${styles.b_summ_top} flex-100 `}
              >
                {accountHolderBox}
              </div>
              <div
                className={`layout-row layout-align-space-around-center ${
                  styles.b_summ_top
                } flex-100 `}
              >
                {shipperContact}
                {consigneeContact}
              </div>
              <div className="flex-100 layout-row layout-align-space-around-center layout-wrap">
                {' '}
                {nArray}{' '}
              </div>
            </div>
          }
        />
        <CollapsingBar
          headingText="Cargo Details"
          theme={theme}
          collapsed={collapser.cargo}
          handleCollapser={() => this.handleCollapser('cargo')}
          content={
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
              {cargoView}
            </div>
          }
        />
        <CollapsingBar
          headingText="Additional Info"
          theme={theme}
          collapsed={collapser.extra_info}
          handleCollapser={() => this.handleCollapser('extra_info')}
          content={
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
              <div className="flex-100 layout-row layout-align-start-center">
                {shipment.total_goods_value ? (
                  <div className="flex-45 layout-row offset-5 layout-align-start-start layout-wrap">
                    <p className="flex-100">
                      <b>Total Value of Goods:</b>
                    </p>
                    <p className="flex-100 no_m">{`${shipment.total_goods_value.currency} ${
                      shipment.total_goods_value.value
                    }`}</p>
                  </div>
                ) : (
                  ''
                )}
                {shipment.eori ? (
                  <div
                    className="flex-45 offset-10 layout-row
                        layout-align-start-start layout-wrap"
                  >
                    <p className="flex-100">
                      <b>EORI number:</b>
                    </p>
                    <p className="flex-100 no_m">{shipment.eori}</p>
                  </div>
                ) : (
                  ''
                )}
              </div>
              <div className="flex-100 layout-row layout-align-space-around-center">
                {shipment.cargo_notes ? (
                  <div className="flex-45 offset-5 layout-row layout-align-start-start layout-wrap">
                    <p className="flex-100">
                      <b>Description of Goods:</b>
                    </p>
                    <p className="flex-100 no_m">{shipment.cargo_notes}</p>
                  </div>
                ) : (
                  ''
                )}
                {shipment.notes ? (
                  <div className="flex-45 offset-5 layout-row layout-align-start-start layout-wrap">
                    <p className="flex-100">
                      <b>Notes:</b>
                    </p>
                    <p className="flex-100 no_m">{shipment.notes}</p>
                  </div>
                ) : (
                  ''
                )}
                {shipment.incoterm_text ? (
                  <div className="flex-45 offset-5 layout-row layout-align-start-start layout-wrap">
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
          }
        />
        <CollapsingBar
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
        />
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
