import React from 'react'
import { translate } from 'react-i18next'
import styles from './index.scss'
import PropTypes from '../../prop-types'
import GreyBox from '../GreyBox/GreyBox'

function ShipmentNotes ({
  shipment,
  t
}) {
  return (
    <GreyBox
      wrapperClassName={`layout-row layout-wrap layout-sm-column layout-xs-column flex-100
              ${styles.no_border_top} margin_bottom`}
      contentClassName="layout-row flex-100"
      content={(
        <div className="layout-column flex-100">
          <div className={`layout-row flex-100 flex-sm-100 flex-xs-100 ${styles.column_info}`}>
            <div className={`flex-33 layout-row offset-5 layout-align-start-center layout-wrap ${styles.border_right}`}>
              {shipment.total_goods_value ? (
                <div className="flex-100 layout-xs-column layout-row layout-align-start-center">
                  <span className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row">{t('cargo:totalValue')}:</span>
                  <p className={`flex-60 flex-xs-100 layout-align-xs-start-center layout-row ${styles.info_values}`}>
                    {shipment.total_goods_value.value}&nbsp;
                    {shipment.total_goods_value.currency}
                  </p>
                </div>
              ) : (
                <div className="flex-100 layout-xs-column layout-row layout-align-start-start">
                  <span className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row">{t('cargo:totalValue')}:</span>
                  <p className={`flex-60 flex-xs-100 layout-align-xs-start-center layout-row ${styles.info_values}`}>
                        -
                  </p>
                </div>
              )}
            </div>
            <div className={`flex-33 layout-row offset-5 layout-align-start-center layout-wrap ${styles.border_right}`}>
              {shipment.eori ? (
                <div className="flex-100 layout-xs-column layout-row layout-align-start-start">
                  <span className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row">{t('bookconf:eori')}:</span>
                  <p className={`flex-60 flex-xs-100 layout-align-xs-start-center layout-row ${styles.info_values}`}>
                    {shipment.eori}
                  </p>
                </div>
              ) : (
                <div className="flex-100 layout-xs-column layout-row layout-align-start-start">
                  <span className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row">{t('bookconf:eori')}:</span>
                  <p className={`flex-60 flex-xs-100 layout-align-xs-start-center layout-row ${styles.info_values}`}>
                            -
                  </p>
                </div>
              )}
            </div>
            <div className="flex-33 layout-row offset-5 layout-align-center-center layout-wrap">
              {shipment.incoterm_text ? (
                <div className="flex-100 layout-xs-column layout-row layout-align-start-start">
                  <span className="flex-40 flex-xs-100 layout-align-center-center layout-row">{t('common:incoterm')}:</span>
                  <p className="flex-60 flex-xs-100 layout-align-xs-start-center layout-row">
                    {shipment.incoterm_text}
                  </p>
                </div>
              ) : (
                <div className="flex-100 layout-xs-column layout-row layout-align-start-start">
                  <span className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row">{t('common:incoterm')}:</span>
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
                  <span className="flex-20 layout-row">{t('common:descriptionGoods')}:</span>
                  <p className="flex-80 layout-padding layout-row">
                    {shipment.cargo_notes}
                  </p>
                </div>
              ) : (
                <div className="flex-100 layout-row layout-align-start-center">
                  <span className="flex-20 layout-row">{t('common:descriptionGoods')}:</span>
                  <p className="flex-80 layout-padding layout-row">
                        -
                  </p>
                </div>
              )}
            </div>
            <div className="flex-100 flex-sm-100 padding_top_sm padding_bottom_sm flex-xs-100 layout-row offset-5 layout-align-start-start layout-wrap">
              {shipment.notes ? (
                <div className="flex-100 layout-row layout-align-start-center">
                  <span className="flex-20 layout-row">{t('common:notes')}:</span>
                  <p className="flex-80 layout-padding layout-row">
                    {shipment.notes}
                  </p>
                </div>
              ) : (
                <div className="flex-100 layout-row layout-align-start-center">
                  <span className="flex-20 layout-row">{t('common:notes')}:</span>
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
  )
}

ShipmentNotes.propTypes = {
  shipment: PropTypes.shipment,
  t: PropTypes.func.isRequired
}

ShipmentNotes.defaultProps = {
  shipment: {}
}

export default translate(['common', 'cargo', 'bookconf'])(ShipmentNotes)
