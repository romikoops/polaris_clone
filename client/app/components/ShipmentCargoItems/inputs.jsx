import React from 'react'
import ReactTooltip from 'react-tooltip'
import { ValidatedInput } from '../ValidatedInput/ValidatedInput'
import { Checkbox } from '../Checkbox/Checkbox'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import { Tooltip } from '../Tooltip/Tooltip'
import { switchIcon, chargeableWeight, volume } from '../../helpers'
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
 * @param { object } maxDimensions
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
  maxDimensions,
  availableMotsForRoute
) {
  const { handleDelta } = this.props
  const placeholderInput = (
    <input
      className="flex-80"
      type="number"
    />
  )
  const inputs = {}
  const showColliTypeErrors =
    !firstRenderInputs && nextStageAttempt &&
    (!cargoItemTypes[i] || !cargoItemTypes[i].label)

  const maxDimensionsKey = availableMotsForRoute.some(mot => mot !== 'air') || availableMotsForRoute.length === 0
    ? 'general' : 'air'
  const maxDimensionsToApply = maxDimensions[maxDimensionsKey]

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
                maxDimension: (values, value) => value <= +maxDimensionsToApply.payloadInKg
              }}
              validationErrors={{
                isDefaultRequiredValue: 'Must be greater than 0',
                nonNegative: 'Must be greater than 0',
                maxDimension: `Maximum weight is ${maxDimensionsToApply.payloadInKg}`
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

  inputs.volume = (
    <div className="flex-30 layout-row layout-wrap layout-align-center-center">
      <div className="layout-row flex-40 layout-align-center" >
        <p className={`${styles.input_label} flex-none`}> Volume: </p>
      </div>

      <div className="flex">
        <p className={styles.input_label}>
          { volume(cargoItem) }
          <span>m</span>
          <sup style={{ marginLeft: '1px', fontSize: '10px', height: '17px' }}>3</sup>
        </p>
      </div>
    </div>
  )

  inputs.total = (
    <div className={`${styles.total} flex-10 layout-row layout-wrap layout-align-center-stretch`}>
      <div className={`${styles.cargo_item_box} layout-row flex-100 layout-align-center-center`}>
        <p className={`${styles.input_label} flex-none`}> Total: </p>
      </div>
    </div>
  )

  function chargeableWeightElemJSX (mot) {
    return (
      <div className="flex-33 layout-row">
        { switchIcon(mot) }
        <p className={`${styles.chargeable_weight_value}`}>
          { chargeableWeight(cargoItem, mot) } kg
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

  let heightDataTip = ''
  if (
    cargoItem &&
    maxDimensions.air &&
    +cargoItem.dimension_z < +maxDimensionsToApply.dimensionZ &&
    +cargoItem.dimension_z > +maxDimensions.air.dimensionZ
  ) {
    heightDataTip = `
      Please note that the maximum height for items in
      Air Freight shipments is ${maxDimensions.air.dimensionZ} cm
    `
  }

  let heightRef
  inputs.height = (
    <div className="layout-row flex layout-wrap layout-align-start-center" >
      <div
        className={`flex-90 layout-row ${styles.input_box}`}
        data-tip={heightDataTip}
        ref={(div) => { heightRef = div }}
        onBlur={() => ReactTooltip.hide(heightRef)}
      >
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
              onChange={(event, hasError) => handleDelta(event, hasError, heightRef)}
              firstRenderInputs={firstRenderInputs}
              setFirstRenderInputs={this.setFirstRenderInputs}
              nextStageAttempt={nextStageAttempt}
              errorStyles={{
                fontSize: '10px',
                bottom: '-14px'
              }}
              validations={{
                nonNegative: (values, value) => value > 0,
                maxDimension: (values, value) => value <= +maxDimensionsToApply.dimensionZ
              }}
              validationErrors={{
                isDefaultRequiredValue: 'Must be greater than 0',
                nonNegative: 'Must be greater than 0',
                maxDimension: `Maximum height is ${maxDimensionsToApply.dimensionZ}`
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

  let lengthDataTip = ''
  if (cargoItem) {
    if (cargoItemTypes[i] && cargoItemTypes[i].dimension_x) {
      lengthDataTip = 'Length is automatically set by \'Collie Type\''
    } else if (
      maxDimensions.air &&
      +cargoItem.dimension_x < +maxDimensionsToApply.dimensionX &&
      +cargoItem.dimension_x > +maxDimensions.air.dimensionX
    ) {
      lengthDataTip = `
        Please note that the maximum length for items in
        Air Freight shipments is ${maxDimensions.air.dimensionX} cm
      `
    }
  }
  let lengthRef
  inputs.length = (
    <div className="layout-row flex layout-wrap layout-align-start-center" >
      <ReactTooltip effect="solid" />
      <div
        className={`flex-90 layout-row ${styles.input_box}`}
        data-tip={lengthDataTip}
        ref={(div) => { lengthRef = div }}
        onBlur={() => ReactTooltip.hide(lengthRef)}
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
              onChange={(event, hasError) => handleDelta(event, hasError, lengthRef)}
              firstRenderInputs={firstRenderInputs}
              setFirstRenderInputs={this.setFirstRenderInputs}
              nextStageAttempt={nextStageAttempt}
              errorStyles={{
                fontSize: '10px',
                bottom: '-14px'
              }}
              validations={{
                nonNegative: (values, value) => value > 0,
                maxDimension: (values, value) => value <= +maxDimensionsToApply.dimensionX
              }}
              validationErrors={{
                isDefaultRequiredValue: 'Must be greater than 0',
                nonNegative: 'Must be greater than 0',
                maxDimension: `Maximum length is ${maxDimensionsToApply.dimensionX}`
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

  let widthDataTip = ''
  if (cargoItem) {
    if (cargoItemTypes[i] && cargoItemTypes[i].dimension_y) {
      widthDataTip = 'Width is automatically set by \'Collie Type\''
    } else if (
      maxDimensions.air &&
      +cargoItem.dimension_y < +maxDimensionsToApply.dimensionY &&
      +cargoItem.dimension_y > +maxDimensions.air.dimensionY
    ) {
      widthDataTip = `
        Please note that the maximum width for items in
        Air Freight shipments is ${maxDimensions.air.dimensionY} cm
      `
    }
  }

  let widthRef
  inputs.width = (
    <div className="layout-row flex layout-wrap layout-align-start-center" >
      <ReactTooltip effect="solid" />
      <div
        className={`flex-90 layout-row ${styles.input_box}`}
        data-tip={widthDataTip}
        ref={(div) => { widthRef = div }}
        onBlur={() => ReactTooltip.hide(widthRef)}
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
              onChange={(event, hasError) => handleDelta(event, hasError, widthRef)}
              firstRenderInputs={firstRenderInputs}
              setFirstRenderInputs={this.setFirstRenderInputs}
              nextStageAttempt={nextStageAttempt}
              errorStyles={{
                fontSize: '10px',
                bottom: '-14px'
              }}
              validations={{
                nonNegative: (values, value) => value > 0,
                maxDimension: (values, value) => value <= +maxDimensionsToApply.dimensionY
              }}
              validationErrors={{
                isDefaultRequiredValue: 'Must be greater than 0',
                nonNegative: 'Must be greater than 0',
                maxDimension: `Maximum width is ${maxDimensionsToApply.dimensionY}`
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
