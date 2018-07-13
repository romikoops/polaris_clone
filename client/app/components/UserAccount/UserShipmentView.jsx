import React, { Component } from 'react'
import Select from 'react-select'
import { v4 } from 'uuid'
import { pick, uniqWith } from 'lodash'
import styled from 'styled-components'
import PropTypes from '../../prop-types'
import adminStyles from '../Admin/Admin.scss'
import styles from '../Admin/AdminShipments.scss'
import { CargoItemGroup } from '../Cargo/Item/Group'
import CargoItemGroupAggregated from '../Cargo/Item/Group/Aggregated'
import { CargoContainerGroup } from '../Cargo/Container/Group'
import { moment, documentTypes } from '../../constants'
import {
  gradientTextGenerator,
  switchIcon,
  gradientGenerator,
  gradientBorderGenerator,
  formattedPriceValue,
  totalPrice
} from '../../helpers'
import '../../styles/select-css-custom.css'
import FileUploader from '../FileUploader/FileUploader'
import DocumentsForm from '../Documents/Form'
import GradientBorder from '../GradientBorder'
import ShipmentOverviewShowCard from '../Admin/AdminShipmentView/ShipmentOverviewShowCard'
import ContactDetailsRow from '../Admin/AdminShipmentView/ContactDetailsRow'
import AlternativeGreyBox from '../GreyBox/AlternativeGreyBox'

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
  constructor (props) {
    super(props)
    this.state = {
      fileType: { label: 'Packing Sheet', value: 'packing_sheet' },
      upUrl: `/shipments/${this.props.match.params.id}/upload/packing_sheet`,
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
    window.scrollTo(0, 0)
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
  deleteDoc (doc) {
    const { userDispatch } = this.props
    userDispatch.deleteDocument(doc.id)
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
  fileFn (file) {
    const { shipmentData, userDispatch } = this.props
    const { shipment } = shipmentData
    const type = file.doc_type
    const url = `/shipments/${shipment.id}/upload/${type}`
    userDispatch.uploadDocument(file, type, url)
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
  reuseShipment () {
    const { shipmentData, userDispatch } = this.props
    const {
      shipment, cargoItems, containers, aggregatedCargo, contacts
    } = shipmentData
    const req = {
      shipment, cargoItems, containers, aggregatedCargo, contacts
    }
    userDispatch.reuseShipment(req)
  }

  render () {
    const {
      theme, hubs, shipmentData, user, userDispatch, tenant
    } = this.props

    if (!shipmentData || !hubs || !user) {
      return ''
    }
    const { scope } = tenant.data
    const {
      contacts,
      shipment,
      documents,
      cargoItems,
      containers,
      aggregatedCargo
      // accountHolder
    } = shipmentData
    const docOptions = [
      { label: 'Packing Sheet', value: 'packing_sheet' },
      { label: 'Commercial Invoice', value: 'commercial_invoice' },
      { label: 'Customs Declaration', value: 'customs_declaration' },
      { label: 'Customs Value Declaration', value: 'customs_value_declaration' },
      { label: 'EORI', value: 'eori' },
      { label: 'Certificate Of Origin', value: 'certificate_of_origin' },
      { label: 'Dangerous Goods', value: 'dangerous_goods' }
    ]
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
    const missingDocs = []

    const statusRequested = (shipment.status === 'requested') ? (
      <GradientBorder
        wrapperClassName={`layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25 ${adminStyles.header_margin_buffer}  ${styles.status_box_requested}`}
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
    const reuseShipment = (
      <div style={gradientStyle} onClick={() => this.reuseShipment()} className={`layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25 layout-align-center-center pointy ${adminStyles.header_margin_buffer}  ${styles.reuse_shipment_box}`}>
        <p className="layout-align-center-center layout-row">Reuse Shipment </p>
      </div>
    )

    const statusFinished = (shipment.status === 'finished') ? (
      <div style={gradientStyle} className={`layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25 layout-align-center-center ${adminStyles.header_margin_buffer}  ${styles.status_box}`}>
        <p className="layout-align-center-center layout-row"> {shipment.status} </p>
      </div>
    ) : (
      ''
    )
    // const accountHolderBox = accountHolder ? (
    //   <div className="flex-50 layout-row">
    //     <div className="flex-15 layout-column layout-align-start-center">
    //       <i className={`${styles.icon} fa fa-user-circle-o flex-none`} style={textStyle} />
    //     </div>
    //     <div className="flex-85 layout-row layout-wrap layout-align-start-start">
    //       <div className="flex-100">
    //         <TextHeading theme={theme} size={3} text="Account Holder" />
    //       </div>
    //       <p className={`${styles.address} flex-100`}>
    //         {accountHolder.first_name} {accountHolder.last_name} <br />
    //         {accountHolder.email} {accountHolder.phone} <br />
    //       </p>
    //     </div>
    //   </div>
    // ) : (
    //   ''
    // )
    // if (contacts) {
    //   contacts.forEach((n) => {
    //     if (n.type === 'notifyee') {
    //       nArray.push(<div key={v4()} className="flex-33 layout-row">
    //         <div className="flex-15 layout-column layout-align-start-center">
    //           <i className={` ${styles.icon} fa fa-user-circle-o flex-none`} style={textStyle} />
    //         </div>
    //         <div className="flex-85 layout-row layout-wrap layout-align-start-start">
    //           <div className="flex-100">
    //             <TextHeading theme={theme} size={3} text="Notifyee" />
    //           </div>
    //           <p className={` ${styles.address} flex-100`}>
    //             {n.contact.first_name} {n.contact.last_name} <br />
    //           </p>
    //         </div>
    //       </div>)
    //     }
    //     if (n.type === 'shipper') {
    //       shipperContact = (
    //         <div className="flex-33 layout-row">
    //           <div className="flex-15 layout-column layout-align-start-center">
    //             <i className={`${styles.icon} fa fa-user-circle-o flex-none`} style={textStyle} />
    //           </div>
    //           <div className="flex-85 layout-row layout-wrap layout-align-start-start">
    //             <div className="flex-100">
    //               <TextHeading theme={theme} size={3} text="Shipper" />
    //             </div>
    //             <p className={`${styles.address} flex-100`}>
    //               {n.contact.first_name} {n.contact.last_name} <br />
    //               {n.location.street} {n.location.street_number} <br />
    //               {n.location.zip_code} {n.location.city} <br />
    //               {n.location.country}
    //             </p>
    //           </div>
    //         </div>
    //       )
    //     }
    //     if (n.type === 'consignee') {
    //       consigneeContact = (
    //         <div className="flex-33 layout-row">
    //           <div className="flex-15 layout-column layout-align-start-center">
    //             <i className={`${styles.icon} fa fa-envelope-open-o flex-none`} style={textStyle} />
    //           </div>
    //           <div className="flex-85 layout-row layout-wrap layout-align-start-start">
    //             <div className="flex-100">
    //               <TextHeading theme={theme} size={3} text="Receiver" />
    //             </div>
    //             <p className={`${styles.address} flex-100`}>
    //               {n.contact.first_name} {n.contact.last_name} <br />
    //               {n.location.street} {n.location.street_number} <br />
    //               {n.location.zip_code} {n.location.city} <br />
    //               {n.location.country}
    //             </p>
    //           </div>
    //         </div>
    //       )
    //     }
    //   })
    // }
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
      // , customs_declaration: false,
      // customs_value_declaration: false,
      // eori: false,
      // certificate_of_origin: false,
      // dangerous_goods: false,
      // bill_of_lading: false,
      // invoice: false
    }

    if (documents) {
      documents.forEach((doc) => {
        docChecker[doc.doc_type] = true
        docView.push(<div className="flex-100 flex-md-45 flex-gt-md-30 layout-row" style={{ padding: '10px' }}>
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
    const feeHash = shipment.selected_offer
    const etdJSX = (
      <p className={`flex-none letter_3 ${styles.date}`}>
        {`${moment(shipment.planned_etd).format('DD/MM/YYYY | HH:mm')}`}
      </p>
    )
    const cargoCount = Object.keys(feeHash.cargo).length - 2
    const etaJSX = (
      <p className={`flex-none letter_3 ${styles.date}`}>
        {`${moment(shipment.planned_eta).format('DD/MM/YYYY | HH:mm')}`}
      </p>
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start padding_top">
        <div className={`${adminStyles.margin_box_right} layout-row flex-100 layout-align-center-stretch`}>
          <div className={`layout-row flex layout-align-start-center ${adminStyles.title_grey}`}>
            <p className="layout-align-start-center layout-row">Shipment</p>
          </div>
          {reuseShipment}
          {statusRequested}
          {statusInProcess}
          {statusFinished}
        </div>

        <div className={`flex-100 layout-row layout-wrap layout-align-center-center ${styles.ref_row}`}>
          <p className="layout-row flex-md-30 flex-20">Ref:&nbsp; <span>{shipment.imc_reference}</span></p>
          <hr className="layout-row flex-md-40 flex-55" />
          <p className="layout-row flex-md-30 flex-25 layout-align-end-center"><strong>Placed at:&nbsp;</strong> {createdDate}</p>
        </div>
        <div className="layout-row flex-100 margin_bottom">

          <GradientBorder
            wrapperClassName={`layout-row flex-40 ${styles.hub_box_shipment}`}
            gradient={gradientBorderStyle}
            className="layout-row flex"
            content={(
              <div className="layout-row flex-100">
                <ShipmentOverviewShowCard
                  et={etdJSX}
                  hub={shipment.origin_hub}
                  bg={bg1}
                />
              </div>
            )}
          />
          <div className="layout-row flex-20 layout-align-center-center">
            <div className={`layout-column flex layout-align-center-center ${styles.font_adjustaments}`}>
              <div className="layout-align-center-center layout-row" style={gradientStyle}>
                {switchIcon(shipment)}
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
                  hub={shipment.destination_hub}
                  bg={bg2}
                />
              </div>
            )}
          />
        </div>

        <div className={`flex-100 layout-row layout-align-space-between-start ${styles.info_delivery} margin_bottom`}>
          <div className="layout-column flex-60 layout-align-center-stretch">
            <div className="layout-row flex-100 layout-align-start-center">
              <div className="flex-40 layout-row layout-align-start-center">
                <i className={`flex-none fa fa-check-square clip ${styles.check_square}`} style={shipment.pickup_address ? selectedStyle : deselectedStyle} />
                <h4 className="flex-95 layout-row">Pick-up</h4>
              </div>
              <div className="flex-40 layout-row layout-align-start-center">
                <p>{moment(shipment.planned_pickup_date)
                  .subtract(shipment.trucking.pre_carriage.trucking_time_in_seconds, 'seconds')
                  .format('DD/MM/YYYY') }</p>
              </div>
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
                  <p>{shipment.pickup_address.street} &nbsp;
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
                <div className={`layout-row flex-95 layout-align-start-center ${styles.carriage_address} ${styles.margin_fixes}`}>
                  {/* <i className={`fa fa-map-marker clip ${styles.markerIcon}`} style={selectedStyle} /> */}
                  <p>{shipment.delivery_address.street}&nbsp;
                    {shipment.delivery_address.street_number},&nbsp;
                    <strong>{shipment.delivery_address.city},&nbsp;
                      {shipment.delivery_address.country.name} </strong>

                  </p>
                </div>
              ) : ''}
            </div>
          </div>
        </div>

        {/* <div className={`${adminStyles.border_box} margin_bottom layout-sm-column layout-xs-column layout-row flex-100`}>
          <div className={`flex-50 flex-sm-100 flex-xs-100 layout-row ${styles.services_box}`}>
            <div className="layout-column flex-100">
              <h3>Freight, Duties & Carriage:</h3>
              <div className="layout-wrap layout-row flex">
                <div className="layout-row flex-50 margin_bottom">
                  <i className="fa fa-truck clip flex-none layout-align-center-center" style={shipment.has_pre_carriage ? selectedStyle : deselectedStyle} />
                  <p>Pre-Carriage</p>
                </div>
                <div className="layout-row flex-50 margin_bottom">
                  <i className="fa fa-truck clip flex-none layout-align-center-center" style={shipment.has_on_carriage ? selectedStyle : deselectedStyle} />
                  <p>On-Carriage</p>
                </div>
                <div className="layout-row flex-50 margin_bottom">
                  <i className="fa fa-file-text clip flex-none layout-align-center-center" style={shipment.has_pre_carriage ? selectedStyle : deselectedStyle} />
                  <p>Origin Documentation</p>
                </div>
                <div className="layout-row flex-50 margin_bottom">
                  <i className="fa fa-file-text-o clip flex-none layout-align-center-center" style={shipment.has_on_carriage ? selectedStyle : deselectedStyle} />
                  <p>Destination Documentation</p>
                </div>
                <div className="layout-row flex-50 margin_bottom">
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
                <div className="layout-row flex-50 margin_bottom">
                  <i className="fa fa-id-card clip flex-none" style={feeHash.customs ? selectedStyle : deselectedStyle} />
                  <p>Customs</p>
                </div>
                <div className="layout-row flex-50 margin_bottom">
                  <i className="fa fa-umbrella clip flex-none" style={feeHash.customs ? selectedStyle : deselectedStyle} />
                  <p>Insurance</p>
                </div>
              </div>
            </div>
          </div>

          <div className={`flex-20 flex-sm-100 flex-xs-100 layout-row layout-align-center-center layout-padding ${styles.services_box}`}>
            <div className="layout-column flex-100">
              <div className="layout-row layout-align-sm-end-center layout-align-xs-center-center flex-100">
                <div className="layout-align-center-center layout-row flex">
                  <span style={gradientStyle} className={`layout-align-center-center layout-row flex-20 flex-sm-5 flex-xs-5 ${styles.quantity_square}`}>x&nbsp;{cargoCount}</span>
                  <p className="layout-align-sm-end-center layout-align-xs-end-center">{UserShipmentView.calcCargoLoad(feeHash, shipment.load_type)}</p>
                </div>
              </div>
              <h2 className="layout-align-end-center layout-row flex">{formattedPriceValue(totalPrice(shipment).value)} {totalPrice(shipment).currency}</h2>
            </div>
          </div>
        </div> */}
        <div className={`${adminStyles.border_box} margin_bottom layout-sm-column layout-xs-column layout-row flex-100`}>
          <div className={`flex-50 flex-sm-100 flex-xs-100 layout-row ${styles.services_box}`}>
            <div className="layout-column flex-100">
              <h3>Freight, Duties & Carriage:</h3>
              <div className="layout-wrap layout-row flex">
                <div className="layout-column flex-45 margin_bottom">
                  <div className="layout-row flex-100">
                    <div className="flex-none layout-row">
                      <i className="fa fa-truck clip flex-none layout-align-center-center" style={shipment.has_pre_carriage ? selectedStyle : deselectedStyle} />
                      <p>Pre-Carriage</p>
                    </div>
                    {scope.detailed_billing && feeHash.trucking_pre ? <div className="flex layout-row layout-align-end-center">
                      <p>
                        {feeHash.trucking_pre ? feeHash.trucking_pre.total.currency : ''}
                        { ' ' }
                        {feeHash.trucking_pre.edited_total
                          ? parseFloat(feeHash.trucking_pre.edited_total.value).toFixed(2)
                          : parseFloat(feeHash.trucking_pre.total.value).toFixed(2)}
                      </p>
                    </div>
                      : '' }
                  </div>
                </div>
                <div className="layout-column flex-offset-10 flex-45 margin_bottom">
                  <div className="layout-row flex-100">
                    <div className="flex-none layout-row">
                      <i
                        className="fa fa-truck clip flex-none layout-align-center-center"
                        style={shipment.has_on_carriage ? selectedStyle : deselectedStyle}
                      />
                      <p>On-Carriage</p>
                    </div>
                    {scope.detailed_billing && feeHash.trucking_on ? <div className="flex layout-row layout-align-end-center">
                      <p>
                        {feeHash.trucking_on ? feeHash.trucking_on.total.currency : ''}
                        { ' ' }
                        {feeHash.trucking_on.edited_total
                          ? parseFloat(feeHash.trucking_on.edited_total.value).toFixed(2)
                          : parseFloat(feeHash.trucking_on.total.value).toFixed(2)}
                      </p>
                    </div>
                      : ''}

                  </div>
                </div>
                <div className="layout-column flex-45 margin_bottom">
                  <div className="layout-row flex-100">
                    <div className="layout-row flex-none">
                      <i
                        className="fa fa-file-text clip flex-none layout-align-center-center"
                        style={shipment.has_pre_carriage ? selectedStyle : deselectedStyle}
                      />
                      <p>
                      Origin<br />
                      Documentation
                      </p>
                    </div>
                    {scope.detailed_billing && feeHash.export ? <div className="flex layout-row layout-align-end-center">
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
                <div
                  className="layout-column flex-offset-10 flex-45 margin_bottom"
                >
                  <div className="layout-row flex-100">
                    <div className="layout-row flex-none">
                      <i
                        className="fa fa-file-text-o clip flex-none layout-align-center-center"
                        style={shipment.has_on_carriage ? selectedStyle : deselectedStyle}
                      />
                      <p>
                      Destination<br />
                      Documentation
                      </p>
                    </div>
                    {scope.detailed_billing && feeHash.import ? <div className="flex layout-row layout-align-end-center">
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
                <div className="layout-column flex-45 margin_bottom">
                  <div className="layout-row flex-100">
                    <div className="layout-row flex-none">
                      <i
                        className="fa fa-ship clip flex-none layout-align-center-center"
                        style={selectedStyle}
                      />
                      <p>Freight</p>
                    </div>
                    {scope.detailed_billing && feeHash.cargo
                      ? <div className="flex layout-row layout-align-end-center">
                        <p>
                          {feeHash.cargo ? feeHash.cargo.total.currency : ''}
                          { ' ' }
                          {feeHash.cargo.edited_total
                            ? parseFloat(feeHash.cargo.edited_total.value).toFixed(2)
                            : parseFloat(feeHash.cargo.total.value).toFixed(2)}
                        </p>
                      </div>
                      : ''}
                  </div>

                </div>
              </div>
            </div>
          </div>
          <div className={`flex-30 layout-row flex-sm-100 flex-xs-100 ${styles.additional_services} ${styles.services_box} ${styles.border_right}`}>
            <div className="layout-column flex-80">
              <h3>Additional Services</h3>
              <div className="">
                <div className="layout-column flex-100 margin_bottom">
                  <div className="layout-row flex-100">
                    <div className="layout-row flex-none">
                      <i className="fa fa-id-card clip flex-none" style={feeHash.customs ? selectedStyle : deselectedStyle} />
                      <p>Customs</p>
                    </div>
                    {scope.detailed_billing && feeHash.customs
                      ? <div className="flex layout-row layout-align-end-center">
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
                <div className="layout-column flex-100 margin_bottom">
                  <div className="layout-row flex-100">
                    <div className="layout-row flex-none">
                      <i className="fa fa-umbrella clip flex-none" style={feeHash.customs ? selectedStyle : deselectedStyle} />
                      <p>Insurance</p>
                    </div>
                    {scope.detailed_billing && feeHash.insurance && (feeHash.insurance.value || feeHash.insurance.edited_total)
                      ? <div className="flex layout-row layout-align-end-center">
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
                    {scope.detailed_billing && feeHash.insurance && !feeHash.insurance.value && !feeHash.insurance.edited_total
                      ? <div className="flex layout-row layout-align-end-center">
                        <p>Requested  </p>
                      </div> : ''}
                  </div>
                </div>
              </div>
            </div>
            <div className="layout-row layout-padding flex-20 layout-align-center-start" />
          </div>
          <div className={`flex-20 flex-sm-100 flex-xs-100 layout-row layout-align-center-center layout-padding ${styles.services_box}`}>
            <div className="layout-column flex-100">
              <div className="layout-row layout-align-sm-end-center layout-align-xs-center-center flex-100">
                <div className="layout-align-center-center layout-row flex">
                  <span style={gradientStyle} className={`layout-align-center-center layout-row flex-20 flex-sm-5 flex-xs-5 ${styles.quantity_square}`}>x&nbsp;{cargoCount}</span>
                  <p className="layout-align-sm-end-center layout-align-xs-end-center">{UserShipmentView.calcCargoLoad(feeHash, shipment.load_type)}</p>
                </div>
              </div>
              <h2 className="layout-align-end-center layout-row flex">
                {formattedPriceValue(totalPrice(shipment).value)} {totalPrice(shipment).currency}
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
          contentClassName="layout-row layout-wrap flex"
          content={(
            <div className={`flex-100 layout-row padding_bottom padding_top layout-wrap layout-align-start-center ${adminStyles.padding_left}`}>
              <div className="flex-100 layout-row layout-wrap layout-align-start-center ">
                <div className="flex-50 layout-align-start-center layout-row">
                  <p className={`${styles.sec_subheader_text} flex-none letter_3`}>
                    Upload New Document
                  </p>
                  <StyledSelect
                    name="file-type"
                    className={`${styles.select} flex-50`}
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
              <div className="flex-100 layout-row layout-wrap layout-align-start-center ">
                {docView}
              </div>
              {missingDocs}
            </div>
          )}
        />

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
