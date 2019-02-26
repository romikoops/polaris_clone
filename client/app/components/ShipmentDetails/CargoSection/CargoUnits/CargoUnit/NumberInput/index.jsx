import React from 'react'
import { withNamespaces } from 'react-i18next'
import FormsyInput from '../../../../../Formsy/Input'
import styles from './index.scss'
import { chargeableWeight } from '../../../../../../helpers'

const errorStyles = {
  whiteSpace: 'normal',
  maxWidth: '200px',
  fontSize: '10px',
  top: '32px'
}

function CargoUnitNumberInput ({
  value, name, onChange, onBlur, onExcessDimensionsRequest,
  maxDimension, maxDimensionsErrorText, labelText, validations,
  className, unit, image, tooltip, t
}) {
  return (
    <div className={`layout-row layout-wrap layout-align-start-center ${styles.cargo_unit_number_input} ${className}`}>
      <h4>{labelText}</h4>
      <div className={`flex-100 layout-row layout-align-start-end ${styles.input_box}`}>
        {image}
        {tooltip}

        <FormsyInput
          wrapperClassName="flex-75"
          name={name}
          value={value}
          type="number"
          placeholder="0"
          onBlur={onBlur}
          onChange={onChange}
          errorStyles={errorStyles}
          validations={{
            nonNegative: (values, _value) => Number(_value) > 0,
            maxDimension: (values, _value) => Number(_value) <= +maxDimension,
            ...validations
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
CargoUnitNumberInput.defaultProps = {
  className: '',
  image: '',
  maxDimension: 1000,
  onChange: () => {},
  onBlur: () => {},
  tooltip: ''
}
export default withNamespaces('common')(CargoUnitNumberInput)
