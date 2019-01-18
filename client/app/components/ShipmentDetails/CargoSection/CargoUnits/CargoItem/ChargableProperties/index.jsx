import React from 'react'
import styles from './index.scss'
import {
  numberSpacing, volume, weight, switchIcon, chargeableWeight, chargeableVolume
} from '../../../../../../helpers'

function chargeableWeightElemJSX ({
  mot, t, availableMots, cargoItem, maxDimensions
}) {
  if (
    (
      availableMots.length > 0 &&
      !availableMots.includes(mot)
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
      <div className={`flex-none layout-align-center-center layout-row ${styles.single_charge}`}>
        { switchIcon(mot) }
        <p className={`${styles.chargeable_weight_value} ${styles.input_value}`}>
          {t('common:unavailable')}
        </p>
      </div>
    )
  }

  return (
    <div className={`flex-none layout-align-center-center layout-row ${styles.single_charge}`}>
      { switchIcon(mot) }
      <p className={`${styles.chargeable_weight_value} ${styles.input_value}`}>
        {chargeableWeight(cargoItem, mot)}
        <span>&nbsp;kg</span>
      </p>
    </div>
  )
}

function chargeableVolumeElemJSX ({
  mot, t, availableMots, cargoItem, maxDimensions
}) {
  if (
    (
      availableMots.length > 0 &&
      !availableMots.includes(mot)
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
      <div className={`flex-none layout-align-center-center layout-row ${styles.single_charge}`}>
        { switchIcon(mot) }
        <p className={`${styles.chargeable_weight_value} ${styles.input_value}`}>
          {t('common:unavailable')}
        </p>
      </div>
    )
  }

  return (
    <div className={`flex-none layout-align-center-center layout-row ${styles.single_charge}`}>
      { switchIcon(mot) }
      <p className={`${styles.chargeable_weight_value} ${styles.input_value}`}>
        {chargeableVolume(cargoItem, mot)}
        <span>
            &nbsp;m
          <sup style={{ marginLeft: '1px', fontSize: '10px', height: '17px' }}>3</sup>
        </span>
      </p>
    </div>
  )
}

function getChargableProperties ({
  t, cargoItem, scope, maxDimensions, availableMots
}) {
  const sharedProps = {
    t,
    cargoItem,
    availableMots,
    maxDimensions
  }
  const chargeableWeightMots = Object.keys(scope.modes_of_transport).filter(
    mot => scope.modes_of_transport[mot].cargo_item
  )
  const totalVolume = (
    <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${styles.charge_volume}`}>
      <p className={`${styles.input_label} flex-none`}>
        {t('common:total')}
&nbsp;
        {t('common:volume')}
:&nbsp;&nbsp;
        <span className={styles.input_value}>
          {numberSpacing(volume(cargoItem), 3)}
          &nbsp;m
          <sup style={{ marginLeft: '1px', fontSize: '10px', height: '17px' }}>3</sup>
        </span>
      </p>
    </div>
  )
  const totalWeight = (
    <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${styles.charge_volume}`}>
      <p className={`${styles.input_label} flex-none`}>
        {t('common:total')}
        &nbsp;
        {t('common:weight')}
        :&nbsp;&nbsp;
        <span className={styles.input_value}>
          {weight(cargoItem)}
          &nbsp;kg
        </span>
      </p>
    </div>
  )

  const chargeableVolumeElement = (
    <div className={
      `${styles.chargeable_weight} layout-row flex-100 ` +
      'layout-wrap layout-align-start-center'
    }
    >
      <div className="layout-row flex-none layout-wrap layout-align-end-center">
        <p className={`${styles.subchargeable} flex-none`}>
          {`${t('cargo:chargeble')}:`}
        </p>
      </div>
      <div className={
        `${styles.chargeable_weight_values} flex ` +
        'layout-row layout-align-start-center'
      }
      >
        {chargeableWeightMots.map(mot => (
          chargeableVolumeElemJSX({ mot, ...sharedProps })))}
      </div>
    </div>
  )
  const chargeableWeightElement = (
    <div className={
      `${styles.chargeable_weight} layout-row flex-100 ` +
      'layout-wrap layout-align-start-center'
    }
    >
      <div className="layout-row flex-none layout-wrap layout-align-end-center">
        <p className={`${styles.subchargeable} flex-none`}>
          {`${t('cargo:chargeble')}:`}
        </p>
      </div>
      <div className={
        `${styles.chargeable_weight_values} flex ` +
        'layout-row layout-align-start-center'
      }
      >
        {chargeableWeightMots.map(mot => (
          chargeableWeightElemJSX({ ...sharedProps, mot })
        ))}
      </div>

    </div>
  )

  return {
    chargeableVolume: chargeableVolumeElement,
    chargeableWeight: chargeableWeightElement,
    totalVolume,
    totalWeight
  }
}

export function ChargableProperties ({
  t,
  cargoItem,
  availableMots,
  scope,
  maxDimensions
}) {
  const {
    totalVolume, chargeableVolume, chargeableWeight, totalWeight
  } = getChargableProperties({
    t,
    cargoItem,
    availableMots,
    scope,
    maxDimensions
  })

  return (
    <div className={`${styles.inner_cargo_item_info} layout-row flex-100 layout-wrap layout-align-start`}>
      <div className="flex-45 layout-wrap layout-row">
        {totalVolume}
        {chargeableVolume}
      </div>
      <div className="flex-5" />
      <div className={`${styles.padding_left} flex-45 layout-wrap layout-row`}>
        {totalWeight}
        {chargeableWeight}
      </div>
    </div>
  )
}
