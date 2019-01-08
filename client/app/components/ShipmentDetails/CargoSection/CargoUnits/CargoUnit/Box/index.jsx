import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'
import QuantityInput from '../QuantityInput'

function CargoUnitBox ({
  cargoUnit, i, onDeleteUnit, onChangeQuantityInput, children, t
}) {
  if (!cargoUnit) return ''

  return (
    <div
      key={i}
      name={`${i}-cargoItem`}
      className="layout-row flex-100 layout-wrap layout-align-stretch"
      style={{ position: 'relative', margin: '30px 0' }}
    >
      <div className={`flex-100 layout-align-start-center layout-row ${styles.cargo_unit_header}`}>
        <h3>{t('cargo:yourCargo')}</h3>

        <div className={styles.delete_icon} onClick={() => onDeleteUnit(cargoUnit, i)}>
          {t('common:delete')}
          <i className="fa fa-trash" />
        </div>
      </div>
      <div className={`flex-100 layout-row layout-wrap ${styles.cargo_unit_inputs}`}>
        <div className="flex-15 layout-row layout-align-center">
          <QuantityInput
            i={i}
            cargoItem={cargoUnit}
            onChange={onChangeQuantityInput}
          />
        </div>
        <div className={`${styles.cargo_item_box} ${styles.cargo_item_inputs} flex-85`}>
          { children }
        </div>
      </div>
    </div>
  )
}

export default withNamespaces('common')(CargoUnitBox)
