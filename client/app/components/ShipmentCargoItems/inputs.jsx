import React from 'react'
import ReactTooltip from 'react-tooltip'
import { ValidatedInput } from '../ValidatedInput/ValidatedInput'
import { Checkbox } from '../Checkbox/Checkbox'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import { Tooltip } from '../Tooltip/Tooltip'
import { switchIcon } from '../../helpers'
import styles from './ShipmentCargoItems.scss'

/**
 * getInput generates the JSX for each of the inputs
 * of the form in ShipmentCargoItem.js.
 *
 * This function is implemented to run in the context of
 * the render() function in ShipmentCargoItem.js
 *
 * @param { object } cargoItem
 * @param { number } i
 * @param { object } theme
 * @param { object } scope
 * @param { array } cargoItemTypes
 * @param { array } availableCargoItemTypes
 * @param { array } numberOptions
 * @param { bool } firstRenderInputs
 * @param { func } toggleModal
 * @param { bool } nextStageAttempt
 * @param { object } scope
 * @param { object } maxDimentions
 *
 * @returns { object } JSX for each input
 */
export default function getInputs (
  cargoItem,
  i,
  theme,
  cargoItemTypes,
  availableCargoItemTypes,
  numberOptions,
  firstRenderInputs,
  toggleModal,
  nextStageAttempt,
  scope,
  maxDimentions
) {
  const { handleDelta } = this.props
  const placeholderInput = (
    <input
      className="flex-80"
      type="number"
    />
  )
  const inputs = {}
  const showColliTypeErrors = !firstRenderInputs && nextStageAttempt && !cargoItemTypes[i]

  inputs.colliType = (
    <div className="layout-row flex-40 layout-wrap layout-align-start-center colli_type" >
      <div style={{ width: '95%' }}>
        <NamedSelect
          placeholder="Select your colli type"
          className={styles.select_100}
          showErrors={showColliTypeErrors}
          name={`${i}-colliType`}
          value={cargoItemTypes[i] && cargoItemTypes[i].label && cargoItemTypes[i]}
          options={availableCargoItemTypes}
          onChange={this.handleCargoItemType}
        />
      </div>
    </div>
  )
  inputs.grossWeight = (
    <div className="layout-row flex-30 layout-wrap layout-align-start-center" >
      <div className={`flex-85 layout-row ${styles.input_box}`}>
        <div className="flex-40 layout-row layout-align-center-center">
          Weight
        </div>
        {
          cargoItem ? (
            <ValidatedInput
              wrapperClassName="flex-60"
              name={`${i}-payload_in_kg`}
              value={cargoItem.payload_in_kg}
              type="number"
              onChange={handleDelta}
              firstRenderInputs={firstRenderInputs}
              setFirstRenderInputs={this.setFirstRenderInputs}
              nextStageAttempt={nextStageAttempt}
              errorStyles={{
                fontSize: '10px',
                bottom: '-14px'
              }}
              validations={{
                nonNegative: (values, value) => value > 0,
                maxDimention: (values, value) => value < maxDimentions.payloadInKg
              }}
              validationErrors={{
                isDefaultRequiredValue: 'Must be greater than 0',
                nonNegative: 'Must be greater than 0',
                maxDimention: `Maximum height is ${maxDimentions.payloadInKg}`
              }}
              required
            />
          ) : placeholderInput
        }
        <div className="flex-20 layout-row layout-align-center-center">
          kg
        </div>
      </div>
      <Tooltip theme={theme} icon="fa-info-circle" text="payload_in_kg" />
    </div>
  )

  const volume =
    cargoItem &&
    cargoItem.dimension_x * cargoItem.dimension_y * cargoItem.dimension_z / 100 ** 3

  function calcQuantityValue (value) {
    console.log(cargoItem)
    if (!cargoItem) {
      return value
    }
    return value * cargoItem.quantity
  }

  inputs.volume = (
    <div className="flex-30 layout-row layout-wrap layout-align-center-center">
      <div className="layout-row flex-40 layout-align-center" >
        <p className={`${styles.input_label} flex-none`}> Volume: </p>
      </div>

      <div className="flex">
        <p className={styles.input_label}>
          { calcQuantityValue(volume) }
          <span>m</span>
          <sup style={{ marginLeft: '1px', fontSize: '10px', height: '17px' }}>3</sup>
        </p>
      </div>
    </div>
  )

  inputs.total = (
    <div className={`${styles.total} flex-10 layout-row layout-wrap layout-align-center-center`}>
      <div className="layout-row flex-40 layout-align-center" >
        <p className={`${styles.input_label} flex-none`}> Total: </p>
      </div>
    </div>
  )

  function chargeableWeight (mot) {
    const effectiveKgPerCubicMeter = {
      air: 167,
      rail: 550,
      ocean: 1000
    }
    return Math.max(volume * effectiveKgPerCubicMeter[mot], cargoItem.payload_in_kg).toFixed(1)
  }
  function chargeableWeightElemJSX (mot) {
    return (
      <div className="flex-33 layout-row">
        { switchIcon(mot) }
        <p className={`${styles.chargeable_weight_value}`}>
          { cargoItem && chargeableWeight(mot)
            ? calcQuantityValue(chargeableWeight(mot))
            : cargoItem && chargeableWeight(mot) } kg
        </p>
      </div>
    )
  }
  inputs.chargeableWeight = (
    <div className={
      `${styles.chargeable_weight} layout-row flex-60 ` +
      'layout-wrap layout-align-end-center'
    }
    >
      <div className="layout-row flex-35 layout-wrap layout-align-start-center" >
        <p className={`${styles.input_label} flex-none`}> Chargeable Weight: </p>
      </div>
      <div className={
        `${styles.chargeable_weight_values} flex ` +
        'layout-row layout-align-start-center'
      }
      >
        {
          Object.keys(scope.modes_of_transport).map(mot => (
            scope.modes_of_transport[mot].cargo_item ? chargeableWeightElemJSX(mot) : ''
          ))
        }
      </div>
    </div>
  )
  inputs.height = (
    <div className="layout-row flex layout-wrap layout-align-start-center" >
      <div className={`flex-90 layout-row ${styles.input_box}`}>
        <div className="flex-20 layout-row layout-align-center-center">
          H
        </div>
        {
          cargoItem ? (
            <ValidatedInput
              wrapperClassName="flex-55"
              name={`${i}-dimension_z`}
              value={cargoItem.dimension_z}
              type="number"
              min="0"
              step="any"
              onChange={handleDelta}
              firstRenderInputs={firstRenderInputs}
              setFirstRenderInputs={this.setFirstRenderInputs}
              nextStageAttempt={nextStageAttempt}
              errorStyles={{
                fontSize: '10px',
                bottom: '-14px'
              }}
              validations={{
                nonNegative: (values, value) => value > 0,
                maxDimention: (values, value) => value < maxDimentions.dimensionZ
              }}
              validationErrors={{
                isDefaultRequiredValue: 'Must be greater than 0',
                nonNegative: 'Must be greater than 0',
                maxDimention: `Maximum height is ${maxDimentions.dimensionZ}`
              }}
              required
            />
          ) : placeholderInput
        }
        <div className="flex-25 layout-row layout-align-center-center">
          cm
        </div>
      </div>
    </div>
  )
  inputs.length = (
    <div className="layout-row flex layout-wrap layout-align-start-center" >
      <ReactTooltip effect="solid" />
      <div
        className={`flex-90 layout-row ${styles.input_box}`}
        data-tip={
          cargoItem && cargoItemTypes[i] && !!cargoItemTypes[i].dimension_x ? (
            'Length is automatically set by \'Collie Type\''
          ) : ''
        }
      >
        <div className="flex-20 layout-row layout-align-center-center">
          L
        </div>

        {
          cargoItem ? (
            <ValidatedInput
              wrapperClassName="flex-55"
              name={`${i}-dimension_x`}
              value={cargoItem.dimension_x}
              type="number"
              min="0"
              step="any"
              onChange={handleDelta}
              firstRenderInputs={firstRenderInputs}
              setFirstRenderInputs={this.setFirstRenderInputs}
              nextStageAttempt={nextStageAttempt}
              errorStyles={{
                fontSize: '10px',
                bottom: '-14px'
              }}
              validations={{
                nonNegative: (values, value) => value > 0,
                maxDimention: (values, value) => value < maxDimentions.dimensionX
              }}
              validationErrors={{
                isDefaultRequiredValue: 'Must be greater than 0',
                nonNegative: 'Must be greater than 0',
                maxDimention: `Maximum height is ${maxDimentions.dimensionX}`
              }}
              required
              disabled={cargoItemTypes[i] && !!cargoItemTypes[i].dimension_x}
            />
          ) : placeholderInput
        }
        <div className="flex-25 layout-row layout-align-center-center">
          cm
        </div>
      </div>
    </div>
  )
  inputs.width = (
    <div className="layout-row flex layout-wrap layout-align-start-center" >
      <ReactTooltip effect="solid" />
      <div
        className={`flex-90 layout-row ${styles.input_box}`}
        data-tip={
          cargoItem && cargoItemTypes[i] && !!cargoItemTypes[i].dimension_y ? (
            'Width is automatically set by \'Colli Type\''
          ) : ''
        }
      >
        <div className="flex-20 layout-row layout-align-center-center">
          W
        </div>
        {
          cargoItem ? (
            <ValidatedInput
              wrapperClassName="flex-55"
              name={`${i}-dimension_y`}
              value={cargoItem.dimension_y}
              type="number"
              min="0"
              step="any"
              onChange={handleDelta}
              firstRenderInputs={firstRenderInputs}
              setFirstRenderInputs={this.setFirstRenderInputs}
              nextStageAttempt={nextStageAttempt}
              errorStyles={{
                fontSize: '10px',
                bottom: '-14px'
              }}
              validations={{
                nonNegative: (values, value) => value > 0,
                maxDimention: (values, value) => value < maxDimentions.dimensionY
              }}
              validationErrors={{
                isDefaultRequiredValue: 'Must be greater than 0',
                nonNegative: 'Must be greater than 0',
                maxDimention: `Maximum height is ${maxDimentions.dimensionY}`
              }}
              disabled={cargoItemTypes[i] && !!cargoItemTypes[i].dimension_y}
              required
            />
          ) : placeholderInput
        }
        <div className="flex-25 layout-row layout-align-center-center">
          cm
        </div>
      </div>
    </div>
  )
  inputs.dangerousGoods = (
    <div
      className="layout-row flex layout-wrap layout-align-start-center"
    >
      <div className="layout-row flex-75 layout-wrap layout-align-start-center">
        <p className={`${styles.input_label} flex-none`}> Dangerous Goods </p>
        <Tooltip theme={theme} icon="fa-info-circle" text="dangerous_goods" />
      </div>
      <Checkbox
        name={`${i}-dangerous_goods`}
        onChange={(checked, e) => this.toggleCheckbox(checked, e)}
        checked={cargoItem ? cargoItem.dangerous_goods : false}
        theme={theme}
        size="20px"
        disabled={!scope.dangerous_goods}
        onClick={scope.dangerous_goods ? '' : () => toggleModal('noDangerousGoods')}
      />
    </div>
  )
  inputs.nonStackable = (
    <div
      className="layout-row flex layout-wrap layout-align-start-center"
    >
      <div className="layout-row flex-65 layout-wrap layout-align-start-center">
        <p className={`${styles.input_label} flex-none`}> Non Stackable </p>
        <Tooltip theme={theme} icon="fa-info-circle" text="non_stackable" />
      </div>
      <Checkbox
        name={`${i}-stackable`}
        onChange={(checked, e) => this.toggleCheckbox(!checked, e)}
        checked={cargoItem ? !cargoItem.stackable : false}
        theme={theme}
        size="20px"
        disabled={false}
      />
    </div>
  )
  return inputs
}
