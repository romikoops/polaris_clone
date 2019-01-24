import React from 'react'
import { withNamespaces } from 'react-i18next'
import CargoUnitBox from '../CargoUnit/Box'
import styles from './index.scss'
import Tooltip from '../../../../Tooltip/Tooltip'
import { NamedSelect } from '../../../../NamedSelect/NamedSelect'
import CargoUnitNumberInput from '../CargoUnit/NumberInput'
import CheckboxWrapper from '../../../GetOffersSection/Checkboxes/CheckboxWrapper'
import { CONTAINER_DESCRIPTIONS } from '../../../../../constants'

const selectOptions = Object.entries(CONTAINER_DESCRIPTIONS).reduce((options, [value, label]) => (
  value === 'lcl' ? options : [...options, { value, label }]
), [])

function Container ({
  container, i, onChangeCargoUnitSelect, onDeleteUnit, theme, scope, t,
  onChangeCargoUnitCheckbox, onChangeCargoUnitInput, toggleModal
}) {
  // TODO: implement dynamic maxPayloadInKg
  const maxPayloadInKg = 200000

  return (
    <CargoUnitBox
      onChangeCargoUnitInput={onChangeCargoUnitInput}
      cargoUnit={container}
      i={i}
      onDeleteUnit={onDeleteUnit}
      container
    >
      <div style={{ position: 'relative' }}>
        <div className="layout-row flex-55">
          <CargoUnitNumberInput
            className={styles.padding_section}
            labelText={t('cargo:cargoGrossWeight')}
            name={`${i}-payloadInKg`}
            onChange={onChangeCargoUnitInput}
            unit="kg"
            maxDimension={maxPayloadInKg}
            value={container.payloadInKg}
          />
        </div>
        <div className="flex-100 layout-row" />
        <div
          className={`layout-row flex-100 layout-wrap layout-align-space-between-center ${styles.padding_section}`}
          style={{ margin: '20px 0' }}
        >

          <div className="layout-row flex-60 layout-wrap layout-align-start-center colli_type">
            <div style={{ width: '95%' }}>
              <NamedSelect
                className={styles.select_100}
                inputProps={{ name: `${i}-sizeClass` }}
                name={`${i}-sizeClass`}
                onChange={onChangeCargoUnitSelect}
                options={selectOptions}
                placeholder={t('common:containerSize')}
                value={container.sizeClass}
              />
            </div>
          </div>

          <div
            className="layout-row flex-40 layout-wrap layout-align-start-center"
            onClick={scope.dangerous_goods ? '' : () => toggleModal('noDangerousGoods')}
          >
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">
              <CheckboxWrapper
                id={`${i}-dangerousGoods`}
                name={`${i}-dangerousGoods`}
                theme={theme}
                size="14px"
                disabled={!scope.dangerous_goods}
                checked={container.dangerousGoods}
                onChange={onChangeCargoUnitCheckbox}
                labelContent={t('common:dangerousGoods')}
                show
                tooltipText="dangerous_goods"
              />
            </div>
          </div>
        </div>
      </div>
    </CargoUnitBox>
  )
}

export default withNamespaces('common')(Container)
