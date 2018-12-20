import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'
import PropTypes from '../../prop-types'
import GreyBox from '../GreyBox/GreyBox'
import NotesCard from '../Notes/Card'

function ShipmentNotes ({
  shipment,
  t
}) {
  const route_notes = shipment.route_notes ? shipment.route_notes.map((note) => (<NotesCard
        note={note}
        itinerary={shipment.itinerary}
      />)) : ''
    
  return (
    <GreyBox
      wrapperClassName={`layout-row layout-wrap layout-sm-column layout-xs-column flex-100
              ${styles.no_border_top} margin_bottom`}
      contentClassName="layout-row flex-100"
      content={(
        <div className="layout-row layout-wrap flex-100">
          <div className={`layout-row flex-100 flex-sm-100 flex-xs-100 ${styles.column_info}`}>
            <div className={`flex-30 layout-row offset-5 layout-align-start-center layout-wrap ${styles.border_right}`}>
              {shipment.total_goods_value ? (
                <div className="flex-100 layout-xs-column layout-row layout-align-start-center">
                  <span className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row">
                    {t('cargo:totalValue')}
                    :
                  </span>
                  <p className={`flex-60 flex-xs-100 layout-align-xs-start-center layout-row ${styles.info_values}`}>
                    {shipment.total_goods_value.value}
                    &nbsp;
                    {shipment.total_goods_value.currency}
                  </p>
                </div>
              ) : (
                <div className="flex-100 layout-xs-column layout-row layout-align-start-start">
                  <span className="flex-40 flex-xs-100 layout-align-xs-start-center layout-row">
                    {t('cargo:totalValue')}
                    :
                  </span>
                  <p className={`flex-60 flex-xs-100 layout-align-xs-start-center layout-row ${styles.info_values}`}>
                    -
                  </p>
                </div>
              )}
            </div>
            <div className="flex layout-row offset-5 layout-align-start-center layout-wrap">
              <div className="flex-100 layout-row layout-align-start-center">
                <span className="flex-20 layout-row">
                  {t('common:descriptionGoods')}
                  :
                </span>
                <p className="flex-80 layout-padding">
                  {shipment.cargo_notes || '-'}
                </p>
              </div>
            </div>
          </div>
          {shipment.eori || shipment.incoterm_text || shipment.notes ? (
            <div className={`layout-row flex-100 layout-wrap ${styles.column_info}`}>

              {shipment.eori ? (
                <div className={`${shipment.incoterm_text || shipment.notes ? styles.border_bottom : ''}
                flex-95 padding_top_sm padding_bottom_sm layout-row offset-5 layout-align-start-start`}
                >
                  <div className="flex-100 layout-xs-column layout-row layout-align-start-center">
                    <span className="flex-10 layout-row">
                      {t('bookconf:eori')}
                      :
                    </span>
                    <p className={`flex-80 layout-padding layout-row ${styles.info_values}`}>
                      {shipment.eori}
                    </p>
                  </div>
                </div>
              ) : ''}
              {shipment.incoterm_text ? (
                <div className={`${shipment.notes ? styles.border_bottom : ''} flex-95 padding_top_sm padding_bottom_sm layout-row offset-5 layout-align-start-start`}>
                  <div className="flex-100 layout-xs-column layout-row layout-align-start-center">
                    <span className="flex-10 layout-row">
                      {t('common:incoterm')}
                      :
                    </span>
                    <p className="flex-80 layout-padding layout-row">
                      {shipment.incoterm_text}
                    </p>
                  </div>
                </div>
              ) : ''}
              {shipment.route_notes || shipment.notes ? (
                <div className="flex-95 padding_top_sm padding_bottom_sm layout-row offset-5 layout-align-start-start layout-wrap">
                  <div className="flex-100 layout-row layout-align-start-center">
                    <span className="flex-10 layout-row">
                      {t('common:notes')}
                      :
                    </span>
                    <div className="flex layout-row layout-align-start-start">
                      {route_notes}
                      {shipment.notes ? (
                        <p className="flex-100">
                          {shipment.notes}
                        </p>
                      ) : ''}
                    </div>
                  </div>
                </div>
              ) : ''}
            </div>
          ) : ''}

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

export default withNamespaces(['common', 'cargo', 'bookconf'])(ShipmentNotes)
