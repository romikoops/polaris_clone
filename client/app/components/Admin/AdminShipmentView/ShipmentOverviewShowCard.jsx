import React from 'react'
import { withNamespaces } from 'react-i18next'
import { get } from 'lodash'
import styles from '../AdminShipments.scss'
import PropTypes from '../../../prop-types'

function ShipmentOverviewShowCard ({
  t,
  estimatedTime,
  carriage,
  noCarriage,
  hub,
  background,
  editTime,
  handleSaveTime,
  toggleEditTime,
  isAdmin,
  shipment,
  theme,
  text,
  showtruckingAvailability
}) {
  const selectedStyle = { color: get(theme, ['colors', 'primary'], '#058E05') }
  const deselectedStyle = { color: '#DCDBDC' }
  const hasFTL = hub.available_trucking ? hub.available_trucking.includes('container') : false
  const hasLTL = hub.available_trucking ? hub.available_trucking.includes('cargo_item') : false

  return (
    <div className="flex-100 layout-row">
      <div className={`${styles.info_hub_box} flex-60 layout-column`}>
        <h3>{hub.name}</h3>
        {estimatedTime ? (
          <div className="layout-row layout-align-start-center">
            <div className="flex-60 layout-align-center-start">
              <span>
                {text}
              </span>
              <div className="layout-row layout-align-start-center">
                {estimatedTime}
              </div>
            </div>
            {isAdmin
              ? (
                <div className="layout-row flex-40 layout-align-center-stretch">
                  {editTime ? (
                    <span className="flex-100 layout-align-center-stretch">
                      <div
                        onClick={handleSaveTime}
                        className={`layout-row flex-50 ${styles.save} layout-align-center-center`}
                      >
                        <i className="fa fa-check" />
                      </div>
                      <div
                        onClick={toggleEditTime}
                        className={`layout-row flex-50 ${styles.cancel} layout-align-center-center`}
                      >
                        <i className="fa fa-times" />
                      </div>
                    </span>
                  ) : (
                    <i onClick={toggleEditTime} className={`fa fa-edit ${styles.editIcon}`} />
                  )}
                </div>
              ) : '' }
          </div>
        ) : '' }

        {text === 'ETD'
          ? (
            <div className="flex-100 layout-row layout-align-start-center ">
              <div className="layout-row flex-100 layout-align-start-center">
                <div className={`flex layout-row layout-wrap layout-align-start-start ${styles.carriage_row}`}>
                  {showtruckingAvailability ? (
                    <div className="flex-100 layout-row layout-wrap">
                      <div className="flex-100 layout-row">
                        <p>{t('shipment:truckingAvailable')}</p>
                      </div>
                      <div className="flex-40 layout-row">
                        <i className={`flex-20 fa fa-check-square ${styles.check_square_sm}`} style={hasFTL ? selectedStyle : deselectedStyle} />
                        <h4 className="flex-70 layout-row">
                          {t('shipment:ftl')}
                        </h4>
                      </div>
                      <div className="flex-60 layout-row">
                        <i className={`flex-15 fa fa-check-square ${styles.check_square_sm}`} style={hasLTL ? selectedStyle : deselectedStyle} />
                        <h4 className="flex-85 layout-row">
                          {t('shipment:pickUp')}
                        </h4>
                      </div>
                    </div>) : (
                    <div className="flex-100 layout-row">
                      <div className="flex-40 layout-row">
                        <i className={`flex-20 fa fa-check-square ${styles.check_square_sm}`} style={shipment.has_pre_carriage ? selectedStyle : deselectedStyle} />
                        <h4 className="flex-70 layout-row">
                          {t('shipment:pickUp')}
                        </h4>
                      </div>
                      <div className="flex-60 layout-row">
                        <i className={`flex-15 fa fa-check-square ${styles.check_square_sm}`} style={!shipment.has_pre_carriage ? selectedStyle : deselectedStyle} />
                        <h4 className="flex-85 layout-row">
                          {t('admin:dropOff')}
                        </h4>
                      </div>
                    </div>)}
                  <div className="layout-row flex-95 layout-align-start-center">
                    <div className="flex-60 layout-row">
                      <p>{ shipment.has_pre_carriage ? carriage : noCarriage }</p>
                    </div>
                  </div>
                  {shipment.pickup_address ? (
                    <div className={`layout-row flex-95 layout-align-start-center ${styles.carriage_address}`}>
                      <p>{shipment.pickup_address.geocoded_address}</p>
                    </div>
                  ) : ''}
                </div>
              </div>

            </div>
          ) : (
            <div className="flex-100 layout-row layout-align-center-stretch">
              <div className="layout-row flex-100 layout-align-start-center">
                <div className={`flex layout-row layout-wrap layout-align-start-start ${styles.carriage_row}`}>
                  {showtruckingAvailability ? (
                    <div className="flex-100 layout-row layout-wrap">
                      <div className="flex-100 layout-row">
                        <p>{t('shipment:truckingAvailable')}</p>
                      </div>
                      <div className="flex-40 layout-row">
                        <i className={`flex-20 fa fa-check-square ${styles.check_square_sm}`} style={hasFTL ? selectedStyle : deselectedStyle} />
                        <h4 className="flex-70 layout-row">
                          {t('shipment:ftl')}
                        </h4>
                      </div>
                      <div className="flex-60 layout-row">
                        <i className={`flex-15 fa fa-check-square ${styles.check_square_sm}`} style={hasLTL ? selectedStyle : deselectedStyle} />
                        <h4 className="flex-85 layout-row">
                          {t('shipment:ltl')}
                        </h4>
                      </div>
                    </div>
                  ) : (
                    <div className="flex-100 layout-row">
                      <div className="flex-40 layout-row">
                        <i className={`flex-20 fa fa-check-square ${styles.check_square_sm}`} style={shipment.has_on_carriage ? selectedStyle : deselectedStyle} />
                        <h4 className="flex-80 layout-row">
                          {t('shipment:delivery')}
                        </h4>
                      </div>
                      <div className="flex-60 layout-row">
                        <i className={`flex-15 fa fa-check-square ${styles.check_square_sm}`} style={!shipment.has_on_carriage ? selectedStyle : deselectedStyle} />
                        <h4 className="flex-85 layout-row">
                          {t('admin:collection')}
                        </h4>
                      </div>
                    </div>)}

                  {shipment.delivery_address ? (
                    <div className={`layout-row flex-95 layout-align-start-center ${styles.carriage_address}`}>
                      <p>{shipment.delivery_address.geocoded_address}</p>
                    </div>
                  ) : ''}
                </div>
              </div>

            </div>
          )}

      </div>
      <div className={`layout-column flex-40 ${styles.image}`} style={background} />
    </div>
  )
}

ShipmentOverviewShowCard.propTypes = {
  t: PropTypes.func.isRequired,
  estimatedTime: PropTypes.node.isRequired,
  carriage: PropTypes.node.isRequired,
  noCarriage: PropTypes.node.isRequired,
  hub: PropTypes.hub.isRequired,
  background: PropTypes.objectOf(PropTypes.string),
  shipment: PropTypes.objectOf(PropTypes.any),
  editTime: PropTypes.bool,
  theme: PropTypes.theme,
  text: PropTypes.string,
  handleSaveTime: PropTypes.func.isRequired,
  toggleEditTime: PropTypes.func.isRequired,
  isAdmin: PropTypes.bool
}

ShipmentOverviewShowCard.defaultProps = {
  background: {},
  shipment: {},
  text: '',
  editTime: false,
  theme: null,
  isAdmin: false
}

export default withNamespaces(['admin', 'shipment'])(ShipmentOverviewShowCard)
