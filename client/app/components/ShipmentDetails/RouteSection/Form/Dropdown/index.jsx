import React from 'react'
import { withNamespaces } from 'react-i18next'
import FormsySelect from '../../../../Formsy/Select'
import styles from './index.scss'
import routeHelpers from './routeHelpers'

const customStyles = `
  .Select-control {
    background-color: #F9F9F9;
    box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
    border: 1px solid #f2f2f2 !important;
  }
  .Select-menu-outer {
    box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
    border: 1px solid #f2f2f2;
  }
  .Select-value {
    background-color: #F9F9F9;
    border: 1px solid #f2f2f2;
  }
  .Select-option {
    background-color: #f9f9f9;
  }
`

function getOptions (targets) {
  const labels = []

  return targets.map(routeHelpers.routeOption).filter((option) => {
    const isNewLabel = !labels.includes(option.label)
    labels.push(option.label)

    return isNewLabel
  })
}

function Dropdown ({
  theme,
  target,
  carriage,
  availableTargets,
  formData,
  onDropdownSelect,
  t
}) {
  return (
    <div className="dropdown">
      <FormsySelect
        name={`${target}-nexus`}
        className={styles.select}
        value={formData.nexusId ? routeHelpers.routeOption(formData) : null}
        placeholder={t(`shipment:${target}`)}
        options={getOptions(availableTargets)}
        onChange={option => onDropdownSelect(target, option)}
        customStyles={customStyles}
        validationErrors={{ isDefaultRequiredValue: t('errors:notBlank') }}
        required
      />
    </div>
  )
}

export default withNamespaces(['shipment', 'errors'])(Dropdown)
