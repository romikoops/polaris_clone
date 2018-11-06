import React from 'react'
import { withNamespaces } from 'react-i18next'
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
  numberSpacing
} from '../../helpers'
import GreyBox from '../GreyBox/GreyBox'
import ShipmentNotes from '../ShipmentNotes'
import QuoteChargeBreakdown from '../QuoteChargeBreakdown/QuoteChargeBreakdown'

function ShipmentQuotationContent ({
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
  t,
  cargoView
}) {
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
                    <h5>{moment(shipment.planned_eta).diff(moment(shipment.planned_etd), `${t('common:days')}`)} {t('common:days')}</h5>
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
          <div className={`${adminStyles.border_box} margin_bottom layout-sm-column layout-xs-column layout-row flex-60`}>
            <div className={`flex-70 flex-sm-100 flex-xs-100 layout-row ${styles.services_box}`}>
              <div className="layout-column flex-100">
                <h3>{t('shipment:freightDutiesAndCarriage')}</h3>
                <div className="layout-wrap layout-row flex">
                  <div className="flex-45 margin_bottom">
                    <div className="layout-row flex-100">
                      <div className="flex-none layout-row">
                        <i className="fa fa-truck clip flex-none layout-align-center-center" style={feeHash.trucking_pre ? selectedStyle : deselectedStyle} />
                        <p>{t('shipment:pickUp')}</p>
                      </div>
                    </div>
                  </div>
                  <div className="flex-offset-10 flex-45 margin_bottom">
                    <div className="layout-row flex-100">
                      <div className="flex-none layout-row">
                        <i
                          className="fa fa-truck clip flex-none layout-align-center-center"
                          style={feeHash.trucking_on ? selectedStyle : deselectedStyle}
                        />
                        <p>{t('shipment:delivery')}</p>
                      </div>
                    </div>
                  </div>
                  <div className="flex-45 margin_bottom">
                    <div className="layout-row flex-100">
                      <div className="layout-row flex-none">
                        <i
                          className="fa fa-file-text clip flex-none layout-align-center-center"
                          style={feeHash.export ? selectedStyle : deselectedStyle}
                        />
                        <p>
                          {t('shipment:originDocumentation')}
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
                          style={feeHash.import ? selectedStyle : deselectedStyle}
                        />
                        <p>
                          {t('shipment:destinationDocumentation')}
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
                        <p>{t('shipment:freight')}</p>
                      </div>
                    </div>

                  </div>
                </div>
              </div>
            </div>
            <div className={`flex-30 layout-row flex-sm-100 flex-xs-100 ${styles.additional_services} ${styles.services_box}`}>
              <div className="flex-80">
                <h3>{t('shipment:additionalServices')}</h3>
                <div className="">
                  <div className="flex-100 margin_bottom">
                    <div className="layout-row flex-100">
                      <div className="layout-row flex-none">
                        <i className="fa fa-id-card clip flex-none" style={feeHash.customs ? selectedStyle : deselectedStyle} />
                        <p>{t('shipment:customs')}</p>
                      </div>
                    </div>
                  </div>
                  <div className="layout-column flex-100 margin_bottom">
                    <div className="layout-row flex-100">
                      <div className="layout-row flex-none">
                        <i className="fa fa-umbrella clip flex-none" style={feeHash.insurance ? selectedStyle : deselectedStyle} />
                        <p>{t('shipment:insurance')}</p>
                      </div>
                      {scope.detailed_billing && feeHash.insurance && !feeHash.insurance.value && !feeHash.insurance.edited_total
                        ? <div className="flex layout-row layout-align-end-center">
                          <p>{t('shipment:requested')}</p>
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
              <QuoteChargeBreakdown
                theme={theme}
                scope={scope}
                quote={shipment.selected_offer}
              />
              <div className="flex-100 layout-wrap layout-align-start-stretch">
                <div className={`flex-100 layout-row layout-align-start-stretch ${quoteStyles.total_row}`}>
                  <div className="flex-30 layout-row layout-align-start-center">
                    <span>{t('common:total')}</span>
                  </div>
                  <div className="flex-70 layout-row layout-align-end-center">
                    <p className="card_padding_right">{numberSpacing(shipment.selected_offer.total.value, 2)}&nbsp;{shipment.selected_offer.total.currency}</p>
                  </div>
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

ShipmentQuotationContent.propTypes = {
  theme: PropTypes.theme,
  gradientBorderStyle: PropTypes.style,
  t: PropTypes.func.isRequired,
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

export default withNamespaces(['common', 'shipment', 'cargo'])(ShipmentQuotationContent)
