import React from 'react'
import { withNamespaces } from 'react-i18next'
import FormsySelect from '../../../../Formsy/Select'
import styles from './index.scss'
import routeOption from './routeOption'

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
  const options = []

  targets.forEach((target) => {
    const option = routeOption(target)
    if (labels.includes(option.label)) return

    labels.push(option.label)
    options.push(option)
  })

  return options.sort((a, b) => (a.label > b.label ? 1 : -1))
}

function Dropdown ({
  target,
  availableTargets,
  formData,
  onDropdownSelect,
  t
}) {
  return (
    <div className={`dropdown ${styles.route_dropdown}`}>
      <FormsySelect
        name={`${target}-nexus`}
        className={styles.select}
        value={formData.nexusId ? routeOption(formData) : null}
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
