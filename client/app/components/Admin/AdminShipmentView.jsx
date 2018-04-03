import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import { formatDate, parseDate } from 'react-day-picker/moment'
import { CargoItemGroup } from '../Cargo/Item/Group'
import { CargoContainerGroup } from '../Cargo/Container/Group'
import FileTile from '../FileTile/FileTile'
import PropTypes from '../../prop-types'
import { RoundButton } from '../RoundButton/RoundButton'
import { RouteHubBox } from '../RouteHubBox/RouteHubBox'
import { moment, currencyOptions, documentTypes } from '../../constants'
import { capitalize, gradientTextGenerator } from '../../helpers'
import styles from './Admin.scss'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import { IncotermRow } from '../Incoterm/Row'
import ShipmentCard from '../ShipmentCard/ShipmentCard'

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
      resultArray.push(<CargoContainerGroup group={cargoGroups[k]} theme={theme} hsCodes={hsCodes} />)
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
      theme, hubs, shipmentData, clients, adminDispatch, tenant
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
      schedules,
      locations
    } = shipmentData
    const {
      newTotal, showEditPrice, currency, showEditTime, newTimes, collapser
    } = this.state
    const hubKeys = schedules[0].hub_route_key.split('-')
    const hubsObj = {
      startHub: {
        data: locations.origin
      },
      endHub: {
        data: locations.destination
      }
    }

    hubs.forEach((c) => {
      if (String(c.data.id) === hubKeys[0]) {
        hubsObj.startHub = c
      }
      if (String(c.data.id) === hubKeys[1]) {
        hubsObj.endHub = c
      }
    })
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
    let cargoView = []
    const docView = []
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
    if (containers) {
      cargoView = this.prepContainerGroups(containers)
    }
    if (cargoItems.length > 0) {
      cargoView = this.prepCargoItemGroups(cargoItems)
    }
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
    if (documents) {
      documents.forEach((doc) => {
        docChecker[doc.doc_type] = true
        docView.push(<FileTile key={doc.id} doc={doc} theme={theme} adminDispatch={adminDispatch} isAdmin />)
      })
    }
    Object.keys(docChecker).forEach((key) => {
      if (!docChecker[key]) {
        docView.push(<div className={`flex-25 layout-row layout-align-start-center ${styles.no_doc}`}>
          <div className="flex-none layout-row layout-align-center-center">
            <i className="flex-none fa fa-ban" />
          </div>
          <div className="flex layout-align-start-center layout-row">
            <p className="flex-none">{`${documentTypes[key]}: Not Uploaded`}</p>
          </div>
        </div>)
      }
    })
    const acceptDeny =
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
        ''
      )
    const feeHash = shipment.schedules_charges[schedules[0].hub_route_key]
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
        {`${moment(shipment.planned_etd).format('DD/MM/YYYY | HH:mm')}`}
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
        <ShipmentCard
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
        <ShipmentCard
          headingText="Itinerary"
          theme={theme}
          collapsed={collapser.itinerary}
          handleCollapser={() => this.handleCollapser('itinerary')}
          content={
            <div className="flex-100 layout-row layout-wrap" style={{ position: 'relative' }}>
              {saveSection}
              <RouteHubBox hubs={hubsObj} route={schedules} theme={theme} />
              <div className="flex-100 layout-row layout-align-space-between-center">
                <div className="flex-40 layout-row layout-wrap layout-align-center-start">
                  <div className="flex-100 layout-row layout-align-center-start layout-wrap">
                    <p className="flex-100 center letter_3"> Expected Time of Departure:</p>
                    {etdJSX}
                  </div>
                  {shipment.has_pre_carriage ? (
                    <div className="flex-100 layout-row layout-align-center-start layout-wrap">
                      <div className="flex-100 layout-row layout-align-center-center">
                        <p className="flex-none">With Pickup From:</p>
                      </div>
                      <address className={` ${styles.itinerary_address} flex-none`}>
                        {`${locations.origin.street_number} ${locations.origin.street}`}, <br />
                        {`${locations.origin.city}, ${' '} `}
                        {`${locations.origin.zip_code}, `}
                        {`${locations.origin.country}`} <br />
                      </address>
                    </div>
                  ) : (
                    ''
                  )}
                </div>
                <div className="flex-40 layout-row layout-wrap layout-align-center-start">
                  <div className="flex-100 layout-row layout-align-center-start layout-wrap">
                    <p className="flex-100 center letter_3"> Expected Time of Arrival:</p>
                    {etaJSX}
                  </div>
                  {shipment.has_on_carriage ? (
                    <div className="flex-100 layout-row layout-align-center-start layout-wrap">
                      <div className="flex-100 layout-row layout-align-center-center">
                        <p className="flex-none">With Delivery To:</p>
                      </div>
                      <address className={` ${styles.itinerary_address} flex-none`}>
                        {`${locations.destination.street_number} ${locations.destination.street}`} ,<br />
                        {`${locations.destination.city}, ${' '} `}
                        {`${locations.destination.zip_code}, `}
                        {`${locations.destination.country}`} <br />
                      </address>
                    </div>
                  ) : (
                    ''
                  )}
                </div>
              </div>
            </div>
          }
        />
        <ShipmentCard
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
                <div className="flex-none content_width_booking layout-row layout-align-center-center">
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
        <ShipmentCard
          headingText="Contact Details"
          theme={theme}
          collapsed={collapser.contacts}
          handleCollapser={() => this.handleCollapser('contacts')}
          content={
            <div className="flex-100 layout-row layout-wrap">
              <div
                className={
                  `${styles.b_summ_top} flex-100 ` + 'layout-row layout-align-space-around-center'
                }
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
        <ShipmentCard
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
        <ShipmentCard
          headingText="Documents"
          theme={theme}
          collapsed={collapser.documents}
          handleCollapser={() => this.handleCollapser('documents')}
          content={
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
              {docView}
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
