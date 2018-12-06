import React from 'react'
import { withNamespaces } from 'react-i18next'
import Select from 'react-select'
import styled from 'styled-components'
import styles from './index.scss'
import TextHeading from '../../TextHeading/TextHeading'
import PropTypes from '../../../prop-types'
import { gradientTextGenerator } from '../../../helpers'
import { incoterms } from '../../../constants'
import '../../../styles/select-css-custom.scss'

function IncotermBox ({
  theme,
  onCarriage,
  preCarriage,
  tenantScope,
  incoterm,
  setIncoterm,
  errorStyles,
  showIncotermError,
  nextStageAttempt,
  direction,
  t
}) {
  const selectedStyle =
    theme && theme.colors
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: 'black' }
  const textSwitch = () => {
    if (preCarriage && onCarriage) {
      return t('itbox:doorToDoor')
    }
    if (!preCarriage && onCarriage) {
      return t('itbox:portToDoor')
    }
    if (preCarriage && !onCarriage) {
      return t('itbox:doorToPort')
    }

    return t('itbox:portToPort')
  }
  const simpleOptions = [
    {
      label: t('itbox:doorToDestination'),
      value: 'DTP',
      direction: 'export',
      preCarriage: true,
      onCarriage: false
    },
    {
      label: t('itbox:doorToDoor'),
      value: 'DTD',
      direction: 'export',
      preCarriage: true,
      onCarriage: true
    },
    {
      label: t('itbox:originToDoor'),
      value: 'PTD',
      direction: 'export',
      preCarriage: true,
      onCarriage: true
    },
    {
      label: t('itbox:originToDestination'),
      value: 'PTP',
      direction: 'export',
      preCarriage: false,
      onCarriage: false
    },
    {
      label: t('itbox:originToDoor'),
      value: 'PTD',
      direction: 'import',
      preCarriage: false,
      onCarriage: true
    },
    {
      label: t('itbox:doorToDestination'),
      value: 'DTP',
      direction: 'import',
      preCarriage: true,
      onCarriage: false
    },
    {
      label: t('itbox:doorToDoor'),
      value: 'DTD',
      direction: 'import',
      preCarriage: true,
      onCarriage: true
    },
    {
      label: t('itbox:originToDestination'),
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
      <div className="flex-40 layout-row layout-align-end-center">
        <div className="flex-none" style={{ paddingRight: '15px' }}>
          <TextHeading theme={theme} text={`${t('shipment:serviceLevel')}:`} size={3} />
        </div>
        <div className="flex-none layout-row layout-align-center-center">
          <i className="fa fa-chain flex-none" style={{ color: '#E0E0E0', paddingRight: '8px' }} />
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
        <div className="flex-none">
          <TextHeading theme={theme} text={t('common:selectIncoterm')} size={3} />
        </div>
      </div>
      <div className="flex-80" name="incoterms" style={{ position: 'relative' }}>
        <StyledSelect
          name="incoterms"
          className={styles.select}
          value={incoterm}
          options={incoterms}
          onChange={setIncoterm}
        />
        <span className={errorStyles.error_message}>
          {showIncotermError ? t('common:noBlank') : ''}
        </span>
      </div>
    </div>
  )
  const filteredOptions = simpleOptions.filter(x => x.direction === direction)
  const dropdownSimple = (
    <div className="flex-100 layout-row layout-align-end-center layout-wrap">
      <div className="flex-100 layout-row layout-align-end-center">
        <div className="flex-none">
          <TextHeading theme={theme} text={t('common:selectIncoterm')} size={3} />
        </div>
      </div>
      <div className="flex-80" name="incoterms" style={{ position: 'relative' }}>
        <StyledSelect
          name="incoterms"
          className={styles.select}
          value={incoterm}
          options={filteredOptions}
          onChange={setIncoterm}
        />
        <span className={errorStyles.error_message}>
          {showIncotermError ? t('common:noBlank') : ''}
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
  t: PropTypes.func.isRequired,
  onCarriage: PropTypes.bool,
  preCarriage: PropTypes.bool,
  tenantScope: PropTypes.objectOf(PropTypes.any),
  incoterm: PropTypes.string,
  setIncoterm: PropTypes.func,
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
  setIncoterm: null,
  errorStyles: {},
  showIncotermError: false,
  nextStageAttempt: false,
  value: false,
  direction: ''
}

export default withNamespaces(['common', 'itbox', 'shipment'])(IncotermBox)
