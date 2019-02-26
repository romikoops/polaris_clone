import React from 'react'
import { withNamespaces } from 'react-i18next'
import FormsyInput from '../../../../../Formsy/Input'
import styles from './index.scss'

function QuantityInput ({
  cargoItem, i, onChange, t
}) {
  return (
    <div className="flex-100 layout-row">
      <div className="flex-100 layout-row layout-align-center">
        <div className={`${styles.quantity} layout-row flex-100 layout-wrap layout-align-start-center`}>
          <p
            className="flex-100 layout-row layout-align-center-start"
            style={{ marginBottom: '25px' }}
          >
            {t('common:quantity')}
          </p>
          <div className="flex-100 layout-row">
            <FormsyInput
              wrapperClassName="flex-100"
              name={`${i}-quantity`}
              value={cargoItem ? cargoItem.quantity : ''}
              type="number"
              min="1"
              step="any"
              onChange={onChange}
              errorMessageStyles={{
                fontSize: '10px',
                top: '-14px',
                bottom: 'unset'
              }}
              validations={{ nonNegative: (values, value) => value > 0 }}
              validationErrors={{ nonNegative: t('errors:nonNegative') }}
            />
          </div>
          <hr className="flex-35" />
        </div>
      </div>
    </div>
  )
}

QuantityInput.defaultProps = {
  cargoItem: null,
  i: -1
}

export default withNamespaces(['common', 'errors'])(QuantityInput)
