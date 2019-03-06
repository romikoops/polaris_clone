import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'
import QuantityInput from '../QuantityInput'

function CargoUnitBox ({
  cargoUnit, i, onDeleteUnit, onChangeCargoUnitInput, children, t, uniqKey, container
}) {
  if (!cargoUnit) return ''

  const deletable = typeof onDeleteUnit === 'function'

  return (
    <div
      key={`cargo_item_${i}`}
      name={`${i}-${container ? 'container' : 'cargoItem'}`}
      className="layout-row flex-100 layout-wrap layout-align-stretch"
      style={{ position: 'relative', margin: '30px 0' }}
    >
      <div className={`flex-100 layout-align-start-center layout-row ${styles.cargo_unit_header}`}>
        <h3>{container ? t('cargo:yourContainer') : t('cargo:yourCargo')}</h3>

        {
          deletable && (
            <div className={styles.delete_icon} onClick={() => onDeleteUnit(i)}>
              {t('common:delete')}
              <i className="fa fa-trash" />
            </div>
          )
        }
      </div>
      <div className={`flex-100 layout-row layout-wrap ${styles.cargo_unit_inputs}`}>
        <div className="flex-15 layout-row layout-align-center">
          <QuantityInput
            i={i}
            cargoItem={cargoUnit}
            onChange={onChangeCargoUnitInput}
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
