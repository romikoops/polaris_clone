import React, { Component } from 'react'
import { connect } from 'react-redux'
import { withNamespaces } from 'react-i18next'
import { has } from 'lodash'
import Tabs from '../Tabs/Tabs'
import Tab from '../Tabs/Tab'
import styles from '../Admin/AdminShipments.scss'
import adminStyles from '../Admin/Admin.scss'
import quoteStyles from '../Quote/Card/index.scss'
import GradientBorder from '../GradientBorder'
import ShipmentOverviewShowCard from '../Admin/AdminShipmentView/ShipmentOverviewShowCard'
import { moment, documentTypes } from '../../constants'
import {
  switchIcon,
  numberSpacing,
  totalPrice,
  cargoPlurals,
  capitalize
} from '../../helpers'
import GreyBox from '../GreyBox/GreyBox'
import ShipmentNotes from '../ShipmentNotes'
import QuoteChargeBreakdown from '../QuoteChargeBreakdown/QuoteChargeBreakdown'
import CargoItemSummary from '../Cargo/Item/Summary'
import CargoContainerSummary from '../Cargo/Container/Summary'

class ShipmentQuotationContent extends Component {
  constructor (props) {
    super(props)
    this.state = {
      fileType: { label: `${this.props.t('common:packingSheet')}`, value: 'packing_sheet' }
    }
    this.setFileType = this.setFileType.bind(this)
  }

  componentDidMount () {
    this.getRemarks()
  }

  getRemarks () {
    const { remarkDispatch } = this.props
    remarkDispatch.getRemarks()
  }

  setFileType (ev) {
    this.setState({ fileType: ev })
  }

  deleteDoc (doc) {
    const { adminDispatch } = this.props
    adminDispatch.deleteDocument(doc.id)
  }

  render () {
    const {
      theme,
      gradientBorderStyle,
      gradientStyle,
      estimatedTimes,
      background,
      selectedStyle,
      deselectedStyle,
      scope,
      feeHash,
      t,
      cargoView,
      remark,
      cargo,
      pricingBreakdowns,
      newPrices,
      showEditServicePrice,
      toggleEditServicePrice,
      saveNewEditedPrice,
      handlePriceChange,
      shipmentData
    } = this.props

    const {
      documents,
      accountHolder,
      shipment,
      containers,
      cargoItems,
      aggregatedCargo
    } = shipmentData

    const remarkBody = remark.quotation ? remark.quotation.shipment.map(_remark => (
      <li>
        {_remark.body}
      </li>
    )) : ''
    const {
      fileType
    } = this.state

    const docChecker = {
      packing_sheet: false,
      commercial_invoice: false
    }
    const showCargoSummary = !aggregatedCargo
    let cargoSummary
    if (showCargoSummary && cargoItems.length) {
      cargoSummary = <CargoItemSummary items={cargoItems} t={t} mot={shipment.mode_of_transport} scope={scope} />
    } else if (showCargoSummary && containers.length) {
      cargoSummary = <CargoContainerSummary items={containers} t={t} />
    }

    const docView = []
    const missingDocs = []
    const documentUrl = `/admin/shipments/${shipment.id}/upload/${fileType.value}`

    if (documents) {
      const uploadedDocs = documents.reduce((docObj, item) => {
        docObj[item.doc_type] = docObj[item.doc_type] || []
        docObj[item.doc_type].push(item)

        return docObj
      }, {})

      Object.keys(uploadedDocs).forEach((key) => {
        docChecker[key] = true
        if (key !== 'shipment_recap') {
          docView.push(<div className={`flex-35 layout-row layout-align-start-start layout-padding ${adminStyles.uploaded_doc}`}>
            <i className="fa fa-check flex-none" style={{ color: 'rgb(13, 177, 75)' }} />
            <div className="layout-row flex layout-wrap" style={{ marginBottom: '12px' }}>
              <h4 className="flex-100 layout-row">{documentTypes[key]}</h4>
              {uploadedDocs[key].map(doc => (
                <div className="flex-100 layout-row">
                  <a
                    href={doc.signed_url}
                    className={`${styles.eye_link} flex-none layout-row layout-align-center-center`}
                    target="_blank"
                  >
                    <i className="fa fa-eye pointy flex-none" />
                  </a>
                  <i
                    className="fa fa-trash pointy flex-none"
                    onClick={() => this.deleteDoc(doc)}
                  />
                  <p className="flex layout-row">
                    {doc.text}
                  </p>
                </div>
              ))}
            </div>
          </div>)
        }
      })
    }
    Object.keys(docChecker).forEach((key) => {
      if (!docChecker[key]) {
        missingDocs.push(<div className={`flex-25 layout-padding layout-row layout-align-start-center ${adminStyles.no_doc}`}>
          <div className="flex-none layout-row layout-align-center-center">
            <i className="flex-none fa fa-ban" />
          </div>
          <div className="flex layout-align-start-center layout-row">
            <p className="flex-none">{`${documentTypes[key]}: ${t('doc:notUploaded')}`}</p>
          </div>
        </div>)
      }
    })

    return (
      <Tabs
        wrapperTabs="layout-row flex-100 margin_bottom"
      >
        <Tab
          tabTitle={t('common:overview')}
          theme={theme}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-center-center  padding_top">
            <div className="layout-row flex-100 margin_bottom">
              <GradientBorder
                wrapperClassName={`layout-row flex-40 ${styles.hub_box_shipment}`}
                gradient={gradientBorderStyle}
                className="layout-row flex"
                content={(
                  <div className="layout-row flex-100">
                    <ShipmentOverviewShowCard
                      et={shipment.pickup_address ? estimatedTimes.etdJSX : null}
                      text={t('common:etd')}
                      shipment={shipment}
                      theme={theme}
                      hub={shipment.origin_hub}
                      background={background.bg1}
                    />
                  </div>
                )}
              />
              <div className="layout-row flex-20 layout-align-center-center">
                <div className={`layout-column flex layout-align-center-center ${styles.font_adjustaments}`}>
                  <div className="layout-align-center-center layout-row" style={gradientStyle}>
                    {switchIcon(shipment)}
                  </div>
                  {shipment.planned_eta && shipment.planned_etd ? (
                    <div className="flex-100 layout-align-center-center layout-wrap layout-row">
                      <p className="flex-100 layout-row layout-align-center-center">{t('shipment:estimatedTimeDelivery')}</p>
                      <h5>
                        {moment(shipment.planned_eta).diff(moment(shipment.planned_etd), `${t('common:days')}`)}
                        {' '}
                        {t('common:days')}
                      </h5>
                    </div>
                  ) : ''}

                </div>
              </div>

              <GradientBorder
                wrapperClassName={`layout-row flex-40 ${styles.hub_box_shipment}`}
                gradient={gradientBorderStyle}
                className="layout-row flex"
                content={(
                  <div className="layout-row flex-100">
                    <ShipmentOverviewShowCard
                      text={t('common:eta')}
                      shipment={shipment}
                      theme={theme}
                      et={shipment.delivery_address ? estimatedTimes.etaJSX : null}
                      hub={shipment.destination_hub}
                      background={background.bg2}
                    />
                  </div>
                )}
              />
            </div>
          </div>
        </Tab>
        <Tab
          tabTitle={t('shipment:freight')}
          theme={theme}
        >
          <div className="flex-100 layout-row layout-align-start-start padding_top card_margin_right">
            <div className={`${adminStyles.border_box} margin_bottom layout-column flex-55`}>
              <div className={`${adminStyles.border_box} margin_bottom layout-sm-column layout-xs-column layout-row flex-100 `}>
                <div className={`flex-50 flex-sm-100 flex-xs-100 layout-row ${styles.services_box}`}>
                  <div className="layout-column flex-100">
                    <h3>{t('shipment:freightDutiesAndCarriage')}</h3>
                    <div className="layout-wrap layout-row flex">
                      <div className="flex-45 margin_bottom">
                        <div className="layout-row flex-100">
                          <div className="flex-100 layout-wrap layout-row">
                            <div className="flex-100 layout-row">
                              <i className="fa fa-truck clip flex-none layout-align-center-center" style={shipment.has_pre_carriage ? selectedStyle : deselectedStyle} />
                              <p>{t('shipment:pickUp')}</p>
                            </div>
                            {has(feeHash, 'trucking_pre.total.currency') ? (
                              <div className="flex-100 layout-row layout-align-end-center">
                                <p>
                                  {feeHash.trucking_pre ? feeHash.trucking_pre.total.currency : ''}
                                  { ' ' }
                                  {feeHash.trucking_pre.edited_total
                                    ? parseFloat(feeHash.trucking_pre.edited_total.value).toFixed(2)
                                    : parseFloat(feeHash.trucking_pre.total.value).toFixed(2)}
                                </p>
                              </div>
                            )
                              : '' }
                            {showEditServicePrice && shipment.selected_offer.trucking_pre ? (
                              <div className={`layout-row flex-100 layout-align-end-stretch ${styles.greyborder}`}>
                                <span
                                  className={
                                    `layout-row flex-100 layout-padding
                              layout-align-center-center ${styles.greybg}`
                                  }
                                >
                                  {newPrices.trucking_pre.currency}
                                </span>
                                <input
                                  type="number"
                                  onChange={e => handlePriceChange('trucking_pre', e.target.value)}
                                  value={newPrices.trucking_pre.value}
                                  className="layout-padding flex-70 layout-row flex-initial"
                                />
                              </div>
                            ) : (
                              ''
                            )}
                          </div>

                        </div>
                      </div>
                      <div className="flex-offset-10 flex-45 margin_bottom">
                        <div className="layout-row flex-100">
                          <div className="flex-100 layout-wrap layout-row">
                            <div className="flex-100 layout-row">
                              <i
                                className="fa fa-truck clip flex-none layout-align-center-center"
                                style={shipment.has_on_carriage ? selectedStyle : deselectedStyle}
                              />
                              <p>{t('shipment:delivery')}</p>
                            </div>
                            {has(feeHash, 'trucking_on.total.currency') ? (
                              <div className="flex-100 layout-row layout-align-end-center">
                                <p>
                                  {feeHash.trucking_on ? feeHash.trucking_on.total.currency : ''}
                                  { ' ' }
                                  {feeHash.trucking_on.edited_total
                                    ? parseFloat(feeHash.trucking_on.edited_total.value).toFixed(2)
                                    : parseFloat(feeHash.trucking_on.total.value).toFixed(2)}
                                </p>
                              </div>
                            )
                              : ''}
                            {showEditServicePrice && shipment.selected_offer.trucking_on ? (
                              <div className={`layout-row flex-100 layout-align-end-stretch ${styles.greyborder}`}>
                                <span
                                  className={
                                    `layout-row flex-100 layout-padding
                              layout-align-center-center ${styles.greybg}`
                                  }
                                >
                                  {newPrices.trucking_on.currency}
                                </span>
                                <input
                                  type="number"
                                  onChange={e => handlePriceChange('trucking_on', e.target.value)}
                                  value={newPrices.trucking_on.value}
                                  className="layout-padding layout-row flex-70 flex-initial"
                                />
                              </div>
                            ) : (
                              ''
                            )}
                          </div>
                        </div>
                      </div>
                      <div className="flex-45 margin_bottom">
                        <div className="layout-row flex-100">
                          <div className="flex-100 layout-wrap layout-row">
                            <div className="layout-row flex-100">
                              <i
                                className="fa fa-file-text clip flex-none layout-align-center-center"
                                style={feeHash.export ? selectedStyle : deselectedStyle}
                              />
                              <p>
                                {t('shipment:originLocalCharges')}
                              </p>
                            </div>
                            {has(feeHash, 'export.total.currency') ? (
                              <div className="flex-100 layout-row layout-align-end-center">
                                <p>
                                  {feeHash.export ? feeHash.export.total.currency : ''}
                                  { ' ' }
                                  {feeHash.export.edited_total
                                    ? parseFloat(feeHash.export.edited_total.value).toFixed(2)
                                    : parseFloat(feeHash.export.total.value).toFixed(2)}
                                </p>
                              </div>
                            )
                              : ''}
                            {showEditServicePrice && shipment.selected_offer.export ? (
                              <div className={`layout-row flex-100 layout-align-end-stretch ${styles.greyborder}`}>
                                <span
                                  className={
                                    `layout-row flex-100 layout-padding
                              layout-align-center-center ${styles.greybg}`
                                  }
                                >
                                  {newPrices.export.currency}
                                </span>
                                <input
                                  type="number"
                                  onChange={e => handlePriceChange('export', e.target.value)}
                                  value={newPrices.export.value}
                                  className="layout-padding layout-row flex-70 flex-initial"
                                />
                              </div>
                            ) : (
                              ''
                            )}
                          </div>
                        </div>
                      </div>
                      <div
                        className="flex-offset-10 flex-45 margin_bottom"
                      >
                        <div className="layout-row flex-100">
                          <div className="layout-row flex-100 layout-wrap">
                            <div className="flex-100 layout-row">
                              <i
                                className="fa fa-file-text-o clip flex-none layout-align-center-center"
                                style={feeHash.import ? selectedStyle : deselectedStyle}
                              />
                              <p>
                                {t('shipment:destinationLocalCharges')}
                              </p>
                            </div>
                            {has(feeHash, 'import.total.currency') ? (
                              <div className="flex-100 layout-row layout-align-end-center">
                                <p>
                                  {feeHash.import ? feeHash.import.total.currency : ''}
                                  { ' ' }
                                  {feeHash.import.edited_total
                                    ? parseFloat(feeHash.import.edited_total.value).toFixed(2)
                                    : parseFloat(feeHash.import.total.value).toFixed(2)}
                                </p>
                              </div>
                            )
                              : ''}
                            {showEditServicePrice && shipment.selected_offer.import ? (
                              <div className={`layout-row flex-100 layout-align-end-stretch ${styles.greyborder}`}>
                                <span
                                  className={
                                    `layout-row flex-100 layout-padding
                              layout-align-center-center ${styles.greybg}`
                                  }
                                >
                                  {newPrices.import.currency}
                                </span>
                                <input
                                  type="number"
                                  onChange={e => handlePriceChange('import', e.target.value)}
                                  value={newPrices.import.value}
                                  className="layout-padding layout-row flex-70 flex-initial"
                                />
                              </div>
                            ) : (
                              ''
                            )}
                          </div>
                        </div>
                      </div>
                      <div className="flex-45 margin_bottom">
                        <div className="layout-row flex-100">
                          <div className="layout-row layout-wrap flex-100">
                            <div className="flex-100 layout-row">
                              <i
                                className="fa fa-ship clip flex-none layout-align-center-center"
                                style={selectedStyle}
                              />
                              <p>{t('shipment:motCargo', { mot: capitalize(shipment.mode_of_transport) })}</p>
                            </div>
                            {has(feeHash, 'cargo.total.currency')
                              ? (
                                <div className="flex-100 layout-row layout-align-end-center">
                                  <p>
                                    {has(feeHash, 'cargo.total.currency') ? feeHash.cargo.total.currency : ''}
                                    { ' ' }
                                    {feeHash.cargo.edited_total
                                      ? parseFloat(feeHash.cargo.edited_total.value).toFixed(2)
                                      : parseFloat(feeHash.cargo.total.value).toFixed(2)}
                                  </p>
                                </div>
                              )
                              : ''}
                            {showEditServicePrice && shipment.selected_offer.cargo ? (
                              <div className={`layout-row flex-100 layout-align-end-stretch ${styles.greyborder}`}>
                                <span
                                  className={
                                    `layout-row flex-100 layout-padding
                              layout-align-center-center ${styles.greybg}`
                                  }
                                >
                                  {newPrices.cargo.currency}
                                </span>
                                <input
                                  type="number"
                                  onChange={e => handlePriceChange('cargo', e.target.value)}
                                  value={newPrices.cargo.value}
                                  className="layout-padding layout-row flex-70 flex-initial"
                                />
                              </div>
                            ) : (
                              ''
                            )}
                          </div>

                        </div>

                      </div>
                    </div>
                  </div>
                </div>
                { scope.customs_export_paper ? '' : (
                  <div className={`flex-25 layout-row flex-sm-100 flex-xs-100 ${styles.additional_services} ${styles.services_box} ${styles.border_right}`}>
                    <div className="layout-column flex-80">
                      <h3>{t('shipment:additionalServices')}</h3>
                      <div className="">
                        <div className="flex-100 margin_bottom">
                          <div className="layout-row flex-100">
                            <div className="layout-row flex-100 layout-wrap">
                              <div className="flex-100 layout-row">
                                <i className="fa fa-id-card clip flex-none" style={feeHash.customs ? selectedStyle : deselectedStyle} />
                                <p>{t('shipment:customs')}</p>
                              </div>
                              {feeHash.customs
                                ? (
                                  <div className="flex-100 layout-row layout-align-end-center">
                                    <p>
                                      {feeHash.customs ? feeHash.customs.total.currency : ''}
                                      { ' ' }
                                      {feeHash.customs.edited_total
                                        ? parseFloat(feeHash.customs.edited_total.value).toFixed(2)
                                        : parseFloat(feeHash.customs.total.value).toFixed(2)}
                                    </p>
                                  </div>
                                )
                                : '' }
                            </div>

                          </div>

                        </div>
                        <div className="flex-100 margin_bottom">
                          <div className="layout-row flex-100">
                            <div className="layout-row flex-100 layout-wrap">
                              <div className="flex-100 layout-row">
                                <i className="fa fa-umbrella clip flex-none" style={feeHash.customs ? selectedStyle : deselectedStyle} />
                                <p>{t('shipment:insurance')}</p>
                              </div>
                              {feeHash.insurance && (feeHash.insurance.value || feeHash.insurance.edited_total)
                                ? (
                                  <div className="flex-100 layout-row layout-align-end-center">
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
                                )
                                : '' }
                              {feeHash.insurance && !feeHash.insurance.value && !feeHash.insurance.edited_total
                                ? (
                                  <div className="flex-100 layout-row layout-align-end-center">
                                    <p>{t('shipment:requested')}</p>
                                  </div>
                                ) : ''}
                              {showEditServicePrice && shipment.selected_offer.insurance ? (
                                <div className={`layout-row flex-100 layout-align-end-stretch ${styles.greyborder}`}>
                                  <span
                                    className={
                                      `layout-row flex-100 layout-padding
                              layout-align-center-center ${styles.greybg}`
                                    }
                                  >
                                    {newPrices.insurance.currency}
                                  </span>
                                  <input
                                    type="number"
                                    onChange={e => handlePriceChange('insurance', e.target.value)}
                                    value={newPrices.insurance.value}
                                    className="layout-padding layout-row flex-70 flex-initial"
                                  />
                                </div>
                              ) : (
                                ''
                              )}
                            </div>

                          </div>

                        </div>
                      </div>
                    </div>
                    <div className="layout-row layout-padding flex-20 layout-align-center-start">
                      {showEditServicePrice ? (
                        <div className="layout-column layout-align-center-center">
                          <div className={`layout-row layout-align-center-center ${styles.save}`}>
                            <i onClick={saveNewEditedPrice} className="fa fa-check" />
                          </div>
                          <div className={`layout-row layout-align-center-center ${styles.cancel}`}>
                            <i onClick={toggleEditServicePrice} className="fa fa-trash" />
                          </div>
                        </div>
                      ) : (
                        <i onClick={toggleEditServicePrice} className={`fa fa-edit ${styles.editIcon}`} />
                      )}
                    </div>
                  </div>
                ) }
                <div className={`flex-25 flex-sm-100 flex-xs-100 layout-row layout-align-center-center layout-padding ${styles.services_box}`}>
                  <div className="layout-column flex-100">
                    <div className="layout-row layout-align-sm-end-center layout-align-xs-center-center flex-100">
                      <div className="layout-align-start-center layout-row flex">
                        <span style={gradientStyle} className={`layout-align-center-center layout-row flex-none ${styles.quantity_square}`}>
                          x&nbsp;
                          {shipment.cargo_count}
                        </span>
                        <p className="layout-align-sm-end-center layout-align-xs-end-center">{cargoPlurals(shipment, t)}</p>
                      </div>
                    </div>
                    <h2 className="layout-align-start-center layout-row flex">
                      {numberSpacing(totalPrice(shipment).value, 2)}
                      {' '}
                      {totalPrice(shipment).currency}
                    </h2>
                  </div>
                </div>
              </div>
              {remarkBody ? (
                <div className={`${adminStyles.border_box} ${adminStyles.remark_box}
                                margin_bottom layout-sm-column layout-xs-column layout-row flex-100`}
                >
                  <div className={`flex-50 flex-sm-100 flex-xs-100 layout-row ${styles.services_box}`}>
                    <div className="layout-column flex-100">
                      <h3
                        style={{ marginBottom: '0px' }}
                      >
                        {`${t('shipment:remarks')}:`}
                      </h3>
                      <ul>
                        {remarkBody}
                      </ul>
                    </div>
                  </div>
                </div>
              ) : ''}
            </div>
            <div className="flex-100 flex-gt-md-40 layout-row">
              <div
                className={`flex-100 layout-row layout-wrap ${quoteStyles.wrapper}`}
              >
                <QuoteChargeBreakdown
                  theme={theme}
                  scope={scope}
                  cargo={cargoItems || containers}
                  shrinkHeaders
                  trucking={shipment.trucking}
                  showBreakdowns
                  metadata={shipment.meta}
                  pricingBreakdowns={pricingBreakdowns}
                  quote={shipment.selected_offer}
                  mot={shipment.mode_of_transport}
                />
                <div className="flex-100 layout-wrap layout-align-start-stretch">
                  <div className={`flex-100 layout-row layout-align-start-stretch ${quoteStyles.total_row}`}>
                    { has(feeHash, 'total.currency')
                      ? [
                        (<div className="flex-30 layout-row layout-align-start-center">
                          <span>{t('common:total')}</span>
                        </div>),
                        (<div className="flex-70 layout-row layout-align-end-center">
                          <p className="card_padding_right">
                            {`${numberSpacing(shipment.selected_offer.total.value, 2)} ${shipment.selected_offer.total.currency}`}
                          </p>
                        </div>)
                      ] : ''
                    }
                  </div>
                </div>
              </div>
            </div>
          </div>
        </Tab>
        <Tab
          tabTitle={t('cargo:cargoDetails')}
          theme={theme}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-center-center padding_top">
            <GreyBox
              wrapperClassName={`layout-row flex-100 ${adminStyles.no_margin_box_right}`}
              contentClassName="layout-column flex"
              content={cargoView}
            />
            <ShipmentNotes shipment={shipment} />
          </div>
        </Tab>
      </Tabs>
    )
  }
}

ShipmentQuotationContent.defaultProps = {
  theme: null,
  gradientBorderStyle: {},
  gradientStyle: {},
  estimatedTimes: {},
  shipment: {},
  background: {},
  selectedStyle: {},
  deselectedStyle: {},
  scope: {},
  feeHash: {},
  cargoView: null,
  pricingBreakdowns: []
}

function mapStateToProps (state) {
  const {
    remark
  } = state

  return {
    remark
  }
}

export default connect(mapStateToProps, null)(withNamespaces(['common', 'shipment', 'cargo'])(ShipmentQuotationContent))
