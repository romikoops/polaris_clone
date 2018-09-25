import React, { Component } from 'react'
import { v4 } from 'uuid'
import { pick, uniqWith } from 'lodash'
import { translate } from 'react-i18next'
import PropTypes from '../../prop-types'
import adminStyles from '../Admin/Admin.scss'
import styles from '../Admin/AdminShipments.scss'
import { CargoItemGroup } from '../Cargo/Item/Group'
import CargoItemGroupAggregated from '../Cargo/Item/Group/Aggregated'
import { CargoContainerGroup } from '../Cargo/Container/Group'
import { moment, documentTypes } from '../../constants'
import {
  gradientTextGenerator,
  gradientGenerator,
  gradientBorderGenerator
} from '../../helpers'
import '../../styles/select-css-custom.css'
import DocumentsForm from '../Documents/Form'
import GradientBorder from '../GradientBorder'
import { UserShipmentContent } from './UserShipmentContent'
import { ShipmentQuotationContent } from './ShipmentQuotationContent'

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
    this.props.setCurrentUrl('/account/shipments')
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
      theme, hubs, shipmentData, user, userDispatch, tenant, t
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
        <p className="layout-align-center-center layout-row">
          {t('common:inProcess')}
        </p>
      </div>
    ) : (
      ''
    )
    const reuseShipment = (
      <div style={gradientStyle} onClick={() => this.reuseShipment()} className={`layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25 layout-align-center-center pointy ${adminStyles.shipment_view_margin_buffer}  ${styles.reuse_shipment_box}`}>
        <p className="layout-align-center-center layout-row">
          {t('shipment:reuseShipment')}
        </p>
      </div>
    )

    const statusFinished = (shipment.status === 'finished') ? (
      <div style={gradientStyle} className={`layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25 layout-align-center-center ${adminStyles.header_margin_buffer}  ${styles.status_box}`}>
        <p className="layout-align-center-center layout-row"> {shipment.status} </p>
      </div>
    ) : (
      ''
    )
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
    const pickupDate = (
      <p className={`flex-none letter_3 ${styles.date}`}>
        {`${moment(shipment.planned_pickup_date).format('DD/MM/YYYY | HH:mm')}`}
      </p>
    )
    const deliveryDate = (
      <p className={`flex-none letter_3 ${styles.date}`}>
        {`${moment(shipment.planned_delivery_date).format('DD/MM/YYYY | HH:mm')}`}
      </p>
    )
    const originDropOffDate = (
      <p className={`flex-none letter_3 ${styles.date}`}>
        {`${moment(shipment.planned_origin_drop_off_date).format('DD/MM/YYYY | HH:mm')}`}
      </p>
    )
    const destinationCollectionDate = (
      <p className={`flex-none letter_3 ${styles.date}`}>
        {`${moment(shipment.planned_destination_collection_date).format('DD/MM/YYYY | HH:mm')}`}
      </p>
    )

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start padding_top extra_padding">
        <div className={`${adminStyles.margin_box_right} layout-row flex-100 layout-align-center-stretch margin_bottom`}>
          <div className={`layout-row flex layout-align-space-between-center ${adminStyles.title_shipment_grey}`}>
            <p className="layout-align-start-center layout-row">{t('common:ref')}:&nbsp; <span>{shipment.imc_reference}</span></p>
            <p className="layout-row layout-align-end-end"><strong>{t('shipment:placedAt')}:&nbsp;</strong> {createdDate}</p>
          </div>
          {reuseShipment}
          {statusRequested}
          {statusInProcess}
          {statusFinished}
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-start-start padding_top">
          {shipment.status !== 'quoted' ? (
            <UserShipmentContent
              theme={theme}
              gradientBorderStyle={gradientBorderStyle}
              gradientStyle={gradientStyle}
              etdJSX={etdJSX}
              etaJSX={etaJSX}
              pickupDate={pickupDate}
              deliveryDate={deliveryDate}
              originDropOffDate={originDropOffDate}
              destinationCollectionDate={destinationCollectionDate}
              shipment={shipment}
              bg1={bg1}
              bg2={bg2}
              selectedStyle={selectedStyle}
              deselectedStyle={deselectedStyle}
              scope={scope}
              contacts={contacts}
              user={user}
              upUrl={this.state.upUrl}
              fileType={this.state.fileType}
              setFileType={this.setFileType}
              feeHash={feeHash}
              docOptions={docOptions}
              userDispatch={userDispatch}
              docView={docView}
              cargoCount={cargoCount}
              missingDocs={missingDocs}
              cargoView={cargoView}
              calcCargoLoad={UserShipmentView.calcCargoLoad(feeHash, shipment.load_type)}
            />) : (
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
              scope={scope}
              feeHash={feeHash}
              cargoView={cargoView}
            />
          )}

        </div>
      </div>
    )
  }
}

UserShipmentView.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  hubs: PropTypes.arrayOf(PropTypes.object),
  loading: PropTypes.bool,
  shipmentData: PropTypes.shipmentData.isRequired,
  user: PropTypes.user,
  userDispatch: PropTypes.shape({
    deleteDocument: PropTypes.func
  }).isRequired,
  match: PropTypes.match.isRequired,
  setNav: PropTypes.func.isRequired,
  setCurrentUrl: PropTypes.func.isRequired,
  tenant: PropTypes.tenant
}

UserShipmentView.defaultProps = {
  theme: null,
  hubs: [],
  loading: false,
  user: null,
  tenant: {}
}

export default translate(['common', 'shipment', 'bookconf', 'cargo'])(UserShipmentView)
