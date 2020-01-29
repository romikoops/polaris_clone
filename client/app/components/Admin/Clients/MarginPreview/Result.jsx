import React from 'react'
import { withNamespaces } from 'react-i18next'
import { moment } from '../../../../constants'
import GreyBox from '../../../GreyBox/GreyBox'
import styles from './index.scss'
import { capitalize } from '../../../../helpers'

function AdminClientMarginPreviewResult ({ results, tenant, t }) {
  const getMarginValue = (margin, key) => {
    const effectiveMargin = margin.marginDetails.filter(md => md.fee_code === key)[0] || margin
    const value = effectiveMargin.operator === '%' ? parseFloat(effectiveMargin.value) * 100 : effectiveMargin.value

    return `@ ${value} ${margin.operator}`
  }

  return (
    <div className="flex-100 layout-row layout-align-start-start layout-wrap">
      { results.map(result => (
        <GreyBox
          wrapperClassName={`flex-100 ${styles.result_box}`}
          contentClassName="flex-100 layout-row layout-align-start-start layout-wrap"
        >
          <div className={`flex-100 layout-row layout-align-start-start greyBg ${styles.header}`}>
            <div className="flex layout-row layout-align-center-center">
              <h2 className="flex">
                {result.itinerary.name}
              </h2>
            </div>
            <div className="flex layout-row layout-align-center-center">
              <h4 className="flex-none">
                {`${t('admin:cargoClass')} ${t(`common:${result.cargo_class}`)}`}
              </h4>
            </div>
            <div className="flex layout-row layout-align-center-center">
              <h4 className="flex-none">
                {`${t('admin:serviceLevel')}: ${capitalize(result.service_level)}`}
              </h4>
            </div>
          </div>
          <div className="flex-100 layout-row layout-align-start-start">
            <table className={`flex-100 ${styles.result_table}`}>
              <tbody>
                <tr>
                  <th>{t('admin:label')}</th>
                  <th>{t('admin:effectivePeriod')}</th>
                  <th>
                    {t('admin:source')}
                  </th>
                  { Object.keys(result.data).map(k => <th>{k}</th>)}
                </tr>
                <tr>
                  <td>{t('admin:basePricing')}</td>
                  <td>
                    {`${moment(result.effective_date).format('MM/YY')} - ${moment(result.expiration_date).format('MM/YY')}`}
                  </td>
                  <td>
                    {t('admin:base')}
                  </td>
                  { Object.keys(result.data).map(k => (
                    <td>
                      {`${result.data[k].rate} ${result.data[k].currency}`}
                    </td>
                  ))}
                </tr>
                { result.manipulation_steps.map((ms, i) => (
                  <tr>
                    <td>
                      {`Margin ${i + 1}`}
                    </td>
                    <td>
                      {`${moment(ms.margin.effectiveDate).format('MM/YY')} - ${moment(ms.margin.expirationDate).format('MM/YY')}`}
                    </td>
                    <td>
                      {ms.applicable}
                    </td>
                    { Object.keys(result.data).map(k => (
                      <td>
                        {`${ms.fees[k].rate} ${ms.fees[k].currency} ${getMarginValue(ms.margin, k)}`}
                      </td>
                    ))}
                  </tr>))}
              </tbody>
            </table>
          </div>
        </GreyBox>)) }
    </div>
  )
}

AdminClientMarginPreviewResult.defaultProps = {
  results: []
}

export default withNamespaces(['admin', 'common'])(AdminClientMarginPreviewResult)
