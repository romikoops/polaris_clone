import React from 'react'
import PropTypes from 'prop-types'
import { withNamespaces } from 'react-i18next'

export function UserMergedShipHeaders (props) {
  const { title, total, t } = props

  return (
    <div className="flex-100 layout-row layout-align-start-center">
      <div className="flex-40 layout-row layout-align-start-center">
        <h3 className="flex-none" style={{ paddingRight: '10px' }}>
          {title}
        </h3>
        <h3 className="flex-none">({total})</h3>
      </div>
      <div className="flex-15 layout-row layout-align-start-center">
        <h3 className="flex-none">
          {t('common:reference')}
        </h3>
      </div>
      <div className="flex-15 layout-row layout-align-start-center">
        <h3 className="flex-none">
          {t('common:status')}
        </h3>
      </div>
      <div className="flex-15 layout-row layout-align-start-center">
        {/* <h3 className="flex-none">Incoterm </h3> */}
      </div>
      <div className="flex-15 layout-row layout-align-start-center">
        <h3 className="flex-none">
          {t('common:requiresAction')}
        </h3>
      </div>
    </div>
  )
}

UserMergedShipHeaders.propTypes = {
  t: PropTypes.func.isRequired,
  title: PropTypes.string.isRequired,
  total: PropTypes.number.isRequired
}

export default withNamespaces('common')(UserMergedShipHeaders)
