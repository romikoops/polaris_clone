// import React from 'react'
// import { withNamespaces } from 'react-i18next'
// import Checkbox from '../../../Checkbox/Checkbox'
// import CollapsingBar from '../../../CollapsingBar/CollapsingBar'
// import NamedSelect from '../../../NamedSelect/NamedSelect'
// import styles from './index.scss'

// function AdminScopeEditorRow ({
//   t, value, scopeKey, handleScopeChange, selectOptions, selectedValue
// }) {
//   const editor = selectOptions
//     ? (
//       <NamedSelect
//         className="flex-100"
//         options={selectOptions.map(o => ({ label: t(`scopes:${o}`), value: o }))}
//         value={selectedValue || { label: t(`scopes:${value}`), value }}
//         onChange={e => handleScopeChange(scopeKey, e)}
//       />
//     )
//     : (
//       <Checkbox
//         checked={value}
//         onChange={handleScopeChange}
//       />
//     )

//   return (
//     <CollapsingBar
//       text={t(`scopes:${scopeKey}`)}
//       showArrow
//       wrapperContentClasses={styles.overflow}
//       overflow
//       content={
//         (
//           <div className="flex-100 layout-row padd_20">
//             <div className="flex layout-row layout-align-start-start">
//               <p className="flex-90">
//                 {t(`scopes:${scopeKey}Description`)}
//               </p>
//             </div>
//             <div className="flex-33 layout-row layout-align-start-start">
//               {editor}
//             </div>
//           </div>
//         )
//       }
//     />
//   )
// }

// export default withNamespaces(['admin', 'common', 'scopes'])(AdminScopeEditorRow)

import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { get } from 'lodash'
import Checkbox from '../../../Checkbox/Checkbox'
import CollapsingBar from '../../../CollapsingBar/CollapsingBar'
import NamedSelect from '../../../NamedSelect/NamedSelect'

class AdminScopeEditorRow extends Component {
  constructor (props) {
    super(props)
  }

  editor (data) {
    const {
      t, selectOptions, selectedValue, scopeKey, handleScopeChange
    } = this.props
    if (selectOptions) {
      const options = selectOptions.map(o => ({ label: t(`scopes:${o}`), value: o }))
      const currentValue = options.filter(o => o.value === selectedValue)[0]

      return (
        <NamedSelect
          className="flex-100"
          options={options}
          value={currentValue}
          onChange={e => handleScopeChange(scopeKey, e.value)}
        />
      )
    }
    if (typeof data === 'boolean') {
      return (
        <Checkbox
          checked={data}
          onChange={e => handleScopeChange(scopeKey, e)}
        />
      )
    }

    return (
      <div className="flex-100 layout-row input_box_full">
        <input type="text" value={data} onBlur={e => handleScopeChange(scopeKey, e.target.value)} />
      </div>
    )
  }

  nestedRows (data, key) {
    const { t } = this.props

    return (
      <div className="flex-100 layout-row layout-align-start-center">
        <div className="flex-100 layout-row layout-align-start-center">
          <h5 className="flex-none">{t(`scopes:${key}`)}</h5>
        </div>
        <div className="flex-100 layout-row layout-align-start-center layout-wrap">
          { Object.keys(data[key]).map(k => (
            <div className="flex-100 layout-row layout-align-start-center">
              <div className="flex layout-row layout-align-start-center">
                {t(`scopes:${k}Description`)}
              </div>
              <div className="flex-33 layout-row layout-align-start-center">
                {this.editor({ data: data[key], key: k })}
              </div>
            </div>
          ))}
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
              {this.editor({ data, key })}
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

    return (
      <CollapsingBar
        text={t(`scopes:${scopeKey}`)}
        showArrow
        content={
          (
            <div className="flex-100 layout-row padd_20">
              <div className="flex layout-row layout-align-start-start">
                <p className="flex-90">
                  {t(`scopes:${scopeKey}Description`)}
                </p>
              </div>
              <div className="flex-33 layout-row layout-align-start-start">
                {this.editor()}
              </div>
            </div>
          )
        }
      />
    )
  }
}

export default withNamespaces(['admin', 'common', 'scopes'])(AdminScopeEditorRow)
