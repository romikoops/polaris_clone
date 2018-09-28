import React from 'react'
import Select from 'react-select'
import styled from 'styled-components'
import PropTypes from '../../prop-types'
import Tabs from '../Tabs/Tabs'
import Tab from '../Tabs/Tab'
import styles from '../Admin/AdminShipments.scss'
import adminStyles from '../Admin/Admin.scss'
import GradientBorder from '../GradientBorder'
import ShipmentOverviewShowCard from '../Admin/AdminShipmentView/ShipmentOverviewShowCard'
import { moment } from '../../constants'
import {
  switchIcon,
  formattedPriceValue,
  totalPrice
} from '../../helpers'
import ContactDetailsRow from '../Admin/AdminShipmentView/ContactDetailsRow'
import GreyBox from '../GreyBox/GreyBox'
import FileUploader from '../FileUploader/FileUploader'

export function UserShipmentContent ({
  theme,
  user,
  gradientBorderStyle,
  gradientStyle,
  etdJSX,
  etaJSX,
  shipment,
  bg1,
  bg2,
  pickupDate,
  deliveryDate,
  originDropOffDate,
  destinationCollectionDate,
  selectedStyle,
  deselectedStyle,
  scope,
  contacts,
  feeHash,
  docOptions,
  userDispatch,
  docView,
  cargoCount,
  missingDocs,
  cargoView,
  upUrl,
  fileType,
  setFileType,
  calcCargoLoad
}) {
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
                    estimatedTime={etdJSX}
                    text="ETD"
                    theme={theme}
                    carriage={pickupDate}
                    noCarriage={originDropOffDate}
                    shipment={shipment}
                    hub={shipment.origin_hub}
                    bg={bg1}
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
                    estimatedTime={etaJSX}
                    carriage={deliveryDate}
                    shipment={shipment}
                    text="ETA"
                    theme={theme}
                    noCarriage={destinationCollectionDate}
                    hub={shipment.destination_hub}
                    bg={bg2}
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
                    <p className="layout-align-sm-end-center layout-align-xs-end-center">{calcCargoLoad}</p>
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

          <GreyBox
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
                        <span className="flex-30 layout-row">Description of Goods:</span>
                        <p className="flex-80 layout-padding layout-row">
                          {shipment.cargo_notes}
                        </p>
                      </div>
                    ) : (
                      <div className="flex-100 layout-row layout-align-start-center">
                        <span className="flex-30 layout-row">Description of Goods:</span>
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
        </div>
      </Tab>
      <Tab
        tabTitle="Documents"
        theme={theme}
      >
        <div className="flex-100 layout-row layout-wrap layout-align-center-center  padding_top">

          <GreyBox
            title="Documents"
            wrapperClassName={`layout-row flex-100 ${adminStyles.no_margin_box_right} margin_bottom`}
            contentClassName={`layout-row layout-wrap flex ${styles.min_height}`}
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
                      value={fileType}
                      options={docOptions}
                      onChange={setFileType}
                    />
                  </div>
                  <div className="flex-50 layout-align-end-center layout-row">
                    <FileUploader
                      theme={theme}
                      url={upUrl}
                      type={fileType.value}
                      text={fileType.label}
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
      </Tab>
    </Tabs>
  )
}

UserShipmentContent.propTypes = {
  theme: PropTypes.theme,
  user: PropTypes.user,
  userDispatch: PropTypes.shape({
    deleteDocument: PropTypes.func
  }).isRequired,
  gradientBorderStyle: PropTypes.style,
  gradientStyle: PropTypes.style,
  etdJSX: PropTypes.node,
  etaJSX: PropTypes.node,
  pickupDate: PropTypes.node,
  deliveryDate: PropTypes.node,
  originDropOffDate: PropTypes.node,
  destinationCollectionDate: PropTypes.node,
  shipment: PropTypes.shipment,
  bg1: PropTypes.style,
  bg2: PropTypes.style,
  selectedStyle: PropTypes.style,
  deselectedStyle: PropTypes.style,
  scope: PropTypes.objectOf(PropTypes.any),
  contacts: PropTypes.arrayOf(PropTypes.contact),
  feeHash: PropTypes.objectOf(PropTypes.any),
  docOptions: PropTypes.arrayOf(PropTypes.object),
  docView: PropTypes.arrayOf(PropTypes.node),
  cargoCount: PropTypes.number,
  missingDocs: PropTypes.arrayOf(PropTypes.node),
  cargoView: PropTypes.node,
  upUrl: PropTypes.string,
  fileType: PropTypes.objectOf(PropTypes.string),
  setFileType: PropTypes.func,
  calcCargoLoad: PropTypes.number
}

UserShipmentContent.defaultProps = {
  theme: null,
  user: null,
  gradientBorderStyle: {},
  gradientStyle: {},
  etdJSX: null,
  etaJSX: null,
  pickupDate: null,
  deliveryDate: null,
  originDropOffDate: null,
  destinationCollectionDate: null,
  shipment: {},
  bg1: {},
  bg2: {},
  selectedStyle: {},
  deselectedStyle: {},
  scope: {},
  contacts: [],
  feeHash: {},
  docOptions: [],
  docView: [],
  cargoCount: 0,
  missingDocs: [],
  cargoView: null,
  upUrl: '',
  fileType: {},
  setFileType: null,
  calcCargoLoad: 0
}

export default UserShipmentContent
