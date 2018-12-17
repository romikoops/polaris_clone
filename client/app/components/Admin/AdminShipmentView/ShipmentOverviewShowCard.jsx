import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from '../AdminShipments.scss'
import PropTypes from '../../../prop-types'
import { gradientTextGenerator } from '../../../helpers'

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
  text
}) {
  const selectedStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: '#E0E0E0' }
  const deselectedStyle = {
    ...gradientTextGenerator('#DCDBDC', '#DCDBDC')
  }

  return (
    <div className="flex-100 layout-row">
      <div className={`${styles.info_hub_box} flex-60 layout-column`}>
        <h3>{hub.name}</h3>
        {estimatedTime ? <div className="layout-row layout-align-start-center">
          <div className="flex-60 layout-align-center-start">
            <span>
              {text}
            </span>
            <div className="layout-row layout-align-start-center">
              {estimatedTime}
            </div>
          </div>
          {isAdmin
            ? (<div className="layout-row flex-40 layout-align-center-stretch">
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
            </div>) : '' }
        </div> : '' }

        {text === 'ETD'
          ? (
            <div className="flex-100 layout-row layout-align-start-center ">
              <div className="layout-row flex-100 layout-align-start-center">
                <div className={`flex layout-row layout-wrap layout-align-start-start ${styles.carriage_row}`}>
                  <div className="flex-100 layout-row">
                    <div className="flex-40 layout-row">
                      <i className={`flex-20 fa fa-check-square clip ${styles.check_square_sm}`} style={shipment.has_pre_carriage ? selectedStyle : deselectedStyle} />
                      <h4 className="flex-70 layout-row">
                        {t('shipment:pickUp')}
                      </h4>
                    </div>
                    <div className="flex-60 layout-row">
                      <i className={`flex-15 fa fa-check-square clip ${styles.check_square_sm}`} style={!shipment.has_pre_carriage ? selectedStyle : deselectedStyle} />
                      <h4 className="flex-85 layout-row">
                        {t('admin:dropOff')}
                      </h4>
                    </div>
                  </div>
                  {shipment.has_pre_carriage ? (<div className="layout-row layout-align-start-center">
                    <div className="flex-100 layout-align-center-start">
                      <div className="layout-row layout-align-start-center">
                        {carriage}
                      </div>
                    </div>
                  </div>) : (<div className="flex-100 layout-align-center-start">
                    <div className="layout-row layout-align-start-center">
                      {noCarriage}
                    </div>
                  </div>) }
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
                  <div className="flex-100 layout-row">
                    <div className="flex-40 layout-row">
                      <i className={`flex-20 fa fa-check-square clip ${styles.check_square_sm}`} style={shipment.has_on_carriage ? selectedStyle : deselectedStyle} />
                      <h4 className="flex-80 layout-row">
                        {t('shipment:delivery')}
                      </h4>
                    </div>
                    <div className="flex-60 layout-row">
                      <i className={`flex-15 fa fa-check-square clip ${styles.check_square_sm}`} style={!shipment.has_on_carriage ? selectedStyle : deselectedStyle} />
                      <h4 className="flex-85 layout-row">
                        {t('admin:collection')}
                      </h4>
                    </div>
                  </div>
                  {shipment.has_on_carriage ? (<div className="layout-row layout-align-start-center">
                    <div className="flex-100 layout-align-center-start">
                      <div className="layout-row layout-align-start-center">
                        {carriage}
                      </div>
                    </div>
                  </div>) : (<div className="flex-100 layout-align-center-start">
                    <div className="layout-row layout-align-start-center">
                      {noCarriage}
                    </div>
                  </div>) }
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
