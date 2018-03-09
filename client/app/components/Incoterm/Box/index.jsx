import React from 'react'
import Select from 'react-select'
import styled from 'styled-components'
import styles from './index.scss'
import { TextHeading } from '../../TextHeading/TextHeading'
import PropTypes from '../../../prop-types'
import { gradientTextGenerator } from '../../../helpers'
import { incoterms } from '../../../constants'
import '../../../styles/select-css-custom.css'

export function IncotermBox ({
  theme,
  shipment,
  onCarriage,
  preCarriage,
  tenantScope,
  incoterm,
  setIncoTerm,
  errorStyles,
  showIncotermError,
  nextStageAttempt,
  direction
}) {
  const selectedStyle =
    theme && theme.colors
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: 'black' }
  const textSwitch = () => {
    if (preCarriage && onCarriage) {
      return 'Door to Door'
    }
    if (!preCarriage && onCarriage) {
      return 'Port to Door'
    }
    if (preCarriage && !onCarriage) {
      return 'Door to Port'
    }
    if (!preCarriage && !onCarriage) {
      return 'Port to Port'
    }
    return 'Port to Port'
  }
  const simpleOptions = [
    {
      label: 'Door to Destination Port',
      value: 'DTP',
      direction: 'export',
      preCarriage: true,
      onCarriage: false
    },
    {
      label: 'Door to Door',
      value: 'DTD',
      direction: 'export',
      preCarriage: true,
      onCarriage: true
    },
    {
      label: 'Origin Port to Door',
      value: 'PTD',
      direction: 'export',
      preCarriage: true,
      onCarriage: true
    },
    {
      label: 'Origin Port to Destination Port',
      value: 'PTP',
      direction: 'export',
      preCarriage: false,
      onCarriage: false
    },
    {
      label: 'Origin Port to Door',
      value: 'PTD',
      direction: 'import',
      preCarriage: false,
      onCarriage: true
    },
    {
      label: 'Door to Destination Port',
      value: 'DTP',
      direction: 'import',
      preCarriage: true,
      onCarriage: false
    },
    {
      label: 'Door to Door',
      value: 'DTD',
      direction: 'import',
      preCarriage: true,
      onCarriage: true
    },
    {
      label: 'Origin Port to Destination Port',
      value: 'PTP',
      direction: 'import',
      preCarriage: false,
      onCarriage: false
    }
  ]
  const backgroundColor = value => (!value && nextStageAttempt ? '#FAD1CA' : '#F9F9F9')
  const placeholderColorOverwrite = value =>
    (!value && nextStageAttempt ? 'color: rgb(211, 104, 80);' : '')
  const StyledSelect = styled(Select)`
    .Select-control {
      background-color: ${props => backgroundColor(props.value)};
      box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
      border: 1px solid #f2f2f2 !important;
    }
    .Select-menu-outer {
      box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
      border: 1px solid #f2f2f2;
    }
    .Select-value {
      background-color: ${props => backgroundColor(props.value)};
      border: 1px solid #f2f2f2;
    }
    .Select-placeholder {
      background-color: ${props => backgroundColor(props.value)};
      ${props => placeholderColorOverwrite(props.value)};
    }
    .Select-option {
      background-color: #f9f9f9;
    }
  `
  const textDisplay = (
    <div className="flex-100 layout-row layout-align-end-center layout-wrap">
      <div className="flex-100 layout-row layout-align-end-center">
        <div className="flex-none letter_2">
          <TextHeading theme={theme} text="Incoterm:" size={3} />
        </div>
      </div>
      <div className="flex-100 layout-row layout-align-end-center">
        <div className="flex-none layout-row layout-align-center-center">
          <i className="fa fa-chain clip flex-none" style={selectedStyle} />
        </div>
        <div className="flex-5" />
        <div className="flex-none layout-row layout-align-center-center">
          <p className="flex-none no_m">{textSwitch()}</p>
        </div>
      </div>
    </div>
  )

  const dropdownFull = (
    <div className="flex-100 layout-row layout-align-end-center layout-wrap">
      <div className="flex-100 layout-row layout-align-end-center">
        <div className="flex-none letter_2">
          <TextHeading theme={theme} text="Select Incoterm:" size={3} />
        </div>
      </div>
      <div className="flex-80" name="incoterms" style={{ position: 'relative' }}>
        <StyledSelect
          name="incoterms"
          className={styles.select}
          value={incoterm}
          options={incoterms}
          onChange={setIncoTerm}
        />
        <span className={errorStyles.error_message}>
          {showIncotermError ? 'Must not be blank' : ''}
        </span>
      </div>
    </div>
  )
  const filteredOptions = simpleOptions.filter(x => x.direction === direction)
  const dropdownSimple = (
    <div className="flex-100 layout-row layout-align-end-center layout-wrap">
      <div className="flex-100 layout-row layout-align-end-center">
        <div className="flex-none letter_2">
          <TextHeading theme={theme} text="Select Incoterm:" size={3} />
        </div>
      </div>
      <div className="flex-80" name="incoterms" style={{ position: 'relative' }}>
        <StyledSelect
          name="incoterms"
          className={styles.select}
          value={incoterm}
          options={filteredOptions}
          onChange={setIncoTerm}
        />
        <span className={errorStyles.error_message}>
          {showIncotermError ? 'Must not be blank' : ''}
        </span>
      </div>
    </div>
  )
  let boxView
  const switchVal =
    tenantScope && tenantScope.incoterm_info_level ? tenantScope.incoterm_info_level : ''
  switch (switchVal) {
    case 'simple':
      boxView = dropdownSimple
      break
    case 'text':
      boxView = textDisplay
      break
    case 'full':
      boxView = dropdownFull
      break
    default:
      break
  }
  return (
    <div className={`flex-100 layout-row layout-align-start-start  ${styles.incoterm_wrapper}`}>
      {boxView}
    </div>
  )
}

IncotermBox.propTypes = {
  theme: PropTypes.theme,
  onCarriage: PropTypes.bool,
  preCarriage: PropTypes.bool,
  shipment: PropTypes.objectOf(PropTypes.any).isRequired,
  tenantScope: PropTypes.objectOf(PropTypes.any),
  incoterm: PropTypes.string,
  setIncoTerm: PropTypes.func,
  errorStyles: PropTypes.objectOf(PropTypes.any),
  showIncotermError: PropTypes.bool,
  nextStageAttempt: PropTypes.bool,
  value: PropTypes.bool,
  direction: PropTypes.string
}

IncotermBox.defaultProps = {
  theme: null,
  onCarriage: false,
  preCarriage: false,
  tenantScope: {},
  incoterm: '',
  setIncoTerm: null,
  errorStyles: {},
  showIncotermError: false,
  nextStageAttempt: false,
  value: false,
  direction: ''
}

export default IncotermBox
