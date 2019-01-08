import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'

function AddUnitButton ({ onClick, theme, t }) {
  const textStyle = {
    background:
      theme && theme.colors
        ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
        : 'black'
  }

  return (
    <div
      className={`layout-row flex-none ${styles.add_unit} layout-wrap layout-align-center-center`}
      onClick={onClick}
    >
      <i className="fa fa-plus-square-o clip" style={textStyle} />
      <p>
        {t('shipment:addUnit')}
      </p>
    </div>
  )
}

export default withNamespaces('shipment')(AddUnitButton)
