import React from 'react'
import { withNamespaces } from 'react-i18next'
import CargoUnitBox from '../CargoUnit/Box'
import styles from './index.scss'
import Tooltip from '../../../../Tooltip/Tooltip'
import { NamedSelect } from '../../../../NamedSelect/NamedSelect'
import Checkbox from '../../../../Checkbox/Checkbox'
import CargoUnitNumberInput from '../CargoUnit/NumberInput'
import CheckboxWrapper from '../../../GetOffersSection/Checkboxes/CheckboxWrapper'

const availableContainerTypes = [
  '20\' Dry Container',
  '40\' Dry Container',
  '40\' High Cube'
]

const selectOptions = [
  { label: availableContainerTypes[0], value: 'smallDryContainer' },
  { label: availableContainerTypes[1], value: 'largeDryContainer' },
  { label: availableContainerTypes[2], value: 'highCube' }
]

function Container ({
  container, i, onChangeCargoUnitSelect, onDeleteUnit, theme, scope, t, onChangeCargoUnitCheckbox, onChangeCargoUnitInput, toggleModal
}) {
  const showColliTypeErrors = false

  return (
    <CargoUnitBox onChangeCargoUnitInput={onChangeCargoUnitInput} cargoUnit={container} i={i} onDeleteUnit={onDeleteUnit}>
      <div style={{ position: 'relative' }}>
        <div className="flex-100 layout-row" />
        <div
          className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.padding_section}`}
          style={{ margin: '20px 0' }}
        >

          <div className="layout-row flex-40 layout-wrap layout-align-start-center colli_type">
            <div style={{ width: '95%' }}>
              <NamedSelect
                className={styles.select_100}
                inputProps={{ name: `${i}-sizeClass` }}
                name={`${i}-sizeClass`}
                onChange={onChangeCargoUnitSelect}
                options={selectOptions}
                placeholder={t('common:containerSize')}
                showErrors={showColliTypeErrors}
                value={container.sizeClass}
              />
            </div>
          </div>

          <div className="layout-row flex-35">
            <CargoUnitNumberInput
              labelText={t('cargo:cargoGrossWeight')}
              name={`${i}-weight`}
              onChange={onChangeCargoUnitInput}
              unit="kg"
              maxDimension={200000}
              value={container.weight}
            />
          </div>

          <div
            className="layout-row flex-25 layout-wrap layout-align-start-center"
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
