import React from 'react'
import { withNamespaces } from 'react-i18next'
import ReactTooltip from 'react-tooltip'
import PropTypes from '../../prop-types'
import styles from './ShipmentLocationBox.scss'
import { capitalizeAndDashifyCamelCase } from '../../helpers'

function showTooltip (truckingOption, directionConstraint, hubName, truckingBoolean) {
  return ['mandatory', 'disabled'].includes(directionConstraint) || (!truckingOption && hubName) || (truckingBoolean)
}

function TruckingTooltip ({
  truckingOptions, carriage, hubName, direction, scope, truckingBoolean, t
}) {
  const directionConstraints = {
    onCarriage: scope.carriage_options.on_carriage[direction],
    preCarriage: scope.carriage_options.pre_carriage[direction]
  }

  if (!showTooltip(truckingOptions[carriage], directionConstraints[carriage], hubName, truckingBoolean)) return ''

  let dataTip
  const carriageText = capitalizeAndDashifyCamelCase(carriage)
  if (!truckingOptions[carriage]) {
    dataTip = `${carriageText}${t('trucking:isNotAvailableLocal')}${hubName}`
  } else if (directionConstraints[carriage] === 'mandatory') {
    dataTip = `${carriageText}${t('trucking:isMandatory')}${direction}`
  } else if (directionConstraints[carriage] === 'disabled') {
    dataTip = `${carriageText}${t('trucking:isNotOffered')}${direction}`
  } else if (truckingBoolean) {
    dataTip = `${carriageText}${t('trucking:isNotAvailable')}`
  }

  return (
    <div>
      <ReactTooltip effect="solid" />
      <div
        className={styles.toggle_box_overlay}
        data-tip={dataTip}
      />
    </div>
  )
}

TruckingTooltip.propTypes = {
  truckingOptions: PropTypes.objectOf(PropTypes.bool).isRequired,
  t: PropTypes.func.isRequired,
  scope: PropTypes.scope.isRequired,
  carriage: PropTypes.string.isRequired,
  hubName: PropTypes.string,
  direction: PropTypes.string,
  truckingBoolean: PropTypes.bool.isRequired
}

TruckingTooltip.defaultProps = {
  hubName: '',
  direction: ''
}

export default withNamespaces('trucking')(TruckingTooltip)
