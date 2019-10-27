import React from 'react'
import { withNamespaces } from 'react-i18next'
import uuid from 'uuid'
import styles from './index.scss'
import {
  volume, 
  weightDynamicScale,
  switchIcon,
  chargeableWeight,
  chargeableWeightTon,
  rawWeight,
  effectiveKgPerCubicMeter,
  convertCargoItemAttributes,
  numberSpacing
} from '../../../../../../helpers'
import ChargeableProperty from './ChargeableProperty'
import TotalProperty from './TotalProperty'
import UnitSpan from '../../../../../UnitSpan'

class ChargeableProperties extends React.PureComponent {
  constructor (props) {
    super(props)

    this.getOption = this.getOption.bind(this)
    this.getValue = this.getValue.bind(this)
    this.getLabelText = this.getLabelText.bind(this)
    this.isAvailableMot = this.isAvailableMot.bind(this)
  }

  getOption (mot) {
    const { scope, cargoItem } = this.props
    const convertedItem = convertCargoItemAttributes(cargoItem)

    if (scope.chargeable_weight_view !== 'dynamic') return (scope.chargeable_weight_view || 'both')

    const showVolume = volume(convertedItem) > (rawWeight(convertedItem) / effectiveKgPerCubicMeter[mot || 'ocean'])

    return showVolume ? 'volume' : 'weight'
  }

  getUnitSpan (option) {
    const { scope } = this.props
    const { values } = scope
    const { unit } = values.weight

    return {
      weight: <UnitSpan unit={unit} />,
      volume: <UnitSpan unit="m" />,
      both: (
        <React.Fragment>
          <UnitSpan unit="t" />
          |
          <UnitSpan unit="m" />
        </React.Fragment>
      )
    }[option]
  }

  getValue (mot, option) {
    const { cargoItem, scope } = this.props
    const convertedItem = convertCargoItemAttributes(cargoItem)
    const { values } = scope
    const { unit } = values.weight

    return {
      weight: unit === 'kg' ? chargeableWeight(convertedItem, mot) : chargeableWeightTon(convertedItem, mot),
      volume: chargeableWeightTon(convertedItem, mot),
      both: chargeableWeightTon(convertedItem, mot)
    }[option]
  }

  getLabelText () {
    const { t } = this.props

    return {
      weight: `${t('cargo:chargeableWeight')}:`,
      volume: `${t('cargo:chargeableVolume')}:`,
      both: `${t('cargo:chargeableWeightVol')}:`
    }[this.getOption()]
  }

  isAvailableMot (mot) {
    const { cargoItem, availableMots, maxDimensions } = this.props
    const convertedItem = convertCargoItemAttributes(cargoItem)

    return !(
      (
        availableMots.length > 0 && !availableMots.includes(mot)
      ) ||
      (
        maxDimensions[mot] && (
          +cargoItem.dimensionZ > +maxDimensions[mot].dimensionZ ||
          +cargoItem.dimensionY > +maxDimensions[mot].dimensionY ||
          chargeableWeight(convertedItem, mot) > +maxDimensions[mot].chargeableWeight
        )
      )
    )
  }

  render () {
    const { allMots, cargoItem, scope } = this.props
    const { values } = scope
    const { unit, decimals } = values.weight
    const convertedItem = convertCargoItemAttributes(cargoItem)

    return (
      <div className={`${styles.inner_cargo_item_info} layout-row flex-100 layout-wrap layout-align-start`}>
        <div className="flex-100 layout-row layout-wrap">
          <div className="flex layout-wrap layout-row">
            <TotalProperty
              value={numberSpacing(volume(convertedItem), 3)}
              unit={<UnitSpan unit="m" />}
              property="volume"
            />
          </div>
          <div className="flex offset-5 layout-wrap layout-row">
            <TotalProperty
              value={weightDynamicScale(convertedItem, unit, decimals)}
              unit={<UnitSpan unit={unit} />}
              property="weight"
            />
          </div>
        </div>

        <div className={`${styles.chargeable_weight} layout-row flex-100 layout-wrap layout-align-start-center`}>
          <div className="layout-row flex-none layout-wrap layout-align-end-center">
            <p className={`${styles.subchargeable} flex-none`}>
              {this.getLabelText()}
            </p>
          </div>
          <div className={
            `${styles.chargeable_weight_values} flex layout-row layout-align-start-center`
          }
          >
            {
              allMots.map((mot) => {
                const option = this.getOption(mot)

                return (
                  <ChargeableProperty
                    key={uuid.v4()}
                    value={this.getValue(mot, option)}
                    unit={this.getUnitSpan(option)}
                    available={this.isAvailableMot(mot)}
                    icon={switchIcon(mot)}
                  />
                )
              })
            }
          </div>
        </div>
      </div>
    )
  }
}

export default withNamespaces(['common', 'cargo'])(ChargeableProperties)
