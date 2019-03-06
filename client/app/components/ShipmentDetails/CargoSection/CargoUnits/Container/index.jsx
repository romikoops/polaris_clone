import React from 'react'
import { withNamespaces } from 'react-i18next'
import { get } from 'lodash'
import CargoUnitBox from '../CargoUnit/Box'
import styles from './index.scss'
import FormsySelect from '../../../../Formsy/Select'
import CargoUnitNumberInput from '../CargoUnit/NumberInput'
import CheckboxWrapper from '../../../GetOffersSection/Checkboxes/CheckboxWrapper'
import { getTareWeight, getSizeClassOptions } from '../../../../../helpers'

function Container ({
  container, i, onChangeCargoUnitSelect, onDeleteUnit, theme, scope, t,
  onChangeCargoUnitCheckbox, onChangeCargoUnitInput, toggleModal
}) {
  // TODO: implement dynamic maxPayloadInKg for each Tenant
  const tareWeight = getTareWeight(container) || 2370
  const maxPayloadInKg = 35000 - tareWeight

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
            onBlur={onChangeCargoUnitInput}
            unit="kg"
            onExcessDimensionsRequest={() => toggleModal('maxDimensions')}
            maxDimension={maxPayloadInKg}
            maxDimensionsErrorText={t('errors:maxWeight')}
            errorMessageStyles={{
              top: '3px',
              left: '235px'
            }}
            value={container.payloadInKg}
          />
        </div>
        <div className="flex-100 layout-row" />
        <div
          className={`layout-row flex-100 layout-wrap layout-align-space-between-center ${styles.padding_section}`}
          style={{ margin: '20px 0' }}
        >

          <div className="layout-row flex-60 layout-wrap layout-align-start-center ccb_size_class">
            <div style={{ width: '95%' }}>
              <FormsySelect
                className={styles.select_100}
                inputProps={{ name: `${i}-sizeClass` }}
                name={`${i}-sizeClass`}
                options={getSizeClassOptions()}
                placeholder={t('common:containerSize')}
                value={container.sizeClass}
                onChange={(option) => { onChangeCargoUnitSelect(i, 'sizeClass', get(option, 'value')) }}
                validationErrors={{ isDefaultRequiredValue: t('common:noBlank') }}
                required
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
