import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import styles from './index.scss'
import { documentGlossary } from '../../../../constants'
import { history } from '../../../../helpers'
import TextHeading from '../../../TextHeading/TextHeading'
import { RoundButton } from '../../../RoundButton/RoundButton'

export class AdminUploadsSuccess extends Component {
  static goBack () {
    history.goBack()
  }

  static prepShipment (baseShipment, clients, hubsObj) {
    const shipment = Object.assign({}, baseShipment)
    shipment.clientName = clients[shipment.user_id]
      ? `${clients[shipment.user_id].first_name} ${clients[shipment.user_id].last_name}`
      : ''
    shipment.companyName = clients[shipment.user_id]
      ? `${clients[shipment.user_id].company_name}`
      : ''
    const hubKeys = shipment.schedule_set[0].hub_route_key.split('-')
    shipment.originHub = hubsObj[hubKeys[0]] ? hubsObj[hubKeys[0]].name : ''
    shipment.destinationHub = hubsObj[hubKeys[1]] ? hubsObj[hubKeys[1]].name : ''

    return shipment
  }

  render () {
    const {
      t, theme, data, closeDialog
    } = this.props
    const stats = data
    const statView = stats ? Object.keys(stats).filter(k => !['has_errors', 'errors'].includes(k))
      .map(statKey => (
        <div className={`${styles.stat_row} flex-100 layout-row layout-align-space-between-center`}>
          <div className="flex-33 layout-row layout-align-start-center">
            <p className="flex-none">
              <strong>{documentGlossary[statKey]}</strong>
            </p>
          </div>
          <div className="flex-33 layout-row layout-align-start-center">
            <p className="flex-none">{`${t('admin:numberCreated')} ${stats[statKey].number_created}`}</p>
          </div>
          <div className="flex-33 layout-row layout-align-start-center">
            <p className="flex-none">{`${t('admin:numberUpdated')} ${stats[statKey].number_updated}`}</p>
          </div>
        </div>
      )) : ''
    const errorView = stats.has_errors ? stats.errors.map(error => (
      <tr className="flex-100 layout-row">
        <td className={`flex-50 ${styles.error_reason}`}>
          {error.reason}
        </td>
        <td className={`flex-50 ${styles.error_row}`}>
          {error.row_no}
        </td>
      </tr>
    )) : ''

    return (
      <div
        className={`flex-none layout-row layout-wrap layout-align-center-center ${
          styles.results_backdrop
        }`}
      >
        <div
          className={`flex-none layout-row layout-wrap layout-align-start-start ${
            styles.results_fade
          }`}
          onClick={closeDialog}
        />
        <div
          className={`flex-none layout-row layout-wrap layout-align-start-start ${
            styles.results_box
          }`}
        >
          <div className="flex-100 layout-row layout-align-start-center">
            { stats.has_errors
              ? <TextHeading theme={theme} text={t('admin:uploadFailed')} size={3} />
              : <TextHeading theme={theme} text={t('admin:uploadSuccessful')} size={3} /> }
          </div>
          <div className="flex-100 layout-row layout-align-start-center layout-wrap">
            {statView}
          </div>
          <div className={`flex-100 layout-row layout-align-start-center layout-wrap ${styles.error_box}`}>
            <table className="flex-100 layout-row layout-align-start-start">
              <tbody className="flex-100 layout-row layout-wrap">
                <thead className="flex-100 layout-row">
                  <tr className="flex-100 layout-row">
                    <th className={`flex-50 ${styles.error_reason}`}>{t('admin:reason')}</th>
                    <th className={`flex-50 ${styles.error_row}`}>{t('admin:rowNo')}</th>
                  </tr>
                </thead>
                {errorView}
              </tbody>
            </table>
          </div>
          <div className="flex-100 layout-row layout-align-center-center layout-wrap layout-padding">
            {stats.has_errors ? <p className="flex">{t('admin:errorTip')}</p> : ''}
          </div>
          <div className="flex-100 layout-row layout-align-end-center layout-wrap">
            <RoundButton
              text={t('admin:continue')}
              theme={theme}
              size="small"
              handleNext={closeDialog}
              iconClass="fa-chevron-right"
              active
            />
          </div>
        </div>
      </div>
    )
  }
}
AdminUploadsSuccess.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  data: PropTypes.objectOf(PropTypes.any),
  closeDialog: PropTypes.func.isRequired
}

AdminUploadsSuccess.defaultProps = {
  theme: null,
  data: {}
}

export default withNamespaces(['admin', 'common'])(AdminUploadsSuccess)
