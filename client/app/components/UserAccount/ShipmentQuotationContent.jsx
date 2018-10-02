import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import Tabs from '../Tabs/Tabs'
import Tab from '../Tabs/Tab'
import styles from '../Admin/AdminShipments.scss'
import adminStyles from '../Admin/Admin.scss'
import quoteStyles from '../Quote/Card/index.scss'
import GradientBorder from '../GradientBorder'
import ShipmentOverviewShowCard from '../Admin/AdminShipmentView/ShipmentOverviewShowCard'
import { moment } from '../../constants'
import {
  switchIcon,
  numberSpacing,
  checkPreCarriage,
  capitalize
} from '../../helpers'
import GreyBox from '../GreyBox/GreyBox'
import CollapsingBar from '../CollapsingBar/CollapsingBar'

export class ShipmentQuotationContent extends Component {
  static determineSubKey (key) {
    switch (key) {
      case 'trucking_lcl' || 'trucking_fcl':
        return 'Trucking Rate'

      default:
        return key
    }
  }
  constructor (props) {
    super(props)
    this.state = {
      expander: {}
    }
  }
  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }
  render () {
    const {
      theme,
      gradientBorderStyle,
      gradientStyle,
      et,
      shipment,
      bg,
      selectedStyle,
      deselectedStyle,
      scope,
      feeHash,
      cargoView
    } = this.props

    const pricesArr = Object.keys(shipment.selected_offer).splice(2).length !== 0 ? (
      Object.keys(shipment.selected_offer).splice(2).map(key => (<CollapsingBar
        showArrow
        collapsed={!this.state.expander[`${key}`]}
        theme={theme}
        contentStyle={quoteStyles.sub_price_row_wrapper}
        headerWrapClasses="flex-100 layout-row layout-wrap layout-align-start-center"
        handleCollapser={() => this.toggleExpander(`${key}`)}
        mainWrapperStyle={{ borderTop: '1px solid #E0E0E0', minHeight: '50px' }}
        contentHeader={(
          <div className={`flex-100 layout-row layout-align-start-center ${quoteStyles.price_row}`}>
            <div className="flex-none layout-row layout-align-start-center" />
            <div className="flex-45 layout-row layout-align-start-center">
              {key === 'trucking_pre' ? (
                <span>Pick-up</span>
              ) : ''}
              {key === 'trucking_on' ? (
                <span>Delivery</span>
              ) : ''}
              <span>{key === 'trucking_pre' || key === 'trucking_on' ? '' : capitalize(key)}</span>
            </div>
            <div className="flex-50 layout-row layout-align-end-center">
              <p>{numberSpacing(shipment.selected_offer[`${key}`].total.value, 2)}&nbsp;{shipment.selected_offer.total.currency}</p>
            </div>
          </div>
        )}
        content={Object.entries(shipment.selected_offer[`${key}`])
          .map(array => array.filter(value =>
            value !== 'total' && value !== 'edited_total'))
          .filter(value => value.length !== 1).map((price) => {
            const subPrices = (<div className={`flex-100 layout-row layout-align-start-center ${quoteStyles.sub_price_row}`}>
              <div className="flex-45 layout-row layout-align-start-center">
                <span>{key === 'cargo' ? 'Freight rate' : ShipmentQuotationContent.determineSubKey(price[0])}</span>
              </div>
              <div className="flex-50 layout-row layout-align-end-center">
                <p>{numberSpacing(price[1].value || price[1].total.value, 2)}&nbsp;{shipment.selected_offer.total.currency}</p>
              </div>
            </div>)

            return subPrices
          })}
      />))
    ) : ''

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
                      et={shipment.pickup_address ? et.etdJSX : null}
                      text="ETD"
                      shipment={shipment}
                      theme={theme}
                      hub={shipment.origin_hub}
                      bg={bg.bg1}
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
                      <p>Estimated time delivery</p>
                      <h5>{moment(shipment.planned_eta).diff(moment(shipment.planned_etd), 'days')} days{' '}</h5>
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
                      text="ETA"
                      shipment={shipment}
                      theme={theme}
                      et={shipment.delivery_address ? et.etaJSX : null}
                      hub={shipment.destination_hub}
                      bg={bg.bg2}
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
          <div className="flex-100 layout-row layout-align-start-start padding_top card_margin_right">
            <div className={`${adminStyles.border_box} margin_bottom layout-sm-column layout-xs-column layout-row flex-60`}>
              <div className={`flex-70 flex-sm-100 flex-xs-100 layout-row ${styles.services_box}`}>
                <div className="layout-column flex-100">
                  <h3>Freight, Duties & Carriage:</h3>
                  <div className="layout-wrap layout-row flex">
                    <div className="flex-45 margin_bottom">
                      <div className="layout-row flex-100">
                        <div className="flex-none layout-row">
                          <i className="fa fa-truck clip flex-none layout-align-center-center" style={shipment.trucking.has_pre_carriage ? selectedStyle : deselectedStyle} />
                          <p>Pickup</p>
                        </div>
                      </div>
                    </div>
                    <div className="flex-offset-10 flex-45 margin_bottom">
                      <div className="layout-row flex-100">
                        <div className="flex-none layout-row">
                          <i
                            className="fa fa-truck clip flex-none layout-align-center-center"
                            style={shipment.trucking.has_on_carriage ? selectedStyle : deselectedStyle}
                          />
                          <p>Delivery</p>
                        </div>
                      </div>
                    </div>
                    <div className="flex-45 margin_bottom">
                      <div className="layout-row flex-100">
                        <div className="layout-row flex-none">
                          <i
                            className="fa fa-file-text clip flex-none layout-align-center-center"
                            style={shipment.trucking.has_pre_carriage ? selectedStyle : deselectedStyle}
                          />
                          <p>
                      Origin<br />
                      Documentation
                          </p>
                        </div>
                      </div>
                    </div>
                    <div
                      className="flex-offset-10 flex-45 margin_bottom"
                    >
                      <div className="layout-row flex-100">
                        <div className="layout-row flex-none">
                          <i
                            className="fa fa-file-text-o clip flex-none layout-align-center-center"
                            style={shipment.trucking.has_on_carriage ? selectedStyle : deselectedStyle}
                          />
                          <p>
                      Destination<br />
                      Documentation
                          </p>
                        </div>
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
                      </div>

                    </div>
                  </div>
                </div>
              </div>
              <div className={`flex-30 layout-row flex-sm-100 flex-xs-100 ${styles.additional_services} ${styles.services_box}`}>
                <div className="flex-80">
                  <h3>Additional Services</h3>
                  <div className="">
                    <div className="flex-100 margin_bottom">
                      <div className="layout-row flex-100">
                        <div className="layout-row flex-none">
                          <i className="fa fa-id-card clip flex-none" style={feeHash.customs ? selectedStyle : deselectedStyle} />
                          <p>Customs</p>
                        </div>
                      </div>
                    </div>
                    <div className="layout-column flex-100 margin_bottom">
                      <div className="layout-row flex-100">
                        <div className="layout-row flex-none">
                          <i className="fa fa-umbrella clip flex-none" style={feeHash.customs ? selectedStyle : deselectedStyle} />
                          <p>Insurance</p>
                        </div>
                        {scope.detailed_billing && feeHash.insurance && !feeHash.insurance.value && !feeHash.insurance.edited_total
                          ? <div className="flex layout-row layout-align-end-center">
                            <p>Requested  </p>
                          </div> : ''}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div className="flex-40 layout-row">
              <div
                className={`flex-100 layout-row layout-wrap ${quoteStyles.wrapper}`}
              >
                {pricesArr}
                <div className="flex-100 layout-wrap layout-align-start-stretch">
                  <div className={`flex-100 layout-row layout-align-start-stretch ${quoteStyles.total_row}`}>
                    <div className="flex-50 layout-row layout-align-start-center">
                      <span>Total</span>
                    </div>
                    <div className="flex-50 layout-row layout-align-end-center">
                      <p>{numberSpacing(shipment.selected_offer.total.value, 2)}&nbsp;{shipment.selected_offer.total.currency}</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
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
                        <div className="flex-100 layout-xs-column layout-row layout-align-start-center">
                          <span className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row">Total Value <br /> of Goods:</span>
                          <p className={`flex-60 flex-xs-100 layout-align-xs-start-center layout-row ${styles.info_values}`}>
                            {shipment.total_goods_value.value}&nbsp;
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
                        <div className="flex-100 layout-xs-column layout-row layout-align-start-start">
                          <span className="flex-40 flex-xs-100 layout-align-center-center layout-row">Incoterm:</span>
                          <p className="flex-60 flex-xs-100 layout-align-xs-start-center layout-row">
                            {shipment.incoterm_text}
                          </p>
                        </div>
                      ) : (
                        <div className="flex-100 layout-xs-column layout-row layout-align-start-start">
                          <span className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row">Incoterm:</span>
                          <p className="flex-60 flex-xs-100 layout-align-xs-start-center layout-row">
                        -
                          </p>
                        </div>
                      )}
                    </div>
                  </div>
                  <div className={`layout-column flex-100 flex-sm-100 flex-xs-100 ${styles.column_info}`}>
                    <div className={`${styles.border_bottom} padding_top_sm padding_bottom_sm flex-100 flex-sm-100 flex-xs-100 layout-row offset-5 layout-align-start-start layout-wrap`}>
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
                    <div className="flex-100 flex-sm-100 padding_top_sm padding_bottom_sm flex-xs-100 layout-row offset-5 layout-align-start-start layout-wrap">
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
      </Tabs>
    )
  }
}

ShipmentQuotationContent.propTypes = {
  theme: PropTypes.theme,
  gradientBorderStyle: PropTypes.style,
  gradientStyle: PropTypes.style,
  et: PropTypes.objectOf(PropTypes.node),
  shipment: PropTypes.shipment,
  bg: PropTypes.objectOf(PropTypes.style),
  selectedStyle: PropTypes.style,
  deselectedStyle: PropTypes.style,
  scope: PropTypes.objectOf(PropTypes.any),
  feeHash: PropTypes.objectOf(PropTypes.any),
  cargoView: PropTypes.node
}

ShipmentQuotationContent.defaultProps = {
  theme: null,
  gradientBorderStyle: {},
  gradientStyle: {},
  et: {},
  shipment: {},
  bg: {},
  selectedStyle: {},
  deselectedStyle: {},
  scope: {},
  feeHash: {},
  cargoView: null
}

export default ShipmentQuotationContent
