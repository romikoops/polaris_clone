import React, { Component } from 'react'
import Select from 'react-select'
import styled from 'styled-components'
import PropTypes from '../../prop-types'
import Tabs from '../Tabs/Tabs'
import Tab from '../Tabs/Tab'
import styles from '../Admin/AdminShipments.scss'
import adminStyles from '../Admin/Admin.scss'
import GradientBorder from '../GradientBorder'
import ShipmentOverviewShowCard from '../Admin/AdminShipmentView/ShipmentOverviewShowCard'
import DocumentsForm from '../Documents/Form'
import { moment, documentTypes, docOptions } from '../../constants'
import {
  switchIcon,
  formattedPriceValue,
  totalPrice
} from '../../helpers'
import ContactDetailsRow from '../Admin/AdminShipmentView/ContactDetailsRow'
import GreyBox from '../GreyBox/GreyBox'
import FileUploader from '../FileUploader/FileUploader'
import ShipmentNotes from '../ShipmentNotes'

export class UserShipmentContent extends Component {
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
      upUrl: `/shipments/${this.props.match.params.id}/upload/packing_sheet`
    }

    this.setFileType = this.setFileType.bind(this)
  }

  setFileType (ev) {
    const shipmentId = this.props.shipmentData.shipment.id
    const url = `/shipments/${shipmentId}/upload/${ev.value}`
    this.setState({ fileType: ev, upUrl: url })
  }
  deleteDoc (doc) {
    const { userDispatch } = this.props
    userDispatch.deleteDocument(doc.id)
  }
  fileFn (file) {
    const { shipmentData, userDispatch } = this.props
    const { shipment } = shipmentData
    const type = file.doc_type
    const url = `/shipments/${shipment.id}/upload/${type}`
    userDispatch.uploadDocument(file, type, url)
  }

  render () {
    const {
      theme,
      user,
      gradientBorderStyle,
      gradientStyle,
      estimatedTimes,
      background,
      selectedStyle,
      deselectedStyle,
      scope,
      shipmentData,
      feeHash,
      userDispatch,
      cargoCount,
      cargoView
    } = this.props
    const { fileType, upUrl } = this.state
    const {
      contacts,
      shipment,
      documents
    } = shipmentData
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

    const docChecker = {
      packing_sheet: false,
      commercial_invoice: false
    }
    const docView = []
    const missingDocs = []

    if (documents) {
      documents.forEach((doc) => {
        docChecker[doc.doc_type] = true
        docView.push(<div className="flex-xs-100 flex-sm-45 flex-33 flex-gt-lg-25 layout-align-start-center layout-row" style={{ padding: '10px' }}>
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
        missingDocs.push(<div className={`flex-25 layout-row layout-align-start-center layout-padding ${adminStyles.no_doc}`}>
          <div className="flex-none layout-row layout-align-center-center">
            <i className="flex-none fa fa-ban" />
          </div>
          <div className="flex layout-align-start-center layout-row">
            <p className="flex-none">{`${documentTypes[key]}: Not Uploaded`}</p>
          </div>
        </div>)
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

    return (
      <Tabs
        wrapperTabs="layout-row flex-100 margin_bottom"
      >
        <Tab
          tabTitle="Overview"
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
                      text="ETD"
                      theme={theme}
                      carriage={pickupDate}
                      noCarriage={originDropOffDate}
                      shipment={shipment}
                      hub={shipment.origin_hub}
                      background={background.bg1}
                    />
                  </div>
                )}
              />
              <div className="layout-row flex-100 flex-gt-sm-20 layout-align-center-center padd_20">
                <div className={`layout-column flex layout-align-center-center ${styles.font_adjustaments}`}>
                  <div className="layout-align-center-center layout-row" style={gradientStyle}>
                    {switchIcon(shipment)}
                  </div>
                  <p className="">Estimated time delivery</p>
                  <h5>{moment(shipment.planned_eta).diff(moment(shipment.planned_etd), 'days')} days{' '}</h5>
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
                      shipment={shipment}
                      text="ETA"
                      theme={theme}
                      noCarriage={destinationCollectionDate}
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
          tabTitle="Freight"
          theme={theme}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-center-center  padding_top">
            <div className={`${adminStyles.border_box} margin_bottom layout-sm-column layout-xs-column layout-row flex-100`}>
              <div className={`flex-50 flex-sm-100 flex-xs-100 layout-row ${styles.services_box}`}>
                <div className="layout-column flex-100">
                  <h3>Freight, Duties & Carriage:</h3>
                  <div className="layout-wrap layout-row flex">
                    <div className="flex-45 margin_bottom">
                      <div className="layout-row flex-100">
                        <div className="flex-none layout-row">
                          <i className="fa fa-truck clip flex-none layout-align-center-center" style={shipment.has_pre_carriage ? selectedStyle : deselectedStyle} />
                          <p>Pickup</p>
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
                    <div className="flex-offset-10 flex-45 margin_bottom">
                      <div className="layout-row flex-100">
                        <div className="flex-none layout-row">
                          <i
                            className="fa fa-truck clip flex-none layout-align-center-center"
                            style={shipment.has_on_carriage ? selectedStyle : deselectedStyle}
                          />
                          <p>Delivery</p>
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
                    <div className="flex-45 margin_bottom">
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
                      className="flex-offset-10 flex-45 margin_bottom"
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
                    <div className="flex-45 margin_bottom">
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
              <div className={`flex-25 layout-row flex-sm-100 flex-xs-100 ${styles.additional_services} ${styles.services_box} ${styles.border_right}`}>
                <div className="flex-80">
                  <h3>Additional Services</h3>
                  <div className="">
                    <div className="flex-100 margin_bottom">
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
              </div>
              <div className={`flex-25 flex-sm-100 flex-xs-100 layout-row layout-align-center-center layout-padding ${styles.services_box}`}>
                <div className="layout-column flex-100">
                  <div className="layout-row layout-align-sm-end-center layout-align-xs-center-center flex-100">
                    <div className="layout-align-start-center layout-row flex">
                      <span style={gradientStyle} className={`layout-align-center-center layout-row flex-none ${styles.quantity_square}`}>x&nbsp;{cargoCount}</span>
                      <p className="layout-align-sm-end-center layout-align-xs-end-center">{UserShipmentContent.calcCargoLoad(feeHash, shipment.load_type)}</p>
                    </div>
                  </div>
                  <h2 className="layout-align-start-center layout-row flex">
                    {formattedPriceValue(totalPrice(shipment).value)} {totalPrice(shipment).currency}
                  </h2>
                </div>
              </div>
            </div>
          </div>

        </Tab>
        <Tab
          tabTitle="Contacts"
          theme={theme}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-center-center padding_top">
            <ContactDetailsRow
              contacts={contacts}
              style={selectedStyle}
              accountId={shipment.user_id}
              user={user}
            />
          </div>
        </Tab>
        <Tab
          tabTitle="Cargo Details"
          theme={theme}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-center-center  padding_top">
            <GreyBox
              title="Cargo Details"
              wrapperClassName={`layout-row flex-100 ${adminStyles.no_margin_box_right}`}
              contentClassName="layout-column flex"
              content={cargoView}
            />
            <ShipmentNotes shipment={shipment} />
          </div>
        </Tab>
        <Tab
          tabTitle="Documents"
          theme={theme}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-center-center  padding_top">

            <GreyBox
              wrapperClassName="layout-row flex-100 padd_20 margin_bottom"
              contentClassName={`layout-row layout-wrap flex ${styles.min_height}`}
              content={(
                <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${adminStyles.padding_left}`}>
                  <div className="flex-100 layout-row layout-wrap layout-align-start-center ">
                    <div className="flex-50 layout-align-start-center layout-wrap layout-row margin_bottom">
                      <p className={`${styles.sec_subheader_text} flex-100 padding_bottom_sm padding_top`}>
                    Upload New Document:
                      </p>
                      <div className="flex-100 layout-align-start-center layout-row">
                        <StyledSelect
                          name="file-type"
                          className={`${styles.select} flex-50`}
                          value={fileType}
                          options={docOptions}
                          onChange={this.setFileType}
                        />
                        <div className="flex-50 layout-align-center-center layout-row padd_10">
                          <FileUploader
                            theme={theme}
                            url={upUrl}
                            formClasses="flex-100 layout-row layout-align-center-center"
                            type={fileType.value}
                            text={fileType.label}
                            uploadFn={userDispatch.uploadDocument}
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

UserShipmentContent.propTypes = {
  theme: PropTypes.theme,
  user: PropTypes.user,
  userDispatch: PropTypes.shape({
    deleteDocument: PropTypes.func
  }).isRequired,
  gradientBorderStyle: PropTypes.style,
  gradientStyle: PropTypes.style,
  estimatedTimes: PropTypes.objectOf(PropTypes.node),
  background: PropTypes.objectOf(PropTypes.style),
  match: PropTypes.match.isRequired,
  selectedStyle: PropTypes.style,
  deselectedStyle: PropTypes.style,
  scope: PropTypes.objectOf(PropTypes.any),
  feeHash: PropTypes.objectOf(PropTypes.any),
  cargoCount: PropTypes.number,
  shipmentData: PropTypes.shipmentData.isRequired,
  cargoView: PropTypes.node
}

UserShipmentContent.defaultProps = {
  theme: null,
  user: null,
  gradientBorderStyle: {},
  gradientStyle: {},
  estimatedTimes: {},
  background: {},
  selectedStyle: {},
  deselectedStyle: {},
  scope: {},
  feeHash: {},
  cargoCount: 0,
  cargoView: null
}

export default UserShipmentContent
