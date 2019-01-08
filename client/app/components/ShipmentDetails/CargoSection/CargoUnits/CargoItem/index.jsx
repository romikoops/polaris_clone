import React from 'react'
import uuid from 'uuid'
import { withNamespaces } from 'react-i18next'
import CargoUnitBox from '../CargoUnit/Box'
import styles from './index.scss'
import CargoUnitNumberInput from '../CargoUnit/NumberInput'
import Tooltip from '../../../../Tooltip/Tooltip'
import { NamedSelect } from '../../../../NamedSelect/NamedSelect'
import Checkbox from '../../../../Checkbox/Checkbox'
import kg from '../../../../../assets/images/cargo/kg.png'
import length from '../../../../../assets/images/cargo/length.png'
import width from '../../../../../assets/images/cargo/width.png'
import height from '../../../../../assets/images/cargo/height.png'

function CargoItem ({
  cargoItem, i, onDeleteUnit, theme, scope, t
}) {
  const tooltipId = uuid.v4()

  // TODO: implement collective weight based on scope
  // scope.frontend_consolidation ? inputs.collectiveWeight : inputs.grossWeight

  // TODO: implement cargoItemTypes
  // const showColliTypeErrors = !cargoItemTypes[i] || !cargoItemTypes[i].label
  const cargoItemTypes = []
  const showColliTypeErrors = false
  const availableCargoItemTypes = []

  // TODO: implement
  const toggleCheckbox = console.log
  const toggleModal = console.log

  return (
    <CargoUnitBox cargoUnit={cargoItem} i={i} onDeleteUnit={onDeleteUnit}>
      <div style={{ position: 'relative' }}>
        <div
          className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.padding_section}`}
          style={{ marginBottom: '20px' }}
        >
          <CargoUnitNumberInput
            className="flex-20"
            value={cargoItem.dimensionX}
            image={<img data-for={tooltipId} data-tip={t('common:length')} src={length} alt="length" border="0" />}
            unit="cm"
            name={`${i}-dimensionX`}
            onChange={console.log}
            onExcessDimensionsRequest={console.log}
            maxDimension="23"
            maxDimensionsErrorText={t('errors:maxLength')}
            labelText={t('common:length')}
          />
          <CargoUnitNumberInput
            className="flex-20"
            value={cargoItem.dimensionY}
            image={<img data-for={tooltipId} data-tip={t('common:width')} src={width} alt="width" border="0" />}
            unit="cm"
            name={`${i}-dimensionY`}
            onChange={console.log}
            onExcessDimensionsRequest={console.log}
            maxDimension="23"
            maxDimensionsErrorText={t('errors:maxWidth')}
            labelText={t('common:width')}
          />
          <CargoUnitNumberInput
            className="flex-20"
            value={cargoItem.dimensionZ}
            image={<img data-for={tooltipId} data-tip={t('common:height')} src={height} alt="height" border="0" />}
            unit="cm"
            name={`${i}-dimensionZ`}
            onChange={console.log}
            onExcessDimensionsRequest={console.log}
            maxDimension="23"
            maxDimensionsErrorText={t('errors:maxHeight')}
            labelText={t('common:height')}
          />
          <CargoUnitNumberInput
            className="flex-30 offset-5"
            value={cargoItem.payloadInKg}
            image={<img data-for={tooltipId} data-tip={t('common:grossWeight')} src={kg} alt="weight" border="0" />}
            tooltip={<Tooltip color={theme.colors.primary} icon="fa-info-circle" text="payload_in_kg" />}
            unit="kg"
            name={`${i}-payloadInKg`}
            onChange={console.log}
            onExcessDimensionsRequest={console.log}
            maxDimension="23"
            maxDimensionsErrorText={t('errors:maxWeight')}
            labelText={t('common:Gross Weight')}
          />
        </div>
        <div className="flex-100 layout-row" />
        <div
          className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.padding_section}`}
          style={{ margin: '20px 0' }}
        >
          <div className="layout-row flex-40 layout-wrap layout-align-start-center colli_type">
            <div style={{ width: '95%' }}>
              <NamedSelect
                placeholder={t('common:selectColliType')}
                className={styles.select_100}
                showErrors={showColliTypeErrors}
                inputProps={{ name: `${i}-colliType` }}
                name={`${i}-colliType`}
                value={cargoItemTypes[i] && cargoItemTypes[i].label && cargoItemTypes[i]}
                options={availableCargoItemTypes}
                onChange={console.log}
              />
            </div>
          </div>

          <div
            className={`layout-row flex layout-wrap layout-align-start-center ${styles.cargo_unit_check}`}
            onClick={scope.dangerous_goods ? '' : () => toggleModal('noDangerousGoods')}
          >
            <Checkbox
              id={`${i}-dangerous_goods`}
              name={`${i}-dangerous_goods`}
              onChange={(checked, e) => toggleCheckbox(checked, e)}
              checked={cargoItem ? cargoItem.dangerous_goods : false}
              theme={theme}
              size="15px"
              disabled={!scope.dangerous_goods}
            />
            <div className="layout-row flex-75 layout-wrap layout-align-start-center">
              <label className={`${styles.input_check} flex-none pointy`} htmlFor={`${i}-dangerous_goods`}>
                <p>{t('common:dangerousGoods')}</p>
              </label>
              <Tooltip color={theme.colors.primary} icon="fa-info-circle" text="dangerous_goods" />
            </div>
          </div>
          <div
            className={`layout-row flex layout-wrap layout-align-end-center ${styles.cargo_unit_check}`}
            onClick={scope.non_stackable_goods ? '' : () => toggleModal('nonStackable')}
          >
            <Checkbox
              id={`${i}-stackable`}
              name={`${i}-stackable`}
              onChange={(checked, e) => toggleCheckbox(!checked, e)}
              checked={cargoItem ? !cargoItem.stackable : false}
              theme={theme}
              size="15px"
              disabled={!scope.non_stackable_goods}
            />
            <div className="layout-row flex-65 layout-wrap layout-align-start-center">
              <label className={`${styles.input_check} flex-none pointy`} htmlFor={`${i}-stackable`}>
                <p>{t('common:nonStackable')}</p>
              </label>
              <Tooltip color={theme.colors.primary} icon="fa-info-circle" text="non_stackable" />
            </div>
          </div>
        </div>
      </div>
      <div className={`${styles.cargo_item_info} flex-100'`}>
        <div className={`${styles.inner_cargo_item_info} layout-row flex-100 layout-wrap layout-align-start`}>
          <div className="flex-25 layout-wrap layout-row">
            {'inputs.totalVolume'}
            {'inputs.chargeableVolume'}
          </div>
          <div className={`${styles.padding_left} flex-25 layout-wrap layout-row`}>
            {'inputs.totalWeight'}
            {'inputs.chargeableWeight'}
          </div>
        </div>
      </div>
    </CargoUnitBox>
  )
}

export default withNamespaces('common')(CargoItem)
