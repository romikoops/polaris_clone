import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import DocumentsDownloader from '../Documents/Downloader'
import styles from './index.scss'
import {
  numberSpacing
} from '../../helpers'

class PricingBreakdown extends Component {
  static renderValue (operator, value) {
    if (operator === '+') return numberSpacing(value, 2)

    return Number(value) * 100
  }

  render () {
    const {
      t, data
    } = this.props

    const { fee, stages, name } = data
    const initialPrice = stages.find(breakdown => breakdown.order === 0).adjusted_rate
    const metadata = initialPrice.rate_origin
    const breakdownLines = stages.filter(breakdown => breakdown.order !== 0).map((breakdown) => {
      const {
        target_type,
        target_name,
        adjusted_rate
      } = breakdown
      const {
        operator,
        margin_value
      } = adjusted_rate

      return (
        <div className={`flex-100 layout-row layout-align-start-center ${styles.breakdown_line}`}>
          <div className="flex-50 layout-align-start-center">
            <p className="flex-none">
              {`from ${target_type} ${target_name || ''}`}
            </p>
          </div>
          <div className="flex-50 layout-align-end-center end">
            <p className="flex-none">
              {`${operator} ${initialPrice.currency} ${PricingBreakdown.renderValue(operator, margin_value)}`}
            </p>
          </div>
        </div>
      )
    })
    if (breakdownLines.length === 0) {
      breakdownLines.push(
        <div className={`flex-100 layout-row layout-align-start-center ${styles.breakdown_line}`}>
          <div className="flex-50 layout-align-start-center" />
          <div className="flex-50 layout-align-end-center end">
            <p className="flex-none">
              {t('admin:noMarginsApplied')}
            </p>
          </div>
        </div>
      )
    }

    return (
      <div className="flex-100 layout-row layout-align-center-center layout-wrap">
        { metadata &&
          (
            <div className="flex-100 layout-row layout-align-center-center layout-wrap">
              <div className="flex-100 layout-row">
                <h3 className="flex-none">
                  {t('admin:metadata')}
                </h3>
              </div>
              <div className={`flex-100 layout-row layout-align-space-between-center ${styles.breakdown_line}`}>
                <p className={`flex-none ${styles.row_header}`}>
                  {t('admin:sourceFile')}
                </p>
                <p className="flex-none">{metadata.file_name}</p>
              </div>
              <div className={`flex-100 layout-row layout-align-space-between-center ${styles.breakdown_line}`}>
                <p className="flex-none">{t('admin:rowNumber')}</p>
                <p className="flex-none">{metadata.row_number}</p>
              </div>
              { metadata.document_id &&
              (
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.breakdown_line}`}>
                  <p className="flex-none">{t('admin:downloadOriginalFile')}</p>
                  <DocumentsDownloader target="id" options={{ id: metadata.document_id }} modal />
                </div>
              )}
            </div>
          )
        }
        <div className="flex-100 layout-row layout-align-center-center layout-wrap">
          <div className="flex-100 layout-row">
            <h3 className="flex-none">
              {t('admin:pricingChanges')}
            </h3>
          </div>

          <div className={`flex-100 layout-row layout-align-start-center ${styles.breakdown_line}`}>
            <p className={`flex-50 ${styles.row_header}`}>{t('admin:initialRate')}</p>
            <p className="flex-50 end">{`${initialPrice.currency} ${initialPrice.rate || initialPrice.value} ${initialPrice.rate_basis}`}</p>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
            <h3 className={`flex-100 ${styles.row_header}`}>
              {t('admin:margins')}
            </h3>
            {breakdownLines}
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
            <h3 className={`flex-100 ${styles.row_header}`}>
              {t('admin:finalAdjustedRate')}
            </h3>
            <div className={`flex-100 layout-row layout-wrap layout-align-space-between-center ${styles.breakdown_line}`}>
              <p className="flex-50">{name}</p>
              <p className="flex-50 end">{`${numberSpacing(fee.rate || fee.value, 2)} ${fee.currency}`}</p>
            </div>
          </div>
        </div>
        <div className={`flex-100 layout-row layout-wrap layout-align-end-center ${styles.breakdown_line}`} />
      </div>
    )
  }
}


export default withNamespaces(['admin'])(PricingBreakdown)
