import React from 'react'
import { withNamespaces } from 'react-i18next'
import CircleCompletion from '../../../../../CircleCompletion/CircleCompletion'
import LoadingSpinner from '../../../../../LoadingSpinner/LoadingSpinner'
import FormsyInput from '../../../../../Formsy/Input'
import styles from '../index.scss'

function CollapsableFields ({
  target,
  formData,
  onInputBlur,
  truckingAvailable,
  t
}) {
  if (truckingAvailable === 'request') return <LoadingSpinner size="medium" />
  if (truckingAvailable === 'animate_available') {
    return (
      <CircleCompletion
        icon="fa fa-check"
        iconColor="white"
        animated={truckingAvailable}
        size="150px"
        opacity={truckingAvailable ? '1' : '0'}
      />
    )
  }

  return (
    <div className="flex-100">
      <div className={`flex-100 layout-row ${styles.form_title}`}>
        <h5>{target === 'origin' ? t('shipment:enterPickUp') : t('shipment:enterDelivery')}</h5>
      </div>

      <FormsyInput
        wrapperClassName="flex-100 layout-row layout-align-center"
        placeholder="Street"
        name={`${target}-street`}
        value={formData.street}
        onBlur={onInputBlur}
      />
      <FormsyInput
        wrapperClassName="flex-100 layout-row layout-align-center"
        placeholder="Number"
        name={`${target}-number`}
        value={formData.number}
        onBlur={onInputBlur}
      />
      <FormsyInput
        wrapperClassName="flex-100 layout-row layout-align-center"
        placeholder="ZIP Code"
        name={`${target}-zipCode`}
        value={formData.zipCode}
        onBlur={onInputBlur}
      />
      <FormsyInput
        wrapperClassName="flex-100 layout-row layout-align-center"
        placeholder="City"
        name={`${target}-city`}
        value={formData.city}
        onBlur={onInputBlur}
      />
      <FormsyInput
        wrapperClassName="flex-100 layout-row layout-align-center"
        placeholder="Country"
        name={`${target}-country`}
        value={formData.country}
        onBlur={onInputBlur}
      />
      <div className="flex-100 pointy layout-row layout-align-start-center">
        <div
          className={`${styles.clear_sec} flex-none layout-row layout-align-end-center`}
          onClick={console.log}
        >
          <i className="fa fa-times flex-none" />
          <p className="offset-5 flex-none" style={{ paddingRight: '10px' }}>
            {t('common:clear')}
          </p>
        </div>
      </div>
    </div>
  )
}

export default withNamespaces(['shipment', 'common'])(CollapsableFields)
