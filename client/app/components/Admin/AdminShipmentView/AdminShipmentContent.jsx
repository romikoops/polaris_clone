import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from '../../../prop-types'
import Tabs from '../../Tabs/Tabs'
import Tab from '../../Tabs/Tab'
import styles from '../AdminShipments.scss'
import adminStyles from '../Admin.scss'
import GradientBorder from '../../GradientBorder'
import { moment, docOptions, documentTypes } from '../../../constants'
import { numberSpacing, totalPrice, cargoPlurals } from '../../../helpers'
import ShipmentOverviewShowCard from './ShipmentOverviewShowCard'
import ContactDetailsRow from './ContactDetailsRow'
import GreyBox from '../../GreyBox/GreyBox'
import { NamedSelect } from '../../NamedSelect/NamedSelect'
import FileUploader from '../../FileUploader/FileUploader'
import ShipmentNotes from '../../ShipmentNotes'

class AdminShipmentContent extends Component {
  static checkSelectedOffer (service) {
    let obj = {}
    if (service && service.total) {
      const total = service.edited_total || service.total
      obj = total
    }

    return obj
  }
  constructor (props) {
    super(props)
    this.state = {
      fileType: { label: `${this.props.t('common:packingSheet')}`, value: 'packing_sheet' }
    }
    this.setFileType = this.setFileType.bind(this)
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
      switchIcon,
      dnrEditKeys,
      pickupDate,
      adminDispatch,
      deliveryDate,
      originDropOffDate,
      destinationCollectionDate,
      showEditTime,
      saveNewTime,
      shipmentData,
      toggleEditTime,
      showEditServicePrice,
      toggleEditServicePrice,
      newPrices,
      feeHash,
      selectedStyle,
      deselectedStyle,
      cargoCount,
      cargoView,
      saveNewEditedPrice,
      t,
      handlePriceChange
    } = this.props

    const {
      contacts,
      shipment,
      documents,
      accountHolder
    } = shipmentData

    const {
      fileType
    } = this.state

    const docChecker = {
      packing_sheet: false,
      commercial_invoice: false
    }

    const docView = []
    const missingDocs = []
    const documentUrl = `/shipments/${shipment.id}/upload/${fileType.value}`

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
            <div className="layout-row layout-wrap flex-100 margin_bottom">

              <GradientBorder
                wrapperClassName={`layout-row flex-gt-sm-40 flex-100 ${styles.hub_box_shipment}`}
                gradient={gradientBorderStyle}
                className="layout-row flex"
                content={(
                  <div className="layout-row flex-100">
                    <ShipmentOverviewShowCard
                      estimatedTime={estimatedTimes.etdJSX}
                      carriage={pickupDate}
                      noCarriage={originDropOffDate}
                      text={t('common:etd')}
                      theme={theme}
                      hub={shipment.origin_hub}
                      shipment={shipment}
                      background={background.bg1}
                      editTime={showEditTime}
                      handleSaveTime={saveNewTime}
                      toggleEditTime={toggleEditTime}
                      isAdmin={!dnrEditKeys.includes(shipment.status)}
                    />
                  </div>
                )}
              />
              <div className="layout-row flex-100 flex-gt-sm-20 layout-align-center-center padd_20">
                <div className={`layout-column flex layout-align-center-center ${styles.font_adjustaments}`}>
                  <div className="layout-align-center-center layout-row" style={gradientStyle}>
                    {switchIcon()}
                  </div>
                  <p>{t('shipment:estimatedTimeDelivery')}</p>
                  <h5>{moment(shipment.planned_eta).diff(moment(shipment.planned_etd), `${t('common:days')}`)} {t('common:days')}</h5>
                </div>
              </div>

              <GradientBorder
                wrapperClassName={`layout-row flex-gt-sm-40 flex-100 ${styles.hub_box_shipment}`}
                gradient={gradientBorderStyle}
                className="layout-row flex"
                content={(
                  <div className="layout-row flex-100">
                    <ShipmentOverviewShowCard
                      estimatedTime={estimatedTimes.etaJSX}
                      carriage={deliveryDate}
                      noCarriage={destinationCollectionDate}
                      text={t('common:eta')}
                      theme={theme}
                      hub={shipment.destination_hub}
                      background={background.bg2}
                      shipment={shipment}
                      editTime={showEditTime}
                      handleSaveTime={saveNewTime}
                      toggleEditTime={toggleEditTime}
                      isAdmin={!dnrEditKeys.includes(shipment.status)}
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
          <div className="flex-100 layout-row layout-wrap layout-align-center-center  padding_top">
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
                          {feeHash.trucking_pre ? <div className="flex-100 layout-row layout-align-end-center">
                            <p>
                              {feeHash.trucking_pre ? feeHash.trucking_pre.total.currency : ''}
                              { ' ' }
                              {feeHash.trucking_pre.edited_total
                                ? parseFloat(feeHash.trucking_pre.edited_total.value).toFixed(2)
                                : parseFloat(feeHash.trucking_pre.total.value).toFixed(2)}
                            </p>
                          </div>
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
                          {feeHash.trucking_on ? <div className="flex-100 layout-row layout-align-end-center">
                            <p>
                              {feeHash.trucking_on ? feeHash.trucking_on.total.currency : ''}
                              { ' ' }
                              {feeHash.trucking_on.edited_total
                                ? parseFloat(feeHash.trucking_on.edited_total.value).toFixed(2)
                                : parseFloat(feeHash.trucking_on.total.value).toFixed(2)}
                            </p>
                          </div>
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
                              style={shipment.has_pre_carriage ? selectedStyle : deselectedStyle}
                            />
                            <p>
                              {t('shipment:originLocalCharges')}
                            </p>
                          </div>
                          {feeHash.export ? <div className="flex-100 layout-row layout-align-end-center">
                            <p>
                              {feeHash.export ? feeHash.export.total.currency : ''}
                              { ' ' }
                              {feeHash.export.edited_total
                                ? parseFloat(feeHash.export.edited_total.value).toFixed(2)
                                : parseFloat(feeHash.export.total.value).toFixed(2)}
                            </p>
                          </div>
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
                              style={shipment.has_on_carriage ? selectedStyle : deselectedStyle}
                            />
                            <p>
                              {t('shipment:destinationLocalCharges')}
                            </p>
                          </div>
                          {feeHash.import ? <div className="flex-100 layout-row layout-align-end-center">
                            <p>
                              {feeHash.import ? feeHash.import.total.currency : ''}
                              { ' ' }
                              {feeHash.import.edited_total
                                ? parseFloat(feeHash.import.edited_total.value).toFixed(2)
                                : parseFloat(feeHash.import.total.value).toFixed(2)}
                            </p>
                          </div>
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
                            <p>{t('shipment:freight')}</p>
                          </div>
                          {feeHash.cargo
                            ? <div className="flex-100 layout-row layout-align-end-center">
                              <p>
                                {feeHash.cargo ? feeHash.cargo.total.currency : ''}
                                { ' ' }
                                {feeHash.cargo.edited_total
                                  ? parseFloat(feeHash.cargo.edited_total.value).toFixed(2)
                                  : parseFloat(feeHash.cargo.total.value).toFixed(2)}
                              </p>
                            </div>
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
                            ? <div className="flex-100 layout-row layout-align-end-center">
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

                    </div>
                    <div className="flex-100 margin_bottom">
                      <div className="layout-row flex-100">
                        <div className="layout-row flex-100 layout-wrap">
                          <div className="flex-100 layout-row">
                            <i className="fa fa-umbrella clip flex-none" style={feeHash.customs ? selectedStyle : deselectedStyle} />
                            <p>{t('shipment:insurance')}</p>
                          </div>
                          {feeHash.insurance && (feeHash.insurance.value || feeHash.insurance.edited_total)
                            ? <div className="flex-100 layout-row layout-align-end-center">
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
                          {feeHash.insurance && !feeHash.insurance.value && !feeHash.insurance.edited_total
                            ? <div className="flex-100 layout-row layout-align-end-center">
                              <p>{t('shipment:requested')}</p>
                            </div> : ''}
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
              <div className={`flex-25 flex-sm-100 flex-xs-100 layout-row layout-align-center-center layout-padding ${styles.services_box}`}>
                <div className="layout-column flex-100">
                  <div className="layout-row layout-align-sm-end-center layout-align-xs-center-center flex-100">
                    <div className="layout-align-start-center layout-row flex">
                      <span style={gradientStyle} className={`layout-align-center-center layout-row flex-none ${styles.quantity_square}`}>x&nbsp;{shipment.cargo_count}</span>
                      <p className="layout-align-sm-end-center layout-align-xs-end-center">{cargoPlurals(shipment, t)}</p>
                    </div>
                  </div>
                  <h2 className="layout-align-start-center layout-row flex">
                    {numberSpacing(totalPrice(shipment).value, 2)} {totalPrice(shipment).currency}
                  </h2>
                </div>
              </div>
            </div>
          </div>

        </Tab>
        <Tab
          tabTitle={t('account:contacts')}
          theme={theme}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-center-center  padding_top">
            <ContactDetailsRow
              contacts={contacts}
              style={selectedStyle}
              accountId={shipment.user_id}
              user={accountHolder}
            />
          </div>
        </Tab>
        <Tab
          tabTitle={t('cargo:cargoDetails')}
          theme={theme}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-center-center  padding_top">
            <GreyBox

              wrapperClassName={`layout-row flex-100 ${adminStyles.no_margin_bottom}`}
              contentClassName="layout-column flex"
              content={cargoView}
            />
            <ShipmentNotes
              shipment={shipment}
            />
          </div>
        </Tab>
        <Tab
          tabTitle={t('common:documents')}
          theme={theme}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-center-center  padding_top">
            <GreyBox
              wrapperClassName="layout-row flex-100 padd_20 margin_bottom"
              contentClassName="flex"
              content={(
                <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${adminStyles.padding_left}`}>
                  <div className="flex-100 layout-row layout-wrap layout-align-start-center padding_bottom">
                    <div className="flex-50 layout-align-start-center layout-wrap layout-row">
                      <p className={`${styles.sec_subheader_text} flex-100 padding_bottom_sm padding_top`}>
                        {t('doc:uploadNewDocument')}
                      </p>
                      <div className="flex-100 layout-align-start-center layout-row padding_bottom">
                        <NamedSelect
                          name="file-type"
                          className={`${styles.select} flex-50`}
                          value={fileType}
                          options={docOptions}
                          clearable={false}
                          onChange={this.setFileType}
                        />
                        <div className="flex-50 layout-align-center-center layout-row padd_10">
                          <FileUploader
                            theme={theme}
                            formClasses="flex-100 layout-row layout-align-center-center"
                            url={documentUrl}
                            type={fileType.value}
                            text={fileType.label}
                            uploadFn={adminDispatch.uploadClientDocument}
                          />
                        </div>
                      </div>
                    </div>
                  </div>
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
              )}
            />
          </div>
        </Tab>
      </Tabs>
    )
  }
}

AdminShipmentContent.propTypes = {
  theme: PropTypes.theme,
  gradientBorderStyle: PropTypes.style,
  gradientStyle: PropTypes.style,
  estimatedTimes: PropTypes.objectOf(PropTypes.node),
  pickupDate: PropTypes.node,
  deliveryDate: PropTypes.node,
  originDropOffDate: PropTypes.node,
  destinationCollectionDate: PropTypes.node,
  shipment: PropTypes.shipment,
  background: PropTypes.objectOf(PropTypes.style),
  selectedStyle: PropTypes.style,
  deselectedStyle: PropTypes.style,
  feeHash: PropTypes.objectOf(PropTypes.any),
  cargoCount: PropTypes.number,
  cargoView: PropTypes.node,
  shipmentData: PropTypes.shipmentData,
  switchIcon: PropTypes.func,
  dnrEditKeys: PropTypes.arrayOf(PropTypes.string),
  showEditTime: PropTypes.bool,
  saveNewTime: PropTypes.func,
  t: PropTypes.func.isRequired,
  toggleEditTime: PropTypes.func,
  showEditServicePrice: PropTypes.bool,
  newPrices: PropTypes.objectOf(PropTypes.any),
  toggleEditServicePrice: PropTypes.func,
  saveNewEditedPrice: PropTypes.func,
  uploadClientDocument: PropTypes.func
}

AdminShipmentContent.defaultProps = {
  theme: null,
  gradientBorderStyle: {},
  gradientStyle: {},
  shipmentData: null,
  estimatedTimes: {},
  pickupDate: null,
  deliveryDate: null,
  originDropOffDate: null,
  destinationCollectionDate: null,
  toggleEditServicePrice: null,
  uploadClientDocument: null,
  saveNewEditedPrice: null,
  shipment: {},
  background: {},
  selectedStyle: {},
  deselectedStyle: {},
  feeHash: {},
  cargoCount: 0,
  cargoView: null,
  switchIcon: null,
  dnrEditKeys: [],
  showEditTime: false,
  saveNewTime: null,
  toggleEditTime: null,
  showEditServicePrice: false,
  newPrices: {}
}

export default withNamespaces(['common', 'shipment', 'doc', 'cargo', 'account'])(AdminShipmentContent)
