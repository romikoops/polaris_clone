import React from 'react'
import { withNamespaces } from 'react-i18next'
import { get, has } from 'lodash'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import { adminActions } from '../../../../actions'
import { numberSpacing } from '../../../../helpers'
import styles from './index.scss'
import Margins from './Margins'
import FlatMargins from './FlatMargins'
import TruckingMargins from './TruckingMargins'
import Fees from './Fees'
import TruckingFees from './TruckingFees'
import DocumentsDownloader from '../../../Documents/Downloader'

function AdminMarginPreviewRate ({
  type, rate, price, t, adminDispatch
}) {
  function viewOwner (margin) {
    let url
    switch (margin.target_type) {
      case 'Tenants::User':
        url = `/admin/clients/client/${margin.url_id}`
        break
      case 'Tenants::Group':
        url = `/admin/clients/groups/${margin.url_id}`
        break
      case 'Tenants::Company':
        url = `/admin/clients/companies/${margin.url_id}`
        break

      default:
        url = false
        break
    }
    if (url) {
      adminDispatch.goTo(url)
    }
  }

  function extractCurrency () {
    if (['trucking_pre', 'trucking_on'].includes(type)) {
      const firstKey = Object.keys(rate.original)[0]

      return get(rate, ['original', firstKey, 0, 'rate', 'currency'])
    }

    return get(rate, ['original', 'currency'])
  }

  const currency = extractCurrency()

  function renderRateTable (target) {
    if (['trucking_pre', 'trucking_on'].includes(type)) {
      return <TruckingFees data={rate[target]} />
    }

    return <Fees data={rate[target]} />
  }

  function renderMargins () {
    if (['trucking_pre', 'trucking_on'].includes(type)) {
      return <TruckingMargins margins={rate.margins} currency={currency} viewOwner={viewOwner} />
    }

    return <Margins margins={rate.margins} viewOwner={viewOwner} />
  }

  const showMargins = rate.margins.length > 0
  const showFlatMargins = rate.flatMargins.length > 0
  const feeName = type.includes('trucking') ? t('rates:trucking') : price.name
  const { metadata } = rate

  return (
    <div className={`${styles.container} flex-100 layout-row layout-wrap layout-align-center-center`}>
      <div className={`${styles.header} flex-100 layout-row layout-align-center-center`}>
        <h4 className="flex-none">{t('rates:pricingBreakdownFor', { feeName })}</h4>
      </div>
      <div className={`${styles.table_section} flex-100 layout-row layout-wrap`}>
        <p className={`${styles.table_section_title} flex-100`}>{t('rates:originalRate')}</p>
        {renderRateTable('original')}
      </div>
      <div className={`${styles.table_section} flex-100 layout-row layout-wrap`}>
        <p className={`${styles.table_section_title} flex-100`}>{t('rates:margins')}</p>
        {showMargins ? renderMargins() : <p className={`${styles.no_margins} flex-100`}>{t('rates:noMargins')}</p>}
      </div>
      {
        showFlatMargins &&
        (
          <div className={`${styles.table_section} flex-100 layout-row layout-wrap`}>
            <p className={`${styles.table_section_title} flex-100`}>{t('rates:finalRate')}</p>
            {renderRateTable('final')}
          </div>
        )
      }
      {
        showFlatMargins &&
        (
          <div className={`${styles.table_section} flex-100 layout-row layout-wrap`}>
            <p className={`${styles.table_section_title} flex-100`}>{t('rates:flatMargins')}</p>
            <FlatMargins margins={rate.flatMargins} currency={currency} viewOwner={viewOwner} />
          </div>
        )
      }
      {
        has(price, ['value']) &&
        (
          <div className={`${styles.final_result} flex-100 layout-row layout-wrap`}>
            <h4 className="flex-50">{t('rates:finalChargedAmount')}</h4>
            <h3 className="flex-50">{`${price.currency} ${numberSpacing(price.value, 2)}`}</h3>
          </div>
        )
      }
      { metadata &&
          (
            <div className={`${styles.metadata_section} flex-100 layout-row layout-wrap`}>
              <div className="flex-100 layout-row">
                <p className={`${styles.table_section_title} flex-100`}>
                  {t('admin:sourceData')}
                </p>
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
    </div>
  )
}

function mapStateToProps (state) {
  return {

  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces(['rates'])(AdminMarginPreviewRate))
