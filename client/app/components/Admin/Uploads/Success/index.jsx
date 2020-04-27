import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import styles from './index.scss'
import TextHeading from '../../../TextHeading/TextHeading'
import { RoundButton } from '../../../RoundButton/RoundButton'
import GreyBox from '../../../GreyBox/GreyBox'

export class AdminUploadsSuccess extends Component {
  static sanitizeStatKey (statKey) {
    if (statKey.includes('/')) {
      return statKey.split('/')[1]
    }

    return statKey
  }

  render () {
    const {
      t, theme, data, closeDialog
    } = this.props
    const stats = data

    const statView = stats ? Object.keys(stats).filter(k => !['has_errors', 'errors'].includes(k))
      .map(statKey => (
        <div className={`${styles.stat_row} flex-100 layout-row layout-align-space-between-center`}>
          <div className="flex-25 layout-row layout-align-start-center">
            <p className="flex-none">
              <strong>{t(`uploads:${AdminUploadsSuccess.sanitizeStatKey(statKey)}`)}</strong>
            </p>
          </div>
          <div className="flex-25 layout-row layout-align-start-center">
            <p className="flex-none">{`${t('admin:numberCreated')} ${stats[statKey].number_created}`}</p>
          </div>
          <div className="flex-25 layout-row layout-align-start-center">
            <p className="flex-none">{`${t('admin:numberUpdated')} ${stats[statKey].number_updated}`}</p>
          </div>
          <div className="flex-25 layout-row layout-align-start-center">
            <p className="flex-none">{`${t('admin:numberDeleted')} ${stats[statKey].number_deleted}`}</p>
          </div>
        </div>
      )) : ''
    const errorView = stats.has_errors ? stats.errors.map(error => (
      <tr className="flex-100 layout-row">
        <td className={`flex-60 ${styles.error_reason}`}>
          {error.reason}
        </td>
        <td className={`flex-20 ${styles.error_row}`}>
          {error.sheet_name}
        </td>
        <td className={`flex-20 ${styles.error_row}`}>
          {error.row_nr}
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
          <GreyBox wrapperClassName="padd_20">
            <div className="flex-100 layout-row layout-align-start-center">
              {stats.has_errors
                ? <TextHeading theme={theme} text={t('admin:uploadFailed')} size={3} />
                : <TextHeading theme={theme} text={t('admin:uploadSuccessful')} size={3} />}
            </div>
            <div className="flex-100 layout-row layout-align-start-center layout-wrap">
              {statView}
            </div>
            {stats.has_errors ? (
              <div className={`flex-100 layout-row layout-align-start-center layout-wrap ${styles.error_box}`}>
                <table className="flex-100 layout-row layout-align-start-start">
                  <tbody className="flex-100 layout-row layout-wrap">
                    <thead className="flex-100 layout-row">
                      <tr className="flex-100 layout-row">
                        <th className={`flex-60 ${styles.error_reason}`}>{t('admin:reason')}</th>
                        <th className={`flex-20 ${styles.error_sheet_name}`}>{t('admin:sheet_name')}</th>
                        <th className={`flex-20 ${styles.error_row}`}>{t('admin:rowNo')}</th>
                      </tr>
                    </thead>
                    {errorView}
                  </tbody>
                </table>
              </div>
            ) : ''}
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
          </GreyBox>
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

export default withNamespaces(['admin', 'common', 'uploads'])(AdminUploadsSuccess)
