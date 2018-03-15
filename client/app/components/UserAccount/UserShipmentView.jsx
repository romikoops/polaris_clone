import React, { Component } from 'react'
import Select from 'react-select'
import styled from 'styled-components'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import styles from '../Admin/Admin.scss'
import { CargoItemGroup } from '../Cargo/Item/Group'
import { CargoContainerGroup } from '../Cargo/Container/Group'
// import { ContainerDetails } from '../ContainerDetails/ContainerDetails'
// import { CargoItemDetails } from '../CargoItemDetails/CargoItemDetails'
import { RouteHubBox } from '../RouteHubBox/RouteHubBox'
import { moment } from '../../constants'
import { capitalize, gradientTextGenerator } from '../../helpers'
import '../../styles/select-css-custom.css'
import FileUploader from '../FileUploader/FileUploader'
import FileTile from '../FileTile/FileTile'
import { RoundButton } from '../RoundButton/RoundButton'
import { TextHeading } from '../TextHeading/TextHeading'
import { IncotermRow } from '../Incoterm/Row'

export class UserShipmentView extends Component {
  static sumCargoFees (cargos) {
    let total = 0.0
    let curr = ''
    Object.keys(cargos).forEach((k) => {
      total += parseFloat(cargos[k].total.value)
      curr = cargos[k].total.currency
    })

    return { currency: curr, total: total.toFixed(2) }
  }
  constructor (props) {
    super(props)
    this.state = {
      fileType: { label: 'Packing Sheet', value: 'packing_sheet' },
      // upUrl: this.props.shipmentData
      //   ? `/shipments/${this.props.shipmentData.shipment.id}/upload/packing_sheet`
      //   : '',
      collapser: {}
    }
    this.setFileType = this.setFileType.bind(this)
    this.back = this.back.bind(this)
  }
  componentDidMount () {
    const {
      shipmentData, loading, userDispatch, match
    } = this.props
    this.props.setNav('shipments')
    if (!shipmentData && !loading) {
      userDispatch.getShipment(parseInt(match.params.id, 10), false)
    } else if (
      shipmentData &&
      shipmentData.shipment &&
      shipmentData.shipment.id !== match.params.id
    ) {
      userDispatch.getShipment(parseInt(match.params.id, 10), false)
    }
  }
  setFileType (ev) {
    const shipmentId = this.props.shipmentData.shipment.id
    const url = `/shipments/${shipmentId}/upload/${ev.value}`
    this.setState({ fileType: ev, upUrl: url })
  }
  handleCollapser (key) {
    this.setState({
      collapser: {
        ...this.state.collapser,
        [key]: !this.state.collapser[key]
      }
    })
  }
  back () {
    const { userDispatch } = this.props
    userDispatch.goBack()
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
      resultArray.push(<CargoContainerGroup
        group={cargoGroups[k]}
        theme={theme}
        hsCodes={hsCodes}
      />)
    })
    return resultArray
  }

  render () {
    const {
      theme, hubs, shipmentData, user, userDispatch, tenant
    } = this.props

    if (!shipmentData || !hubs || !user) {
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
    const { collapser } = this.state
    const docOptions = [
      { label: 'Packing Sheet', value: 'packing_sheet' },
      { label: 'Commercial Invoice', value: 'commercial_invoice' },
      { label: 'Customs Declaration', value: 'customs_declaration' },
      { label: 'Customs Value Declaration', value: 'customs_value_declaration' },
      { label: 'EORI', value: 'eori' },
      { label: 'Certificate Of Origin', value: 'certificate_of_origin' },
      { label: 'Dangerous Goods', value: 'dangerous_goods' }
    ]
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
    const StyledSelect = styled(Select)`
      .Select-control {
        background-color: #f9f9f9;
        box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
        border: 1px solid #f2f2f2 !important;
      }
      .Select-menu-outer {
        box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
        border: 1px solid #f2f2f2;
      }
      .Select-value {
        background-color: #f9f9f9;
        border: 1px solid #f2f2f2;
      }
      .Select-option {
        background-color: #f9f9f9;
      }
    `
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
          nArray.push(<div key={v4()} className="flex-33 layout-row">
            <div className="flex-15 layout-column layout-align-start-center">
              <i className={` ${styles.icon} fa fa-user-circle-o flex-none`} style={textStyle} />
            </div>
            <div className="flex-85 layout-row layout-wrap layout-align-start-start">
              <div className="flex-100">
                <TextHeading theme={theme} size={3} text="Notifyee" />
              </div>
              <p className={` ${styles.address} flex-100`}>
                {n.contact.first_name} {n.contact.last_name} <br />
              </p>
            </div>
          </div>)
        }
        if (n.type === 'shipper') {
          shipperContact = (
            <div className="flex-33 layout-row">
              <div className="flex-15 layout-column layout-align-start-center">
                <i className={`${styles.icon} fa fa-user-circle-o flex-none`} style={textStyle} />
              </div>
              <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                <div className="flex-100">
                  <TextHeading theme={theme} size={3} text="Shipper" />
                </div>
                <p className={`${styles.address} flex-100`}>
                  {n.contact.first_name} {n.contact.last_name} <br />
                  {n.location.street} {n.location.street_number} <br />
                  {n.location.zip_code} {n.location.city} <br />
                  {n.location.country}
                </p>
              </div>
            </div>
          )
        }
        if (n.type === 'consignee') {
          consigneeContact = (
            <div className="flex-33 layout-row">
              <div className="flex-15 layout-column layout-align-start-center">
                <i
                  className={` ${styles.icon} fa fa-envelope-open-o flex-none`}
                  style={textStyle}
                />
              </div>
              <div className="flex-85 layout-row layout-wrap layout-align-start-start">
                <div className="flex-100">
                  <TextHeading theme={theme} size={3} text="Receiver" />
                </div>
                <p className={` ${styles.address} flex-100`}>
                  {n.contact.first_name} {n.contact.last_name} <br />
                  {n.location.street} {n.location.street_number} <br />
                  {n.location.zip_code} {n.location.city} <br />
                  {n.location.country}
                </p>
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
    if (documents) {
      documents.forEach((doc) => {
        docView.push(<FileTile
          key={doc.id}
          doc={doc}
          theme={theme}
          deleteFn={userDispatch.deleteDocument}
        />)
      })
    }
    const feeHash = shipment.schedules_charges[schedules[0].hub_route_key]
    const themeTitled =
      theme && theme.colors
        ? { background: theme.colors.primary, color: 'white' }
        : { background: 'rgba(0,0,0,0.25)', color: 'white' }
    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className={`flex-100 layout-row layout-align-end-center ${styles.sec_title}`}>
          <RoundButton
            theme={theme}
            text="Back"
            size="small"
            back
            iconClass="fa-angle-left"
            handleNext={this.back}
          />
        </div>

        <div
          className={`flex-100 layout-row layout-align-space-between-center layout-wrap ${
            styles.shipment_card
          }`}
        >
          <div
            style={themeTitled}
            className={`${
              styles.heading_style
            } flex-100 layout-row layout-align-space-between-center`}
          >
            <TextHeading theme={theme} color="white" size={3} text="Overview" />
            <div
              className="flex-10 layout-row layout-align-center-center"
              onClick={() => this.handleCollapser('overview')}
            >
              {collapser.overview ? (
                <i className="fa fa-chevron-down pointy" />
              ) : (
                <i className="fa fa-chevron-up pointy" />
              )}
            </div>
          </div>
          <div
            className={`${collapser.overview ? styles.closed_main_panel : styles.open_main_panel} ${
              styles.main_panel
            } flex-100 layout-row layout-wrap layout-align-start-start`}
          >
            <div className="flex-100 layout-row layout-wrap layout-align-space-between-start">
              <p className={` ${styles.sec_title_text_normal} flex-none`}>Shipment:</p>
              <p className={` ${styles.sec_title_text} flex-none offset-5`} style={textStyle}>
                {shipment.imc_reference}
              </p>
            </div>
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
          </div>
        </div>
        <div
          className={`${
            styles.shipment_card
          } flex-100 layout-row layout-align-start-center layout-wrap`}
        >
          <div
            style={themeTitled}
            className={`${
              styles.heading_style
            } flex-100 layout-row layout-align-space-between-center`}
          >
            <TextHeading theme={theme} color="white" size={3} text="Itinerary" />
            <div
              className="flex-10 layout-row layout-align-center-center"
              onClick={() => this.handleCollapser('itinerary')}
            >
              {collapser.itinerary ? (
                <i className="fa fa-chevron-down pointy" />
              ) : (
                <i className="fa fa-chevron-up pointy" />
              )}
            </div>
          </div>
          <div
            className={`${
              collapser.itinerary ? styles.closed_main_panel : styles.open_main_panel
            } ${styles.main_panel} flex-100 layout-row layout-wrap layout-align-start-start`}
          >
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
            </div>
          </div>
        </div>
        <div
          className={`${
            styles.shipment_card
          } flex-100 layout-row layout-align-start-center layout-wrap`}
        >
          <div
            style={themeTitled}
            className={`${
              styles.heading_style
            } flex-100 layout-row layout-align-space-between-center`}
          >
            <TextHeading theme={theme} color="white" size={3} text="Fares & Fees" />
            <div
              className="flex-10 layout-row layout-align-center-center"
              onClick={() => this.handleCollapser('charges')}
            >
              {collapser.charges ? (
                <i className="fa fa-chevron-down pointy" />
              ) : (
                <i className="fa fa-chevron-up pointy" />
              )}
            </div>
          </div>
          <div
            className={`${
              styles.total_row
            } flex-100 layout-row layout-wrap layout-align-space-around-center`}
          >
            <h3 className="flex-70 letter_3">Shipment Total:</h3>
            <div className="flex-30 layout-row layout-align-end-center">
              <h3 className="flex-none letter_3">{`${shipment.total_price.currency} ${parseFloat(shipment.total_price.value).toFixed(2)} `}</h3>
            </div>
          </div>
          <div
            className={`${collapser.charges ? styles.closed_main_panel : styles.open_main_panel} ${
              styles.main_panel
            } flex-100 layout-row layout-wrap layout-align-start-start`}
          >
            <div className="flex-100 layout-row layout-align-center-center">
              <div
                className="
                    flex-none
                     content_width_booking
                     layout-row
                     layout-align-center-center"
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
        </div>
        <div
          className={`${
            styles.shipment_card
          } flex-100 layout-row layout-align-start-center layout-wrap`}
        >
          <div
            style={themeTitled}
            className={`${
              styles.heading_style
            } flex-100 layout-row layout-align-space-between-center`}
          >
            <TextHeading theme={theme} color="white" size={3} text="Contact Details" />
            <div
              className="flex-10 layout-row layout-align-center-center"
              onClick={() => this.handleCollapser('contacts')}
            >
              {collapser.contacts ? (
                <i className="fa fa-chevron-down pointy" />
              ) : (
                <i className="fa fa-chevron-up pointy" />
              )}
            </div>
          </div>
          <div
            className={`${collapser.contacts ? styles.closed_main_panel : styles.open_main_panel} ${
              styles.main_panel
            } flex-100 layout-row layout-wrap layout-align-start-start`}
          >
            <div
              className={`${
                styles.b_summ_top
              } flex-100 layout-row layout-align-space-around-center`}
            >
              {shipperContact}
              {consigneeContact}
            </div>
            <div className="flex-100 layout-row layout-align-space-around-center layout-wrap">
              {' '}
              {nArray}{' '}
            </div>
          </div>
        </div>
        <div
          className={`${
            styles.shipment_card
          } flex-100 layout-row layout-align-start-center layout-wrap`}
        >
          <div
            style={themeTitled}
            className={`${
              styles.heading_style
            } flex-100 layout-row layout-align-space-between-center`}
          >
            <TextHeading theme={theme} color="white" size={3} text="Cargo Details" />
            <div
              className="flex-10 layout-row layout-align-center-center"
              onClick={() => this.handleCollapser('cargo')}
            >
              {collapser.cargo ? (
                <i className="fa fa-chevron-down pointy" />
              ) : (
                <i className="fa fa-chevron-up pointy" />
              )}
            </div>
          </div>
          <div
            className={`${collapser.cargo ? styles.closed_main_panel : styles.open_main_panel} ${
              styles.main_panel
            } flex-100 layout-row layout-wrap layout-align-start-start`}
          >
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
              {cargoView}
            </div>
          </div>
        </div>
        <div
          className={`${
            styles.shipment_card
          } flex-100 layout-row layout-align-start-center layout-wrap`}
        >
          <div
            style={themeTitled}
            className={`${
              styles.heading_style
            } flex-100 layout-row layout-align-space-between-center`}
          >
            <TextHeading theme={theme} color="white" size={3} text="Documents" />
            <div
              className="flex-10 layout-row layout-align-center-center"
              onClick={() => this.handleCollapser('documents')}
            >
              {collapser.documents ? (
                <i className="fa fa-chevron-down pointy" />
              ) : (
                <i className="fa fa-chevron-up pointy" />
              )}
            </div>
          </div>
          <div
            className={`${
              collapser.documents ? styles.closed_main_panel : styles.open_main_panel
            } ${styles.main_panel} flex-100 layout-row layout-wrap layout-align-start-start`}
          >
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
              {docView}
            </div>
            <div className="flex-100 layout-row layout-wrap layout-align-start-center">
              <div
                className={`flex-100 layout-row layout-align-space-between-center ${
                  styles.sec_subheader
                }`}
              >
                <p className={` ${styles.sec_subheader_text} flex-none letter_3`}>
                  Upload New Document
                </p>
              </div>
              <div className="flex-50 layout-align-start-center layout-row">
                <StyledSelect
                  name="file-type"
                  className={`${styles.select}`}
                  value={this.state.fileType}
                  options={docOptions}
                  onChange={this.setFileType}
                />
              </div>
              <div className="flex-50 layout-align-end-center layout-row">
                <FileUploader
                  theme={theme}
                  url={this.state.upUrl}
                  type={this.state.fileType.value}
                  text={this.state.fileType.label}
                  uploadFn={userDispatch.uploadDocument}
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

UserShipmentView.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.object),
  loading: PropTypes.bool,
  shipmentData: PropTypes.shipmentData.isRequired,
  user: PropTypes.user,
  userDispatch: PropTypes.shape({
    deleteDocument: PropTypes.func
  }).isRequired,
  match: PropTypes.match.isRequired,
  setNav: PropTypes.func.isRequired,
  tenant: PropTypes.tenant
}

UserShipmentView.defaultProps = {
  theme: null,
  hubs: [],
  loading: false,
  user: null,
  tenant: {}
}

export default UserShipmentView
