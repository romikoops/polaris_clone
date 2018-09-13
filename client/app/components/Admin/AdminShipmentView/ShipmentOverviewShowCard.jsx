import React from 'react'
import styles from '../AdminShipments.scss'
import PropTypes from '../../../prop-types'
import { moment } from '../../../constants'
import { checkPreCarriage, gradientTextGenerator } from '../../../helpers'

export default function ShipmentOverviewShowCard ({
  et,
  hub,
  bg,
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
        {et ? <div className="layout-row layout-align-start-center">
          <div className="flex-60 layout-align-center-start">
            <span>
              {text}
            </span>
            <div className="layout-row layout-align-start-center">
              {et}
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

        {text === 'ETD' ? (
          <div className="flex-100 layout-row layout-align-center-stretch">
            <div className="layout-row flex-100 layout-align-start-center">
              <div className="flex-100 layout-row layout-align-start-center">
                <i
                  className={`flex-none fa fa-check-square clip ${styles.check_square}`}
                  style={shipment.pickup_address ? selectedStyle : deselectedStyle}
                />
                <div className={`flex layout-row layout-wrap layout-align-start-start ${styles.carriage_row}`}>
                  <h4 className="flex-95 no_m layout-row">{checkPreCarriage(shipment, 'Pick-up').type}&nbsp;
                    {shipment.pickup_address
                      ? `on ${moment(checkPreCarriage(shipment, 'Pick-up').date)
                        .format('DD/MM/YYYY')}`
                      : ''}
                  </h4>
                  {shipment.pickup_address ? (
                    <div className={`layout-row flex-95 layout-align-start-center ${styles.carriage_address}`}>
                      <p>{shipment.pickup_address.street} &nbsp;
                        {shipment.pickup_address.street_number},&nbsp;
                        <strong>{shipment.pickup_address.city},&nbsp;
                          {shipment.pickup_address.country.name} </strong>
                      </p>
                    </div>
                  ) : ''}
                </div>
              </div>
            </div>
          </div>
        ) : (
          <div className="flex-100 layout-row layout-align-center-stretch">
            <div className="layout-row flex-100 layout-align-start-center">
              <i className={`flex-none fa fa-check-square clip ${styles.check_square}`} style={shipment.delivery_address ? selectedStyle : deselectedStyle} />
              <div className={`flex layout-row layout-wrap layout-align-start-start ${styles.carriage_row}`}>
                <h4 className="flex-95 layout-row">{checkPreCarriage(shipment, 'Delivery').type}&nbsp;
                  {shipment.delivery_address
                    ? `on ${moment(checkPreCarriage(shipment, 'Delivery').date)
                      .format('DD/MM/YYYY')}`
                    : ''}
                </h4>
                {shipment.delivery_address ? (
                  <div className={`layout-row flex-95 layout-align-start-center ${styles.carriage_address} ${styles.margin_fixes}`}>
                    <p>{shipment.delivery_address.street}&nbsp;
                      {shipment.delivery_address.street_number},&nbsp;
                      <strong>{shipment.delivery_address.city},&nbsp;
                        {shipment.delivery_address.country.name} </strong>

                    </p>
                  </div>
                ) : ''}
              </div>
            </div>

          </div>
        )}

      </div>
      <div className={`layout-column flex-40 ${styles.image}`} style={bg} />
    </div>
  )
}

ShipmentOverviewShowCard.propTypes = {
  et: PropTypes.node.isRequired,
  hub: PropTypes.hub.isRequired,
  bg: PropTypes.objectOf(PropTypes.string),
  shipment: PropTypes.objectOf(PropTypes.any),
  editTime: PropTypes.bool,
  theme: PropTypes.theme,
  text: PropTypes.string,
  handleSaveTime: PropTypes.func.isRequired,
  toggleEditTime: PropTypes.func.isRequired,
  isAdmin: PropTypes.bool
}

ShipmentOverviewShowCard.defaultProps = {
  bg: {},
  shipment: {},
  text: '',
  editTime: false,
  theme: null,
  isAdmin: false
}
