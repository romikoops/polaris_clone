import React from 'react'
import { withNamespaces } from 'react-i18next'
import FormsyInput from '../../../../../FormsyInput/FormsyInput'
import styles from './index.scss'

function CargoUnitNumberInput ({
  value, name, onChange, onExcessDimensionsRequest,
  maxDimension, maxDimensionsErrorText, labelText,
  className, tooltipId, unit, image, tooltip, t
}) {
  const errorStyles = {
    whiteSpace: 'normal',
    maxWidth: '200px',
    fontSize: '10px',
    top: '32px'
  }

  return (
    <div className={`layout-row layout-wrap layout-align-start-center ${styles.cargo_unit_number_input} ${className}`}>
      <h4>{labelText}</h4>
      <div className={`flex-100 layout-row layout-align-space-between ${styles.input_box}`}>
        {image}
        {tooltip}

        <FormsyInput
          wrapperClassName="flex-75"
          name={name}
          value={value}
          type="number"
          placeholder="0"
          onChange={onChange}
          errorStyles={errorStyles}
          validations={{
            nonNegative: (values, _value) => _value > 0,
            maxDimension: (values, _value) => _value <= +maxDimension
          }}
          validationErrors={{
            isDefaultRequiredValue: t('common:greaterZero'),
            nonNegative: t('common:greaterZero'),
            maxDimension: (
              <p>
                {`${maxDimensionsErrorText} ${maxDimension}`}
                <br />
                <span className="emulate_link blue_link" onClick={onExcessDimensionsRequest}>
                  {t('cargo:excessDimensionsRequest')}
                </span>
              </p>
            )
          }}
          required
        />
        <div className={`layout-row layout-align-center-center ${styles.unit}`}>
          {unit}
        </div>
      </div>

    </div>
  )
}

export default withNamespaces('common')(CargoUnitNumberInput)
