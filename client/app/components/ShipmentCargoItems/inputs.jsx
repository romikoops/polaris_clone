import React from 'react'
import ReactTooltip from 'react-tooltip'
import { v4 } from 'uuid'
import ValidatedInput from '../ValidatedInput/ValidatedInput'
import Checkbox from '../Checkbox/Checkbox'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import { Tooltip } from '../Tooltip/Tooltip'
import kg from '../../assets/images/cargo/kg.png'
import width from '../../assets/images/cargo/width.png'
import length from '../../assets/images/cargo/length.png'
import height from '../../assets/images/cargo/height.png'
import {
  switchIcon,
  chargeableWeight,
  volume,
  numberSpacing,
  calcMaxDimensionsToApply
} from '../../helpers'
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
  const { handleDelta, t } = this.props
  const placeholderInput = (
    <input
      className="flex-80"
      type="number"
    />
  )
  const tooltipId = v4()
  const inputs = {}
  const showColliTypeErrors =
    !firstRenderInputs && nextStageAttempt &&
    (!cargoItemTypes[i] || !cargoItemTypes[i].label)

  const maxDimensionsToApply = calcMaxDimensionsToApply(availableMotsForRoute, maxDimensions)

  inputs.colliType = (
    <div className="layout-row flex-40 layout-wrap layout-align-start-center colli_type" >
      <div style={{ width: '95%' }}>
        <NamedSelect
          placeholder={t('common:selectColliType')}
          className={styles.select_100}
          showErrors={showColliTypeErrors}
          inputProps={{ name: `${i}-colliType` }}
          name={`${i}-colliType`}
          value={cargoItemTypes[i] && cargoItemTypes[i].label && cargoItemTypes[i]}
          options={availableCargoItemTypes}
          onChange={this.handleCargoItemType}
        />
      </div>
    </div>
  )

  inputs.grossWeight = (
    <div className={`layout-row flex-30 layout-wrap layout-align-start-center ${styles.input_weight}`}>
      <h4>{t('common:Gross Weight')}</h4>
      <div className={`flex-60 layout-row ${styles.input_box}`}>

        <img data-for={tooltipId} data-tip={t('common:grossWeight')} src={kg} alt="weight" border="0" />
        <Tooltip color={theme.colors.primary} icon="fa-info-circle" text="payload_in_kg" />
        {
          cargoItem ? (
            <ValidatedInput
              wrapperClassName="flex-90"
              name={`${i}-payload_in_kg`}
              value={cargoItem.payload_in_kg || ''}
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
                isDefaultRequiredValue: t('common:greaterZero'),
                nonNegative: t('common:greaterZero'),
                maxDimension: `${t('errors:maxWeight')} ${maxDimensionsToApply.payloadInKg}`
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
  inputs.collectiveWeight = (
    <div className="layout-row flex-30 layout-wrap layout-align-start-center" >
      <div className={`flex-85 layout-row ${styles.input_box}`}>
        <div className="flex-40 layout-row layout-align-center-center">
          {t('common:grossWeight')}
        </div>
        {
          cargoItem ? (
            <ValidatedInput
              wrapperClassName="flex-60"
              name={`${i}-collectiveWeight`}
              value={cargoItem.payload_in_kg * cargoItem.quantity || ''}
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
                isDefaultRequiredValue: t('common:greaterZero'),
                nonNegative: t('common:greaterZero'),
                maxDimension: `${t('errors:maxWeight')} ${maxDimensionsToApply.payloadInKg}`
              }}
              required
            />
          ) : placeholderInput
        }
        <div className="flex-20 layout-row layout-align-center-center">
          kg
        </div>
      </div>
      <Tooltip color={theme.colors.primary} icon="fa-info-circle" text="payload_in_kg" />
    </div>
  )

  inputs.volume = (
    <div className="flex-30 layout-row layout-wrap layout-align-end-center">
      <div className="layout-row flex-40 layout-align-center" >
        <p className={`${styles.input_label} flex-none`}>{t('common:volume')}:&nbsp;&nbsp;
          <span className={styles.input_value}>{ numberSpacing(volume(cargoItem), 3) }
          &nbsp;m<sup style={{ marginLeft: '1px', fontSize: '10px', height: '17px' }}>3</sup></span>
        </p>
      </div>
    </div>
  )

  inputs.total = (
    <div className={`${styles.total} flex-15 layout-row layout-wrap layout-align-center-stretch`}>
      <div className={`${styles.cargo_item_box} layout-row flex-100 layout-align-center-center`}>
        <p className={`${styles.input_label} flex-none`}>{t('common:total')}</p>
      </div>
    </div>
  )

  function chargeableWeightElemJSX (mot) {
    if (
      (
        availableMotsForRoute.length > 0 &&
        !availableMotsForRoute.includes(mot)
      ) ||
      (
        cargoItem &&
        maxDimensions[mot] &&
        (
          +cargoItem.dimension_z > +maxDimensions[mot].dimensionZ ||
          +cargoItem.dimension_y > +maxDimensions[mot].dimensionY ||
          chargeableWeight(cargoItem, mot) > +maxDimensions[mot].chargeableWeight
        )
      )
    ) {
      return (
        <div className="flex-30 layout-align-center-center layout-row">
          { switchIcon(mot) }
          <p className={`${styles.chargeable_weight_value} ${styles.input_value}`}>
            {t('common:unavailable')}
          </p>
        </div>
      )
    }

    return (
      <div className="flex-30 layout-align-center-center layout-row">
        { switchIcon(mot) }
        <p className={`${styles.chargeable_weight_value} ${styles.input_value}`}>
          { numberSpacing(chargeableWeight(cargoItem, mot), 1) } kg
        </p>
      </div>
    )
  }
  inputs.chargeableWeight = (
    <div className={
      `${styles.chargeable_weight} layout-row flex ` +
      'layout-wrap layout-align-end-center'
    }
    >
      <div className="layout-row flex-30 layout-wrap layout-align-end-center" >
        <p className={`${styles.input_label} flex-none`}>{t('cargo:chargebleWeight')}: </p>
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
      ${t('cargo:heightDataTip')} ${maxDimensions.air.dimensionZ} cm
    `
  }

  let heightRef
  inputs.height = (
    <div className={`layout-row flex-20 layout-wrap layout-align-start-center ${styles.input_height}`}>
      <h4>{t('common:height')}</h4>
      <div
        className={`flex-90 layout-row ${styles.input_box}`}
        data-tip={heightDataTip}
        ref={(div) => { heightRef = div }}
        data-event="disable"
        onMouseEnter={() => ReactTooltip.show(heightRef)}
        onFocus={() => ReactTooltip.show(heightRef)}
        onBlur={() => ReactTooltip.hide(heightRef)}
      >

        <img data-for={tooltipId} data-tip={t('common:height')} src={height} alt="height" border="0" />
        {
          cargoItem ? (
            <ValidatedInput
              wrapperClassName="flex-60"
              name={`${i}-dimension_z`}
              value={cargoItem.dimension_z || ''}
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
                isDefaultRequiredValue: t('common:greaterZero'),
                nonNegative: t('common:greaterZero'),
                maxDimension: `${t('errors:maxHeight')} ${maxDimensionsToApply.dimensionZ}`
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
      lengthDataTip = t('cargo:lengthDataTipTwo')
    } else if (
      maxDimensions.air &&
      +cargoItem.dimension_x < +maxDimensionsToApply.dimensionX &&
      +cargoItem.dimension_x > +maxDimensions.air.dimensionX
    ) {
      lengthDataTip = `
        ${t('cargo:lengthDataTip')} ${maxDimensions.air.dimensionX} cm
      `
    }
  }
  let lengthRef
  inputs.length = (
    <div className={`layout-row flex-20 layout-wrap layout-align-start-center ${styles.input_length}`}>
      <h4>{t('common:length')}</h4>
      <div
        className={`flex-90 layout-row ${styles.input_box}`}
        data-tip={lengthDataTip}
        ref={(div) => { lengthRef = div }}
        data-event="disable"
        onMouseEnter={() => ReactTooltip.show(lengthRef)}
        onFocus={() => ReactTooltip.show(lengthRef)}
        onBlur={() => ReactTooltip.hide(lengthRef)}
      >

        <img data-for={tooltipId} data-tip={t('common:length')} src={length} alt="length" border="0" />

        {
          cargoItem ? (
            <ValidatedInput
              wrapperClassName="flex-60"
              name={`${i}-dimension_x`}
              value={cargoItem.dimension_x || ''}
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
                isDefaultRequiredValue: t('common:greaterZero'),
                nonNegative: t('common:greaterZero'),
                maxDimension: `${t('errors:maxLength')} ${maxDimensionsToApply.dimensionX}`
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
      widthDataTip = t('cargo:widthDataTipTwo')
    } else if (
      maxDimensions.air &&
      +cargoItem.dimension_y < +maxDimensionsToApply.dimensionY &&
      +cargoItem.dimension_y > +maxDimensions.air.dimensionY
    ) {
      widthDataTip = `
        ${t('cargo:widthDataTip')} ${maxDimensions.air.dimensionY} cm
      `
    }
  }

  let widthRef
  inputs.width = (
    <div className={`layout-row flex-20 layout-wrap layout-align-start-center ${styles.input_width}`}>
      <h4>{t('common:width')}</h4>
      <div
        className={`flex-90 layout-row ${styles.input_box}`}
        ref={(div) => { widthRef = div }}
        data-tip={widthDataTip}
        data-event="disable"
        onMouseEnter={() => ReactTooltip.show(widthRef)}
        onFocus={() => ReactTooltip.show(widthRef)}
        onBlur={() => ReactTooltip.hide(widthRef)}
      >

        <img data-for={tooltipId} data-tip={t('common:width')} src={width} alt="width" border="0" />
        {
          cargoItem ? (
            <ValidatedInput
              wrapperClassName="flex-60"
              name={`${i}-dimension_y`}
              value={cargoItem.dimension_y || ''}
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
                isDefaultRequiredValue: t('common:greaterZero'),
                nonNegative: t('common:greaterZero'),
                maxDimension: `${t('errors:maxWidth')} ${maxDimensionsToApply.dimensionY}`
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
      className={`layout-row flex layout-wrap layout-align-start-center ${styles.cargo_unit_check}`}
    >
      <Checkbox
        name={`${i}-dangerous_goods`}
        onChange={(checked, e) => this.toggleCheckbox(checked, e)}
        checked={cargoItem ? cargoItem.dangerous_goods : false}
        theme={theme}
        size="15px"
        disabled={!scope.dangerous_goods}
        onClick={scope.dangerous_goods ? '' : () => toggleModal('noDangerousGoods')}
      />
      <div className="layout-row flex-75 layout-wrap layout-align-start-center">
        <p className={`${styles.input_label} flex-none`}>{t('common:dangerousGoods')}</p>
        <Tooltip color={theme.colors.primary} icon="fa-info-circle" text="dangerous_goods" />
      </div>
    </div>
  )
  inputs.nonStackable = (
    <div
      className={`layout-row flex layout-wrap layout-align-end-center ${styles.cargo_unit_check}`}
    >
      <Checkbox
        name={`${i}-stackable`}
        onChange={(checked, e) => this.toggleCheckbox(!checked, e)}
        checked={cargoItem ? !cargoItem.stackable : false}
        theme={theme}
        size="15px"
        disabled={!scope.non_stackable_goods}
        onClick={scope.non_stackable_goods ? '' : () => toggleModal('nonStackable')}
      />
      <div className="layout-row flex-65 layout-wrap layout-align-start-center">
        <p className={`${styles.input_label} flex-none`}>{t('common:nonStackable')}</p>
        <Tooltip color={theme.colors.primary} icon="fa-info-circle" text="non_stackable" />
      </div>
    </div>
  )

  return inputs
}
