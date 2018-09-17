import React, { Component } from 'react'
import PropTypes from '../../../prop-types'
import Tabs from '../../Tabs/Tabs'
import Tab from '../../Tabs/Tab'
import styles from '../AdminShipments.scss'
import adminStyles from '../Admin.scss'
import GradientBorder from '../../GradientBorder'
import { moment } from '../../../constants'
import { formattedPriceValue } from '../../../helpers'
import ShipmentOverviewShowCard from './ShipmentOverviewShowCard'
import ContactDetailsRow from './ContactDetailsRow'
import GreyBox from '../../GreyBox/GreyBox'

export class AdminShipmentContent extends Component {
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
      newPrices: {
        trucking_pre: AdminShipmentContent.checkSelectedOffer(this.props.shipment.selected_offer.trucking_pre),
        trucking_on: AdminShipmentContent.checkSelectedOffer(this.props.shipment.selected_offer.trucking_on),
        cargo: AdminShipmentContent.checkSelectedOffer(this.props.shipment.selected_offer.cargo),
        insurance: AdminShipmentContent.checkSelectedOffer(this.props.shipment.selected_offer.insurance),
        customs: AdminShipmentContent.checkSelectedOffer(this.props.shipment.selected_offer.customs)
      }
    }
  }

  handlePriceChange (key, value) {
    const { newPrices } = this.state
    this.setState({
      newPrices: {
        ...newPrices,
        [key]: {
          ...newPrices[key],
          value
        }
      }
    })
  }

  render () {
    const {
      theme,
      gradientBorderStyle,
      gradientStyle,
      etdJSX,
      etaJSX,
      shipment,
      bg1,
      bg2,
      switchIcon,
      dnrEditKeys,
      showEditTime,
      saveNewTime,
      toggleEditTime,
      showEditServicePrice,
      toggleEditServicePrice,
      newPrices,
      totalPrice,
      accountHolder,
      feeHash,
      selectedStyle,
      deselectedStyle,
      cargoCount,
      cargoView,
      calcCargoLoad,
      contacts,
      missingDocs,
      docView
    } = this.props

    return (
      <Tabs
        wrapperTabs="layout-row flex-100 margin_bottom"
      >
        <Tab
          tabTitle="Overview"
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
                      et={etdJSX}
                      text="ETD"
                      theme={theme}
                      hub={shipment.origin_hub}
                      shipment={shipment}
                      bg={bg1}
                      editTime={showEditTime}
                      handleSaveTime={saveNewTime}
                      toggleEditTime={toggleEditTime}
                      isAdmin={!dnrEditKeys.includes(shipment.status)}
                    />
                  </div>
                )}
              />
              <div className="layout-row flex-20 layout-align-center-center">
                <div className={`layout-column flex layout-align-center-center ${styles.font_adjustaments}`}>
                  <div className="layout-align-center-center layout-row" style={gradientStyle}>
                    {switchIcon()}
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
                      text="ETA"
                      theme={theme}
                      hub={shipment.destination_hub}
                      bg={bg2}
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
          tabTitle="Freight"
          theme={theme}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-center-center  padding_top">
            <div className={`${adminStyles.border_box} margin_bottom layout-sm-column layout-xs-column layout-row flex-100 `}>
              <div className={`flex-50 flex-sm-100 flex-xs-100 layout-row ${styles.services_box}`}>
                <div className="layout-column flex-100">
                  <h3>Freight, Duties & Carriage:</h3>
                  <div className="layout-wrap layout-row flex">
                    <div className="flex-45 margin_bottom">
                      <div className="layout-row flex-100">
                        <div className="flex-100 layout-wrap layout-row">
                          <div className="flex-100 layout-row">
                            <i className="fa fa-truck clip flex-none layout-align-center-center" style={shipment.has_pre_carriage ? selectedStyle : deselectedStyle} />
                            <p>Pick-up</p>
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
                                onChange={e => this.handlePriceChange('trucking_pre', e.target.value)}
                                value={Number(newPrices.trucking_pre.value).toFixed(2)}
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
                            <p>Delivery</p>
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
                                onChange={e => this.handlePriceChange('trucking_on', e.target.value)}
                                value={Number(newPrices.trucking_on.value).toFixed(2)}
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
                                  Origin<br />
                                  Documentation
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
                        Destination<br />
                        Documentation
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
                            <p>Freight</p>
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
                                onChange={e => this.handlePriceChange('cargo', e.target.value)}
                                value={Number(newPrices.cargo.value).toFixed(2)}
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
                  <h3>Additional Services</h3>
                  <div className="">
                    <div className="flex-100 margin_bottom">
                      <div className="layout-row flex-100">
                        <div className="layout-row flex-100 layout-wrap">
                          <div className="flex-100 layout-row">
                            <i className="fa fa-id-card clip flex-none" style={feeHash.customs ? selectedStyle : deselectedStyle} />
                            <p>Customs</p>
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
                            <p>Insurance</p>
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
                              <p>Requested  </p>
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
                                onChange={e => this.handlePriceChange('insurance', e.target.value)}
                                value={Number(newPrices.insurance.value).toFixed(2)}
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
                        <i onClick={this.saveNewEditedPrice} className="fa fa-check" />
                      </div>
                      <div className={`layout-row layout-align-center-center ${styles.cancel}`}>
                        <i onClick={toggleEditServicePrice} className="fa fa-trash" />
                      </div>
                    </div>
                  ) : (
                    <i onClick={this.toggleEditServicePrice} className={`fa fa-edit ${styles.editIcon}`} />
                  )}
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
          tabTitle="Cargo Details"
          theme={theme}
        >
          <div className="flex-100 layout-row layout-wrap layout-align-center-center  padding_top">
            <GreyBox

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
                          <span
                            className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row"
                          >
                          Incoterm:
                          </span>
                          <p
                            className="flex-60 flex-xs-100 layout-align-xs-start-center layout-row"
                          >
                            -
                          </p>
                        </div>
                      )}
                    </div>
                  </div>
                  <div className={`layout-column flex-100 flex-sm-100 flex-xs-100 ${styles.column_info}`}>
                    <div
                      className={`${styles.border_bottom}
                    flex-100 flex-sm-100 flex-xs-100 layout-row offset-5
                    layout-align-start-start layout-wrap`}
                    >
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

              wrapperClassName={`layout-row flex-100 ${adminStyles.no_margin_box_right} margin_bottom `}
              contentClassName="flex"
              content={(
                <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${adminStyles.padding_left}`}>
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
  etdJSX: PropTypes.node,
  etaJSX: PropTypes.node,
  shipment: PropTypes.shipment,
  bg1: PropTypes.style,
  bg2: PropTypes.style,
  selectedStyle: PropTypes.style,
  deselectedStyle: PropTypes.style,
  contacts: PropTypes.arrayOf(PropTypes.contact),
  feeHash: PropTypes.objectOf(PropTypes.any),
  docView: PropTypes.arrayOf(PropTypes.node),
  cargoCount: PropTypes.number,
  missingDocs: PropTypes.arrayOf(PropTypes.node),
  cargoView: PropTypes.node,
  calcCargoLoad: PropTypes.number,
  switchIcon: PropTypes.func,
  dnrEditKeys: PropTypes.arrayOf(PropTypes.string),
  showEditTime: PropTypes.bool,
  saveNewTime: PropTypes.func,
  toggleEditTime: PropTypes.func,
  showEditServicePrice: PropTypes.bool,
  newPrices: PropTypes.objectOf(PropTypes.any),
  totalPrice: PropTypes.func,
  toggleEditServicePrice: PropTypes.func,
  handlePriceChangePre: PropTypes.func,
  handlePriceChangeOn: PropTypes.func,
  accountHolder: PropTypes.user
}

AdminShipmentContent.defaultProps = {
  theme: null,
  gradientBorderStyle: {},
  gradientStyle: {},
  etdJSX: null,
  etaJSX: null,
  toggleEditServicePrice: null,
  handlePriceChangeOn: null,
  handlePriceChangePre: null,
  shipment: {},
  bg1: {},
  bg2: {},
  selectedStyle: {},
  deselectedStyle: {},
  contacts: [],
  feeHash: {},
  docView: [],
  cargoCount: 0,
  missingDocs: [],
  cargoView: null,
  calcCargoLoad: 0,
  switchIcon: null,
  dnrEditKeys: [],
  showEditTime: false,
  saveNewTime: null,
  toggleEditTime: null,
  showEditServicePrice: false,
  newPrices: {},
  totalPrice: null,
  accountHolder: {}
}

export default AdminShipmentContent
