import React from 'react'
import { withNamespaces } from 'react-i18next'
import uuid from 'uuid'
import { get } from 'lodash'
import CargoUnitBox from '../CargoUnit/Box'
import styles from './index.scss'
import CargoUnitNumberInput from '../CargoUnit/NumberInput'
import Tooltip from '../../../../Tooltip/Tooltip'
import FormsySelect from '../../../../Formsy/Select'
import kg from '../../../../../assets/images/cargo/kg.png'
import length from '../../../../../assets/images/cargo/length.png'
import width from '../../../../../assets/images/cargo/width.png'
import height from '../../../../../assets/images/cargo/height.png'
import calcMaxDimensionsToApply from '../../../../../helpers/calcMaxDimensionsToApply'

import CheckboxWrapper from './checkboxWrapper'
import ChargeableProperties from './ChargeableProperties'

const imageSources = {
  length,
  width,
  height
}

class CargoItem extends React.PureComponent {
  static getSelectedColliType (availableCargoItemTypes, currentTypeId) {
    // If the user delete its selection, then the value is `undefined`
    if (!currentTypeId) return
    const [currentCargoItemType] = availableCargoItemTypes.filter(
      cargoType => cargoType.id === currentTypeId
    )
    const { description } = currentCargoItemType

    return { label: description, value: description }
  }

  static getAvailableCargoItemTypes (cargoItemTypes) {
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

  constructor (props) {
    super(props)
    this.getSharedProps = this.getSharedProps.bind(this)
    this.getImage = this.getImage.bind(this)
    this.getMaxDimensionsToApply = this.getMaxDimensionsToApply.bind(this)

    const { scope } = props

    this.allMots = Object.keys(scope.modes_of_transport).filter(mot => (
      scope.modes_of_transport[mot].cargo_item
    ))
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
      cargoItem,
      toggleModal
    } = this.props
    const maxDimension = Number(
      this.getMaxDimensionsToApply()[prop === 'collectiveWeight' ? 'payloadInKg' : prop]
    )

    return {
      cargoItem,
      className: prop === 'payloadInKg' ? 'flex-30 offset-5' : 'flex-20',
      i,
      maxDimension,
      name: `${i}-${prop}`,
      onBlur: onChangeCargoUnitInput,
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
      onChangeCargoUnitSelect,
      scope,
      t,
      theme,
      toggleModal,
      uniqKey,
      totalShipmentErrors
    } = this.props

    const availableCargoItemTypes = CargoItem.getAvailableCargoItemTypes(cargoItemTypes)
    const selectedColliType = CargoItem.getSelectedColliType(
      cargoItemTypes, cargoItem.cargoItemTypeId
    )

    const sharedPropsCheckbox = {
      i,
      theme,
      cargoItem
    }

    return (
      <CargoUnitBox
        cargoUnit={cargoItem}
        i={i}
        onChangeCargoUnitInput={onChangeCargoUnitInput}
        onDeleteUnit={onDeleteUnit}
        unqiKey={uniqKey}
      >
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
              validations={{
                totalShipmentChargeableWeight: () => (
                  totalShipmentErrors.chargeableWeight.type !== 'error'
                )
              }}
              {...this.getSharedProps('dimensionX')}
            />

            <CargoUnitNumberInput
              image={this.getImage('width')}
              labelText={t('common:width')}
              maxDimensionsErrorText={t('errors:maxWidth')}
              unit="cm"
              validations={{
                totalShipmentChargeableWeight: () => (
                  totalShipmentErrors.chargeableWeight.type !== 'error'
                )
              }}
              {...this.getSharedProps('dimensionY')}
            />

            <CargoUnitNumberInput
              image={this.getImage('height')}
              labelText={t('common:height')}
              maxDimensionsErrorText={t('errors:maxHeight')}
              unit="cm"
              validations={{
                totalShipmentChargeableWeight: () => (
                  totalShipmentErrors.chargeableWeight.type !== 'error'
                )
              }}
              {...this.getSharedProps('dimensionZ')}
            />

            {
              get(scope, ['consolidation', 'cargo', 'frontend'], false)
                ? (
                  <CargoUnitNumberInput
                    validations={{
                      totalShipmentPayloadInKg: () => (
                        totalShipmentErrors.payloadInKg.type !== 'error'
                      ),
                      totalShipmentChargeableWeight: () => (
                        totalShipmentErrors.chargeableWeight.type !== 'error'
                      )
                    }}
                    labelText={t('common:grossWeight')}
                    maxDimensionsErrorText={t('errors:maxWeight')}
                    tooltip={<Tooltip color={theme.colors.primary} icon="fa-info-circle" text="payload_in_kg" />}
                    unit="kg"
                    {...this.getSharedProps('collectiveWeight')}
                  />
                )
                : (
                  <CargoUnitNumberInput
                    validations={{
                      totalShipmentPayloadInKg: () => (
                        totalShipmentErrors.payloadInKg.type !== 'error'
                      ),
                      totalShipmentChargeableWeight: () => (
                        totalShipmentErrors.chargeableWeight.type !== 'error'
                      )
                    }}
                    image={
                      <img data-for={uuid.v4()} data-tip={t('common:grossWeight')} src={kg} alt="weight" border="0" />
                    }
                    labelText={t('common:grossWeightPerItem')}
                    maxDimensionsErrorText={t('errors:maxWeight')}
                    unit="kg"
                    {...this.getSharedProps('payloadInKg')}
                  />
                )
            }

          </div>
          <div className="flex-100 layout-row" />
          <div
            className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.padding_section}`}
            style={{ margin: '20px 0' }}
          >
            <div className="layout-row flex-40 layout-wrap layout-align-start-center ccb_colli_type">
              <div style={{ width: '95%' }}>
                <FormsySelect
                  placeholder={t('common:selectColliType')}
                  className={styles.select_100}
                  inputProps={{ name: `${i}-colliType` }}
                  name={`${i}-colliType`}
                  value={selectedColliType}
                  options={availableCargoItemTypes}
                  onChange={(option) => { onChangeCargoUnitSelect(i, 'cargoItemTypeId', get(option, 'key'), i) }}
                  validationErrors={{ isDefaultRequiredValue: t('common:noBlank') }}
                  required
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
              onChange={(checked, e) => onChangeCargoUnitCheckbox(!checked, e)}
              prop="stackable"
              labelText={t('common:nonStackable')}
              checkedTransform={x => !x}
              {...sharedPropsCheckbox}
            />
          </div>
        </div>
        <div className={`${styles.cargo_item_info} flex-100'`}>
          <ChargeableProperties
            availableMots={ShipmentDetails.availableMots}
            allMots={this.allMots}
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
