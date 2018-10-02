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
  capitalize
} from '../../helpers'
import GreyBox from '../GreyBox/GreyBox'
import CollapsingBar from '../CollapsingBar/CollapsingBar'
import ShipmentNotes from '../ShipmentNotes'

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
      estimatedTimes,
      shipment,
      background,
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
                      et={shipment.pickup_address ? estimatedTimes.etdJSX : null}
                      text="ETD"
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
            <ShipmentNotes shipment={shipment} />
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
  estimatedTimes: PropTypes.objectOf(PropTypes.node),
  shipment: PropTypes.shipment,
  background: PropTypes.objectOf(PropTypes.style),
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
  estimatedTimes: {},
  shipment: {},
  background: {},
  selectedStyle: {},
  deselectedStyle: {},
  scope: {},
  feeHash: {},
  cargoView: null
}

export default ShipmentQuotationContent
