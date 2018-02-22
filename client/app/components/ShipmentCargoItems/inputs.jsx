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
 * @param { bool } showAlertModal
 * @param { bool } nextStageAttempt
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
  showAlertModal,
  nextStageAttempt,
  scope
) {
  const { handleDelta } = this.props
  const placeholderInput = (
    <input
      className="flex-80"
      type="number"
    />
  )
  const inputs = {}
  inputs.colliType = (
    <div className="layout-row flex-50 layout-wrap layout-align-start-center" >
      <div style={{ width: '97.75%' }}>
        <p className={`${styles.input_label} flex-100`}> Colli Type </p>
        <NamedSelect
          placeholder=""
          className={styles.select_100}
          name={`${i}-colliType`}
          value={cargoItemTypes[i]}
          options={availableCargoItemTypes}
          onChange={this.handleCargoItemType}
        />
      </div>
    </div>
  )
  inputs.grossWeight = (
    <div className="layout-row flex-25 layout-wrap layout-align-start-center" >
      <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
        <p className={`${styles.input_label} flex-none`}> Gross Weight </p>
        <Tooltip theme={theme} icon="fa-info-circle" text="payload_in_kg" />
      </div>
      <div className={`flex-95 layout-row ${styles.input_box}`}>
        {
          cargoItem ? (
            <ValidatedInput
              wrapperClassName="flex-80"
              name={`${i}-payload_in_kg`}
              value={cargoItem.payload_in_kg}
              type="number"
              onChange={handleDelta}
              firstRenderInputs={firstRenderInputs}
              setFirstRenderInputs={this.setFirstRenderInputs}
              nextStageAttempt={nextStageAttempt}
              validations={{
                nonNegative: (values, value) => value > 0
              }}
              validationErrors={{
                nonNegative: 'Must be greater than 0',
                isDefaultRequiredValue: 'Must be greater than 0'
              }}
              required
            />
          ) : placeholderInput
        }
        <div className="flex-20 layout-row layout-align-center-center">
          kg
        </div>
      </div>
    </div>
  )

  const volume =
    cargoItem &&
    cargoItem.dimension_x * cargoItem.dimension_y * cargoItem.dimension_z / 100 ** 3
  function chargeableWeight (mot) {
    const effectiveKgPerCubicMeter = {
      air: 167,
      rail: 550,
      ocean: 1000
    }
    return Math.max(volume * effectiveKgPerCubicMeter[mot], cargoItem.payload_in_kg)
  }
  function chargeableWeightElemJSX (mot) {
    return (
      <div className="flex-33 layout-row">
        { switchIcon(mot) }
        <p className={`${styles.chargeable_weight_value}`}>
          { cargoItem && chargeableWeight(mot) } kg
        </p>
      </div>
    )
  }
  inputs.chargeableWeight = (
    <div className={
      `${styles.chargeable_weight} layout-row flex-40 ` +
      'layout-wrap layout-align-start-center'
    }
    >
      <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
        <p className={`${styles.input_label} flex-none`}> Chargeable Weight </p>
      </div>
      <div className={
        `${styles.chargeable_weight_values} flex-95 ` +
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
      <p className={`${styles.input_label} flex-100`}> Height </p>
      <div className={`flex-95 layout-row ${styles.input_box}`}>
        {
          cargoItem ? (
            <ValidatedInput
              wrapperClassName="flex-80"
              name={`${i}-dimension_z`}
              value={cargoItem.dimension_z}
              type="number"
              min="0"
              step="any"
              onChange={handleDelta}
              firstRenderInputs={firstRenderInputs}
              setFirstRenderInputs={this.setFirstRenderInputs}
              nextStageAttempt={nextStageAttempt}
              validations={{
                nonNegative: (values, value) => value > 0,
                maxDimention: (values, value) => value < 1000
              }}
              validationErrors={{
                isDefaultRequiredValue: 'Must be greater than 0',
                nonNegative: 'Must be greater than 0',
                maxDimention: 'Maximum height is 1000'
              }}
              required
            />
          ) : placeholderInput
        }
        <div className="flex-20 layout-row layout-align-center-center">
          cm
        </div>
      </div>
    </div>
  )
  inputs.length = (
    <div className="layout-row flex layout-wrap layout-align-start-center" >
      <p className={`${styles.input_label} flex-100`}> Length </p>
      <ReactTooltip />
      <div
        className={`flex-95 layout-row ${styles.input_box}`}
        data-tip={
          cargoItem && !!cargoItemTypes[i].dimension_x ? (
            'Length is automatically set by \'Collie Type\''
          ) : ''
        }
      >
        {
          cargoItem ? (
            <ValidatedInput
              wrapperClassName="flex-80"
              name={`${i}-dimension_x`}
              value={cargoItem.dimension_x}
              type="number"
              min="0"
              step="any"
              onChange={handleDelta}
              firstRenderInputs={firstRenderInputs}
              setFirstRenderInputs={this.setFirstRenderInputs}
              nextStageAttempt={nextStageAttempt}
              validations={{
                nonNegative: (values, value) => value > 0,
                maxDimention: (values, value) => value < 1000
              }}
              validationErrors={{
                isDefaultRequiredValue: 'Must be greater than 0',
                nonNegative: 'Must be greater than 0',
                maxDimention: 'Maximum length is 1000'
              }}
              required
              disabled={!!cargoItemTypes[i].dimension_x}
            />
          ) : placeholderInput
        }
        <div className="flex-20 layout-row layout-align-center-center">
          cm
        </div>
      </div>
    </div>
  )
  inputs.width = (
    <div className="layout-row flex layout-wrap layout-align-start-center" >
      <p className={`${styles.input_label} flex-100`}> Width </p>
      <ReactTooltip />
      <div
        className={`flex-95 layout-row ${styles.input_box}`}
        data-tip={
          cargoItem && !!cargoItemTypes[i].dimension_y ? (
            'Width is automatically set by \'Collie Type\''
          ) : ''
        }
      >
        {
          cargoItem ? (
            <ValidatedInput
              wrapperClassName="flex-80"
              name={`${i}-dimension_y`}
              value={cargoItem.dimension_y}
              type="number"
              min="0"
              step="any"
              onChange={handleDelta}
              firstRenderInputs={firstRenderInputs}
              setFirstRenderInputs={this.setFirstRenderInputs}
              nextStageAttempt={nextStageAttempt}
              validations={{
                nonNegative: (values, value) => value > 0,
                maxDimention: (values, value) => value < 1000
              }}
              validationErrors={{
                isDefaultRequiredValue: 'Must be greater than 0',
                nonNegative: 'Must be greater than 0',
                maxDimention: 'Maximum width is 1000'
              }}
              disabled={!!cargoItemTypes[i].dimension_y}
              required
            />
          ) : placeholderInput
        }
        <div className="flex-20 layout-row layout-align-center-center">
          cm
        </div>
      </div>
    </div>
  )
  inputs.volume = (
    <div className="layout-row flex layout-wrap layout-align-start-center" >
      <p className={`${styles.input_label} flex-100`}> Volume </p>
      <ReactTooltip />
      <div
        className={`flex-95 layout-row ${styles.input_box}`}
        data-tip={'Volume is automatically set by \'Length\', \'Height\', and \'Width\''}
      >
        {
          cargoItem ? (
            <ValidatedInput
              wrapperClassName="flex-80"
              name={`${i}-volume`}
              value={
                cargoItem.dimension_x * cargoItem.dimension_y * cargoItem.dimension_z / 100 ** 3
              }
              type="number"
              min="0"
              step="any"
              onChange={handleDelta}
              firstRenderInputs={firstRenderInputs}
              setFirstRenderInputs={this.setFirstRenderInputs}
              nextStageAttempt={nextStageAttempt}
              disabled
            />
          ) : placeholderInput
        }
        <div className="flex-20 layout-row layout-align-center-center">
          m <sup style={{ marginLeft: '1px', fontSize: '10px', height: '17px' }}>3</sup>
        </div>
      </div>
    </div>
  )

  inputs.quantity = (
    <div className="layout-row flex layout-wrap layout-align-start-center" >
      <p className={`${styles.input_label} flex-100`}> No. of Cargo Items </p>
      <NamedSelect
        placeholder={cargoItem ? cargoItem.quantity : ''}
        className="flex-95"
        name={`${i}-quantity`}
        value={cargoItem ? cargoItem.quantity : ''}
        options={cargoItem ? numberOptions : ''}
        onChange={this.handleCargoItemQ}
      />
    </div>
  )
  inputs.dangerousGoods = (
    <div
      className="layout-row flex layout-wrap layout-align-start-center"
    >
      <div className="layout-row flex-100 layout-wrap layout-align-start-center">
        <p className={`${styles.input_label} flex-none`}> Dangerous Goods </p>
        <Tooltip theme={theme} icon="fa-info-circle" text="dangerous_goods" />
      </div>
      <Checkbox
        name={`${i}-dangerous_goods`}
        onChange={() => this.toggleDangerousGoods(i)}
        checked={cargoItem ? cargoItem.dangerousGoods : false}
        theme={theme}
        size="34px"
        disabled={!scope.dangerous_goods}
        onClick={scope.dangerous_goods ? '' : showAlertModal}
      />
    </div>
  )
  return inputs
}
