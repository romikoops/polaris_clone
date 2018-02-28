import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import { CargoItemDetails } from '../CargoItemDetails/CargoItemDetails'
import { ContainerDetails } from '../ContainerDetails/ContainerDetails'
import FileTile from '../FileTile/FileTile'
import PropTypes from '../../prop-types'
import { RoundButton } from '../RoundButton/RoundButton'
import { RouteHubBox } from '../RouteHubBox/RouteHubBox'
import { moment } from '../../constants'
import { capitalize, gradientTextGenerator } from '../../helpers'
import styles from './Admin.scss'
import { TextHeading } from '../TextHeading/TextHeading'

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
      newTotal: 0
    }
    this.handleDeny = this.handleDeny.bind(this)
    this.handleAccept = this.handleAccept.bind(this)
    this.toggleEditPrice = this.toggleEditPrice.bind(this)
    this.saveNewPrice = this.saveNewPrice.bind(this)
    this.handleNewTotalChange = this.handleNewTotalChange.bind(this)
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

  handleAccept () {
    const { shipmentData, handleShipmentAction } = this.props
    handleShipmentAction(shipmentData.shipment.id, 'accept')
  }
  toggleEditPrice () {
    this.setState({ showEditPrice: !this.state.showEditPrice })
  }
  saveNewPrice () {
    this.setState({})
  }
  handleNewTotalChange () {
    this.setState({})
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
    const { newTotal, showEditPrice } = this.state
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
          <div className="flex-100 layout-row layout-align-space-between-center">
            <div className="flex-40 layout-row layout-wrap layout-align-center-center">
              <div className="flex-100 layout-row layout-align-center-start">
                <p className="flex-none">{`ETD: ${moment(schedules[0].etd).format('DD/MM/YYYY | HH:mm')}`}</p>
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
              <div className="flex-100 layout-row layout-align-center-start">
                <p className="flex-none">{`ETA: ${moment(schedules[0].eta).format('DD/MM/YYYY | HH:mm')}`}</p>
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
            <h3 className="flex-none letter_3"> {parseFloat(shipment.total_price).toFixed(2)} </h3>
            <div
              className="flex-20 layout-row layout-align-center-center pointy"
              onClick={this.toggleEditPrice}
            >
              <i className="fa fa-pencil clip" style={textStyle} />
            </div>
          </div>
          <div className={`flex-100 layout-row layout-align-space-between-center ${styles.panelDefault} ${newFeeStyle}`}>
            <div className="flex-30 layout-align-start-center">
              <p className="flex-none">Set new total price:</p>
            </div>
            <div className="flex-30 layout-row layout-align-end-center">
              <div className="flex-70 layout-row input_box_full">
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
                <i className="fa fa-times clip" style={{ color: 'red' }} />
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
