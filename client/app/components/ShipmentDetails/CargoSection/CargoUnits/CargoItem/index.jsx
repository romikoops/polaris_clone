import React from 'react'
import { withNamespaces } from 'react-i18next'
import uuid from 'uuid'
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
// TODO test the helper
import calcMaxDimensionsToApply from '../../../../../helpers/calcMaxDimensionsToApply'
import ChargableProperties from './ChargableProperties'

const imageSources = {
  length,
  width,
  height
}

export function getAvailableCargoItemTypes (cargoItemTypes) {
  if (!(Array.isArray(cargoItemTypes))) return []
  const palletType = cargoItemTypes.filter(colli => colli.description === 'Pallet')
  const nonPalletTypes = cargoItemTypes.filter(colli => colli.description !== 'Pallet')
  nonPalletTypes.unshift(palletType[0])

  return nonPalletTypes.map(cargoItemType => ({
    label: cargoItemType.description,
    key: cargoItemType.id,
    dimension_x: cargoItemType.dimension_x,
    dimension_y: cargoItemType.dimension_y
  }))
}

export function getSelectedColliType (availableCargoItemTypes, currentTypeId) {
  // If the user delete its selection, then the value is `undefined`
  if (!currentTypeId) return
  const [currentCargoItemType] = availableCargoItemTypes.filter(
    cargoType => cargoType.id === currentTypeId
  )
  const { description } = currentCargoItemType

  return { label: description, value: description }
}

export function CheckboxWrapper ({
  i, labelText, disabled, onChange, cargoItem, prop, theme, checkedTransform = x => x, onWrapperClick = () => {}
}) {
  return (
    <div
      onClick={onWrapperClick}
      className={`layout-row flex layout-wrap layout-align-start-center ${styles.cargo_unit_check}`}
    >
      <Checkbox
        id={`${i}-${prop}`}
        name={`${i}-${prop}`}
        onChange={onChange}
        checked={checkedTransform(cargoItem[prop])}
        theme={theme}
        size="15px"
        disabled={disabled}
      />
      <div className="layout-row flex-75 layout-wrap layout-align-start-center">
        <label className={`${styles.input_check} flex-none pointy`} htmlFor={`${i}-dangerousGoods`}>
          <p>{labelText}</p>
        </label>
        <Tooltip color={theme.colors.primary} icon="fa-info-circle" text="dangerous_goods" />
      </div>
    </div>
  )
}

class CargoItem extends React.PureComponent {
  constructor (props) {
    super(props)
    this.getSharedProps = this.getSharedProps.bind(this)
    this.getImage = this.getImage.bind(this)
    this.getMaxDimensionsToApply = this.getMaxDimensionsToApply.bind(this)
  }

  getMaxDimensionsToApply () {
    const { ShipmentDetails, maxDimensions } = this.props

    return calcMaxDimensionsToApply(
      ShipmentDetails.availableMots,
      maxDimensions
    )
  }

  getImage (prop) {
    const { t } = this.props

    return (
      <img
        data-for={uuid.v4()}
        data-tip={t(`common:${prop}`)}
        src={imageSources[prop]}
        alt={prop}
        border="0"
      />
    )
  }

  getSharedProps (prop) {
    const {
      i,
      onChangeCargoUnitInput,
      toggleModal,
      cargoItem
    } = this.props
    const maxDimensionsToApply = this.getMaxDimensionsToApply()
    const getMaxDimension = prop => Number(
      maxDimensionsToApply[prop]
    )

    return {
      cargoItem,
      className: prop === 'payloadInKg' ? 'flex-30 offset-5' : 'flex-20',
      i,
      maxDimension: getMaxDimension(prop),
      name: `${i}-${prop}`,
      onChange: onChangeCargoUnitInput,
      onExcessDimensionsRequest: () => toggleModal('maxDimensions'),
      value: cargoItem[prop]
    }
  }

  render () {
    const {
      ShipmentDetails,
      cargoItem,
      cargoItemTypes,
      i,
      onChangeCargoUnitCheckbox,
      onChangeCargoUnitInput,
      onDeleteUnit,
      onSelectColliType,
      scope,
      t,
      theme,
      toggleStackable,
      uniqKey
    } = this.props
    const availableCargoItemTypes = getAvailableCargoItemTypes(cargoItemTypes)
    const selectedColliType = getSelectedColliType(
      cargoItemTypes, cargoItem.cargoItemTypeId
    )

    const sharedPropsCheckbox = {
      i,
      theme,
      cargoItem
    }

    return (
      <CargoUnitBox onChangeCargoUnitInput={onChangeCargoUnitInput} cargoUnit={cargoItem} i={i} onDeleteUnit={onDeleteUnit} unqiKey={uniqKey}>
        <div style={{ position: 'relative' }}>
          <div
            className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.padding_section}`}
            style={{ marginBottom: '20px' }}
          >
            <CargoUnitNumberInput
              image={this.getImage('length')}
              labelText={t('common:length')}
              maxDimensionsErrorText={t('errors:maxLength')}
              unit="cm"
              {...this.getSharedProps('dimensionX')}
            />

            <CargoUnitNumberInput
              image={this.getImage('width')}
              labelText={t('common:width')}
              maxDimensionsErrorText={t('errors:maxWidth')}
              unit="cm"
              {...this.getSharedProps('dimensionY')}
            />

            <CargoUnitNumberInput
              image={this.getImage('height')}
              labelText={t('common:height')}
              maxDimensionsErrorText={t('errors:maxHeight')}
              unit="cm"
              {...this.getSharedProps('dimensionZ')}
            />

            <CargoUnitNumberInput
              image={<img data-for={uuid.v4()} data-tip={t('common:grossWeight')} src={kg} alt="weight" border="0" />}
              labelText={t('common:grossWeight')}
              maxDimensionsErrorText={t('errors:maxWeight')}
              tooltip={<Tooltip color={theme.colors.primary} icon="fa-info-circle" text="payload_in_kg" />}
              unit="kg"
              {...this.getSharedProps('payloadInKg')}
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
                  inputProps={{ name: `${i}-colliType` }}
                  name={`${i}-colliType`}
                  value={selectedColliType}
                  options={availableCargoItemTypes}
                  onChange={onSelectColliType}
                />
              </div>
            </div>

            <CheckboxWrapper
              disabled={!scope.dangerous_goods}
              onChange={onChangeCargoUnitCheckbox}
              prop="dangerousGoods"
              labelText={t('common:dangerousGoods')}
              onWrapperClick={scope.dangerous_goods ? '' : () => toggleModal('noDangerousGoods')}
              {...sharedPropsCheckbox}
            />
            <CheckboxWrapper
              disabled={!scope.non_stackable_goods}
              onChange={toggleStackable}
              prop="stackable"
              labelText={t('common:nonStackable')}
              checkedTransform={x => !x}
              {...sharedPropsCheckbox}
            />
          </div>
        </div>
        <div className={`${styles.cargo_item_info} flex-100'`}>
          <ChargableProperties
            availableMots={ShipmentDetails.availableMots}
            cargoItem={cargoItem}
            maxDimensions={this.getMaxDimensionsToApply()}
            scope={scope}
          />
        </div>
      </CargoUnitBox>
    )
  }
}

export default withNamespaces('common')(CargoItem)
