import React, { Component } from 'react'
import { v4 } from 'uuid'
import { pick, uniqWith } from 'lodash'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../prop-types'
import adminStyles from '../Admin/Admin.scss'
import styles from '../Admin/AdminShipments.scss'
import CargoItemGroup from '../Cargo/Item/Group'
import CargoItemGroupAggregated from '../Cargo/Item/Group/Aggregated'
import CargoContainerGroup from '../Cargo/Container/Group'
import { moment } from '../../constants'
import {
  gradientTextGenerator,
  gradientGenerator,
  gradientBorderGenerator
} from '../../helpers'
import '../../styles/select-css-custom.scss'
import DocumentsDownloader from '../Documents/Downloader'
import GradientBorder from '../GradientBorder'
import UserShipmentContent from './UserShipmentContent'
import ShipmentQuotationContent from './ShipmentQuotationContent'

class UserShipmentView extends Component {
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
      collapser: {}
    }

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
    const { tenant, theme, shipmentData } = this.props
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
        group={cargoGroups[k]}
        theme={theme}
        hsCodes={hsCodes}
        scope={tenant.scope}
        shipment={shipment}
        hideUnits={tenant.scope.cargo_overview_only}
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
      theme, hubs, shipmentData, user, userDispatch, tenant, t, remarkDispatch
    } = this.props

    if (!shipmentData || !hubs || !user) {
      return ''
    }
    const { scope } = tenant
    const {
      shipment,
      cargoItems,
      containers,
      aggregatedCargo
      // accountHolder
    } = shipmentData

    const createdDate = shipment
      ? moment(shipment.updated_at).format('DD/MM/YYYY | HH:mm')
      : moment().format('DD/MM/YYYY | HH:mm')
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

    const statusRequested = (['requested', 'requested_by_unconfirmed_account'].includes(shipment.status)) ? (
      <GradientBorder
        wrapperClassName={`layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25 ${adminStyles.header_margin_buffer}  ${styles.status_box_requested}`}
        gradient={gradientBorderStyle}
        className="layout-row flex-100 layout-align-center-center"
        content={(
          <p className="layout-align-center-center layout-row">
            {' '}
            {t('common:requested')}
            {' '}
          </p>
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
      <div style={gradientStyle} onClick={() => this.reuseShipment()} className={`layout-row flex-15 flex-md-15 flex-sm-20 flex-xs-25 layout-align-center-center pointy ${adminStyles.shipment_view_margin_buffer}  ${styles.reuse_shipment_box}`}>
        <p className="layout-align-center-center layout-row">
          {t('shipment:reuseShipment')}
        </p>
      </div>
    )

    const statusFinished = (shipment.status === 'finished') ? (
      <div style={gradientStyle} className={`layout-row flex-10 flex-md-15 flex-sm-20 flex-xs-25 layout-align-center-center ${adminStyles.header_margin_buffer}  ${styles.status_box}`}>
        <p className="layout-align-center-center layout-row">
          {' '}
          {t('common:finished')}
          {' '}
        </p>
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

    const feeHash = shipment.selected_offer
    const etdJSX = (
      <p className={`flex-none letter_3 ${styles.date}`}>
        {moment(shipment.planned_etd).format('DD/MM/YYYY')}
      </p>
    )
    const etaJSX = (
      <p className={`flex-none letter_3 ${styles.date}`}>
        {moment(shipment.planned_eta).format('DD/MM/YYYY')}
      </p>
    )
    const estimatedTimes = {
      etdJSX,
      etaJSX
    }

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start padding_top extra_padding">
        <div className={`${adminStyles.margin_box_right} layout-row flex-100 layout-wrap layout-align-center-stretch margin_bottom`}>
          <div className={`layout-row flex flex-sm-100 layout-align-space-between-center ${adminStyles.title_shipment_grey}`}>
            <p className="layout-align-start-center layout-row">
              {t('common:ref')}
              :&nbsp;
              {' '}
              <span>{shipment.imc_reference}</span>
            </p>
            <p className="layout-row layout-align-end-end">
              <strong>
                {t('shipment:placedAt')}
                :&nbsp;
              </strong>
              {' '}
              {createdDate}
            </p>
          </div>
          {user.internal ? reuseShipment : ''}
          {statusRequested}
          {statusInProcess}
          {statusFinished}
        </div>
        <div className="flex-100 layout-row layout-wrap layout-align-start-start padding_top">
          {shipment.status !== 'quoted' && !tenant.scope.quotation_tool ? (
            <UserShipmentContent
              theme={theme}
              gradientBorderStyle={gradientBorderStyle}
              gradientStyle={gradientStyle}
              estimatedTimes={estimatedTimes}
              background={background}
              selectedStyle={selectedStyle}
              deselectedStyle={deselectedStyle}
              scope={scope}
              match={this.props.match}
              feeHash={feeHash}
              cargoView={cargoView}
              shipmentData={shipmentData}
              user={user}
              cargo={cargoItems || containers}
              userDispatch={userDispatch}
              remarkDispatch={remarkDispatch}
            />) : (
              <ShipmentQuotationContent
              theme={theme}
              gradientBorderStyle={gradientBorderStyle}
              gradientStyle={gradientStyle}
              estimatedTimes={estimatedTimes}
              shipment={shipment}
              background={background}
              selectedStyle={selectedStyle}
              deselectedStyle={deselectedStyle}
              scope={scope}
              cargo={cargoItems || containers}
              feeHash={feeHash}
              cargoView={cargoView}
              remarkDispatch={remarkDispatch}
            />
          )}
          <div className="flex-100 layout-row layout-wrap">
            <div className="layout-row flex-100 layout-wrap layout-align-center-center" style={{ paddingTop: '30px' }}>
              <p
                className="flex-100 layout-row layout-align-center-center"
                style={{ paddingBottom: '14px', textAlign: 'center' }}
              >
                {shipment.status === 'quoted' ? t('doc:quotePDF') : t('doc:shipmentPDF')}
              </p>
              <DocumentsDownloader
                theme={theme}
                target={shipment.status === 'quoted' ? 'quote' : 'shipment_recap'}
                options={{ shipment }}
                size="full"
              />
            </div>
          </div>

        </div>
      </div>
    )
  }
}

UserShipmentView.defaultProps = {
  theme: null,
  hubs: [],
  loading: false,
  user: null,
  tenant: {}
}

export default withNamespaces(['common', 'shipment', 'bookconf', 'cargo', 'doc'])(UserShipmentView)
