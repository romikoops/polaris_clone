import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import { formatDate, parseDate } from 'react-day-picker/moment'
import { CargoItemDetails } from '../CargoItemDetails/CargoItemDetails'
import { ContainerDetails } from '../ContainerDetails/ContainerDetails'
import FileTile from '../FileTile/FileTile'
import PropTypes from '../../prop-types'
import { RoundButton } from '../RoundButton/RoundButton'
import { RouteHubBox } from '../RouteHubBox/RouteHubBox'
import { moment, currencyOptions } from '../../constants'
import { capitalize, gradientTextGenerator } from '../../helpers'
import styles from './Admin.scss'
import { TextHeading } from '../TextHeading/TextHeading'
import { NamedSelect } from '../NamedSelect/NamedSelect'

export class AdminShipmentView extends Component {
  static sumCargoFees (cargos) {
    let total = 0.0
    let curr = ''
    Object.keys(cargos).forEach((k) => {
      total += parseFloat(cargos[k].total.value)
      curr = cargos[k].total.currency
    })

    return `${curr} ${total.toFixed(2)}`
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
      return 'N/A'
    }
    return `${curr} ${total.toFixed(2)}`
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
  toggleEditPrice () {
    this.setState({ showEditPrice: !this.state.showEditPrice })
  }
  toggleEditTime () {
    this.setState({ showEditTime: !this.state.showEditTime })
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
      theme, hubs, shipmentData, clients, adminDispatch
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
      hsCodes,
      locations
    } = shipmentData
    // ;
    const {
      newTotal, showEditPrice, currency, showEditTime, newTimes
    } = this.state
    const hubKeys = schedules[0].hub_route_key.split('-')
    const hubsObj = { startHub: {}, endHub: {} }
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
    const cargoView = []
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
          if (nArray.length === 1) {
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
                <i
                  className={` ${styles.icon} fa fa-envelope-open-o flex-none`}
                  style={textStyle}
                />
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
      containers.forEach((cont, i) => {
        const offset = i % 3 !== 0 ? 'offset-5' : ''
        cargoView.push(<div key={v4()} className={`flex-30 ${offset} layout-row layout-align-center-center`}>
          <ContainerDetails item={cont} index={i} theme={theme} hsCodes={hsCodes} />
        </div>)
      })
    }
    if (cargoItems) {
      cargoItems.forEach((ci, i) => {
        const offset = i % 3 !== 0 ? 'offset-5' : ''
        cargoView.push(<div key={v4()} className={`flex-30 ${offset} layout-row layout-align-center-center`}>
          <CargoItemDetails item={ci} index={i} theme={theme} hsCodes={hsCodes} />
        </div>)
      })
    }
    if (documents) {
      documents.forEach((doc) => {
        docView.push(<FileTile
          key={doc.id}
          doc={doc}
          theme={theme}
          adminDispatch={adminDispatch}
          isAdmin
        />)
      })
    }
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
    const newFeeStyle = showEditPrice ? styles.showPanel : styles.hidePanel
    const newTimeStyle = showEditTime ? styles.showPanel : styles.hidePanel
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center layout-wrap ${
            styles.sec_title
          }`}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-space-between-start">
            <p className={` ${styles.sec_title_text_normal} flex-none`}>Shipment:</p>
            <p className={` ${styles.sec_title_text} flex-none offset-5`} style={textStyle}>
              {shipment.imc_reference}
            </p>
          </div>
        </div>
        <div
          className={`flex-100 layout-row layout-align-space-between-center layout-wrap ${
            styles.shipment_card
          }`}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-space-between-start">
            <p className={` ${styles.sec_subtitle_text_normal} flex-none`}>Status:</p>
            <p className={` ${styles.sec_subtitle_text} flex-none offset-5 `}>
              {capitalize(shipment.status)}
            </p>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-space-between-start">
            <p className={` ${styles.sec_subtitle_text_normal} flex-none`}>Created at:</p>
            <p className={` ${styles.sec_subtitle_text} flex-none offset-5 `}>{createdDate}</p>
          </div>
          {acceptDeny}
        </div>
        <div
          className={`${
            styles.shipment_card
          } flex-100 layout-row layout-align-start-center layout-wrap`}
        >
          <div className="flex-100 layout-row layout-align-start-center">
            <TextHeading theme={theme} size={3} text="Itinerary" />
          </div>
          <RouteHubBox hubs={hubsObj} route={schedules} theme={theme} />
          <div
            className="flex-100 layout-row layout-align-space-between-center"
            style={{ position: 'relative' }}
          >
            <div className="flex-40 layout-row layout-wrap layout-align-center-center">
              <div className="flex-100 layout-row layout-align-center-start layout-wrap">
                <p className="flex-100 center letter_3"> Expected Time of Departure:</p>
                <p className="flex-none letter_3">{` ${moment(shipment.planned_etd).format('DD/MM/YYYY | HH:mm')}`}</p>
              </div>
              {shipment.has_pre_carriage ? (
                <div className="flex-100 layout-row layout-align-start-start">
                  <address className="flex-none">
                    {`${locations.origin.street_number} ${locations.origin.street}`} <br />
                    {`${locations.origin.city}`} <br />
                    {`${locations.origin.zip_code}`} <br />
                    {`${locations.origin.country}`} <br />
                  </address>
                </div>
              ) : (
                ''
              )}
            </div>
            <div className="flex-40 layout-row layout-wrap layout-align-center-center">
              <div className="flex-100 layout-row layout-align-center-start layout-wrap">
                <p className="flex-100 center letter_3"> Expected Time of Arrival:</p>
                <p className="flex-none letter_3">{`${moment(shipment.planned_eta).format('DD/MM/YYYY | HH:mm')}`}</p>
              </div>
              {shipment.has_on_carriage ? (
                <div className="flex-100 layout-row layout-align-start-start">
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
              )}
            </div>
            <div className={`${styles.time_edit_button}`} onClick={this.toggleEditTime}>
              <i className="fa fa-pencil clip" style={textStyle} />
            </div>
          </div>
          <div
            className={`flex-100 layout-row layout-align-space-between-center layout-wrap ${
              styles.panelDefault
            } ${newTimeStyle}`}
          >
            <div className="flex-40 layout-row layout-align-center-center">
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
            <div className="flex-40 layout-row layout-align-center-center">
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
            <div className="flex-100 layout-row layout-align-end-center" style={{ height: '50px' }}>
              <div
                className="flex-10 layout-row layout-align-center-center pointy"
                onClick={this.saveNewTime}
              >
                <i className="fa fa-check clip" style={textStyle} />
              </div>
              <div
                className="flex-10 layout-row layout-align-center-center pointy"
                onClick={this.toggleEditTime}
              >
                <i className="fa fa-times" style={{ color: 'red' }} />
              </div>
            </div>
          </div>
        </div>
        <div
          className={`${
            styles.shipment_card
          } flex-100 layout-row layout-align-start-center layout-wrap`}
        >
          <div className="flex-100 layout-row layout-align-start-center">
            <TextHeading theme={theme} size={3} text="Fares & Fees" />
          </div>
          <div
            className={`${
              styles.total_row
            } flex-100 layout-row layout-wrap layout-align-space-around-center`}
          />
          <h3 className="flex-70 letter_3">Shipment Total:</h3>
          <div className="flex-30 layout-row layout-align-end-center">
            <h3 className="flex-none letter_3">{`${shipment.total_price.currency} ${parseFloat(shipment.total_price.value).toFixed(2)} `}</h3>
            <div
              className="flex-20 layout-row layout-align-center-center pointy"
              onClick={this.toggleEditPrice}
            >
              <i className="fa fa-pencil clip" style={textStyle} />
            </div>
          </div>
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${
              styles.panelDefault
            } ${newFeeStyle}`}
          >
            <div className="flex-30 layout-align-start-center">
              <p className="flex-none">Set new total price:</p>
            </div>
            <div className="flex-40 layout-row layout-align-end-center">
              <div className="flex-40 layout-row input_box_full">
                <NamedSelect
                  name=""
                  options={currencyOptions}
                  value={currency}
                  onChange={this.handleCurrencySelect}
                />
              </div>
              <div className="flex-40 layout-row input_box_full">
                <input type="number" value={newTotal} onChange={this.handleNewTotalChange} />
              </div>
              <div
                className="flex-15 layout-row layout-align-center-center pointy"
                onClick={this.saveNewPrice}
              >
                <i className="fa fa-check clip" style={textStyle} />
              </div>
              <div
                className="flex-15 layout-row layout-align-center-center pointy"
                onClick={this.toggleEditPrice}
              >
                <i className="fa fa-times" style={{ color: 'red' }} />
              </div>
            </div>
          </div>
          <div
            className={`${styles.b_summ_top} flex-100 layout-row layout-align-space-around-center`}
          >
            <div
              className={`${
                styles.charge_card
              } flex-30 layout-row layout-align-start-start layout-wrap`}
            >
              <div className="flex-100 layout-row layout-align-start-center">
                <h5 className="flex-none letter_3">Freight</h5>
              </div>
              <div className="flex-100 layout-row layout-align-start-center">
                <h3 className="flex-none letter_3">
                  {AdminShipmentView.sumCargoFees(feeHash.cargo)}
                </h3>
              </div>
            </div>
            <div
              className={`${
                styles.charge_card
              } flex-30 layout-row layout-align-start-start layout-wrap`}
            >
              <div className="flex-100 layout-row layout-align-start-center">
                <h5 className="flex-none letter_3">Pre Carriage</h5>
              </div>
              <div className="flex-100 layout-row layout-align-start-center">
                <h3 className="flex-none letter_3">
                  {shipment.has_pre_carriage
                    ? `${feeHash.trucking_pre.currency} ${feeHash.trucking_pre.value}`
                    : 'N/A'}
                </h3>
              </div>
            </div>
            <div
              className={`${
                styles.charge_card
              } flex-30 layout-row layout-align-start-start layout-wrap`}
            >
              <div className="flex-100 layout-row layout-align-start-center">
                <h5 className="flex-none letter_3">On Carriage</h5>
              </div>
              <div className="flex-100 layout-row layout-align-start-center">
                <h3 className="flex-none letter_3">
                  {shipment.has_on_carriage
                    ? `${feeHash.trucking_on.currency} ${feeHash.trucking_on.value}`
                    : 'N/A'}
                </h3>
              </div>
            </div>
            <div
              className={`${
                styles.charge_card
              } flex-30 layout-row layout-align-start-start layout-wrap`}
            >
              <div className="flex-100 layout-row layout-align-start-center">
                <h5 className="flex-none letter_3">Insurance</h5>
              </div>
              <div className="flex-100 layout-row layout-align-start-center">
                <h3 className="flex-none letter_3">
                  {feeHash.insurance && feeHash.insurance.val
                    ? `${feeHash.insurance.currency} ${feeHash.insurance.val.toFixed(2)}`
                    : 'N/A'}
                </h3>
              </div>
            </div>
            <div
              className={`${
                styles.charge_card
              } flex-30 layout-row layout-align-start-start layout-wrap`}
            >
              <div className="flex-100 layout-row layout-align-start-center">
                <h5 className="flex-none letter_3">Customs</h5>
              </div>
              <div className="flex-100 layout-row layout-align-start-center">
                <h3 className="flex-none letter_3">
                  {AdminShipmentView.sumCustomsFees(feeHash.cargo)}
                </h3>
              </div>
            </div>
          </div>
        </div>
        <div
          className={`${
            styles.shipment_card
          } flex-100 layout-row layout-align-start-center layout-wrap`}
        >
          <div className="flex-100 layout-row layout-align-start-center">
            <TextHeading theme={theme} size={3} text="Contact Details" />
          </div>
          <div
            className={`${styles.b_summ_top} flex-100 layout-row layout-align-space-around-center`}
          >
            {shipperContact}
            {consigneeContact}
          </div>
          <div className="flex-100 layout-row layout-align-space-around-center layout-wrap">
            {' '}
            {nArray}{' '}
          </div>
        </div>
        <div
          className={`${
            styles.shipment_card
          } flex-100 layout-row layout-align-start-center layout-wrap`}
        >
          <div className="flex-100 layout-row layout-align-start-center">
            <TextHeading theme={theme} size={3} text="Cargo Details" />
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-start-center">
            {cargoView}
          </div>
        </div>
        <div
          className={`${
            styles.shipment_card
          } flex-100 layout-row layout-align-start-center layout-wrap`}
        >
          <div className="flex-100 layout-row layout-align-start-center">
            <TextHeading theme={theme} size={3} text="Documents" />
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-start-center">{docView}</div>
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
  match: PropTypes.match.isRequired
}

AdminShipmentView.defaultProps = {
  theme: null,
  hubs: [],
  clients: [],
  shipmentData: null,
  loading: false
}

export default AdminShipmentView
