import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { get } from 'lodash'
import Checkbox from '../../../Checkbox/Checkbox'
import CollapsingBar from '../../../CollapsingBar/CollapsingBar'
import NamedSelect from '../../../NamedSelect/NamedSelect'

class AdminScopeEditorHashRow extends Component {
  constructor (props) {
    super(props)
  }

  editor (data, key) {
    const {
      t, selectOptions, selectedValue, scopeKey, handleScopeChange
    } = this.props
    if (get(selectOptions, [key], false)) {
      const options = selectOptions.map(o => ({ label: t(`scopes:${o}`), value: o }))
      const currentValue = options.filter(o => o.value === selectedValue)[0]

      return (
        <NamedSelect
          className="flex-100"
          options={options}
          value={currentValue}
          onChange={e => handleScopeChange([scopeKey, key], e.value)}
        />
      )
    }
    if (typeof data === 'boolean') {
      return (
        <Checkbox
          checked={data}
          onChange={e => handleScopeChange([scopeKey, key], e)}
        />
      )
    }

    return (
      <div className="flex-100 layout-row input_box_full">
        <input type="text" value={data} onBlur={e => handleScopeChange([scopeKey, key], e.target.value)} />
      </div>
    )
  }

  nestedRows (data, key) {
    const { t } = this.props

    return (
      <div className="flex-100 layout-row layout-align-start-center layout-wrap">
        <div className="flex-100 layout-row layout-align-start-center">
          <h5 className="flex-none">{t(`scopes:${key}`)}</h5>
        </div>
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          { Object.keys(data[key]).map(k => {
            if (typeof data[key][k] === 'object') {
              return this.nestedRows(data[key][k], k)
            }
            return (
            <div className="flex-100 layout-row layout-align-start-center">
              <div className="flex layout-row layout-align-start-center">
                {t(`scopes:${k}Description`)}
              </div>
              <div className="flex-33 layout-row layout-align-start-center">
                {this.editor(data[key], k)}
              </div>
            </div>
          )
          })}
        </div>
      </div>
    )
  }

  singleRow (data, key) {
    const { t } = this.props

    return (
      <div className="flex-100 layout-row layout-align-start-center">
        <div className="flex-100 layout-row layout-align-start-center">
          <h5 className="flex-none">{t(`scopes:${key}`)}</h5>
        </div>
        <div className="flex-100 layout-row layout-align-start-center">
          <div className="flex-100 layout-row layout-align-start-center">
            <div className="flex layout-row layout-align-start-center">
              {t(`scopes:${key}Description`)}
            </div>
            <div className="flex-33 layout-row layout-align-start-center">
              {this.editor(data, key)}
            </div>
          </div>
        </div>
      </div>
    )
  }

  render () {
    const {
      t, data, scopeKey
    } = this.props
    const dataKeys = Object.keys(data)

    return (
      <CollapsingBar
        text={t(`scopes:${scopeKey}`)}
        showArrow
        content={
          (
            <div className="flex-100 layout-row layout-wrap">
              {dataKeys.map((dk) => {
                if (typeof data[dk] === 'object') {
                  return this.nestedRows(data, dk)
                }

                return this.singleRow(data, dk)
              })}
            </div>
          )
        }
      />
    )
  }
}

export default withNamespaces(['admin', 'common', 'scopes'])(AdminScopeEditorHashRow)
