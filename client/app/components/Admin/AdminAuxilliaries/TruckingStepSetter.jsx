import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import PropTypes from 'prop-types'
import Formsy from 'formsy-react'
import styles from '../Admin.scss'
import { NamedSelect } from '../../NamedSelect/NamedSelect'
import FormsyInput from '../../FormsyInput/FormsyInput'
import { RoundButton } from '../../RoundButton/RoundButton'

export class TruckingStepSetter extends Component {
  constructor (props) {
    super(props)
    this.state = {
      steps: [],
      upperKey: 'max_weight',
      lowerKey: 'min_weight',
      newStep: {},
      stepBasis: { label: 'Weight', value: 'weight' }
    }
    this.saveSteps = this.saveSteps.bind(this)
    this.handleStepBasisChange = this.handleStepBasisChange.bind(this)
    this.addStep = this.addStep.bind(this)
    this.handleStepChange = this.handleStepChange.bind(this)
  }

  handleStepBasisChange (selection) {
    if (selection.value === 'city') {
      const lowerKey = `min_${selection.value}`
      const upperKey = `max_${selection.value}`
      this.setState({
        stepBasis: selection,
        upperKey,
        lowerKey,
        step2: true,
        newStep: {
          [lowerKey]: 0,
          [upperKey]: 0
        }
      })
    } else if (selection.value === 'unit') {
      this.props.saveSteps({
        steps: [{ all_units: '' }],
        upperKey: 'all_units',
        lowerKey: 'all_units',
        stepBasis: selection
      })
    } else {
      this.setState({
        stepBasis: selection,
        step2: true
      })
    }
  }
  addStep (model) {
    const { steps, upperKey, lowerKey } = this.state
    steps.push({ ...model })
    const diff = parseInt(model[upperKey], 10) - parseInt(model[lowerKey], 10)
    this.setState({
      newStep: {
        [lowerKey]: parseInt(model[upperKey], 10) + 1,
        [upperKey]: parseInt(model[upperKey], 10) + diff
      },
      steps
    })
  }

  handleStepChange (event) {
    const { name, value } = event.target
    this.setState({
      newStep: {
        ...this.state.newStep,
        [name]: parseInt(value, 10)
      }
    })
  }
  saveSteps () {
    this.props.saveSteps({
      steps: this.state.steps,
      stepBasis: this.state.stepBasis,
      lowerKey: this.state.lowerKey,
      upperKey: this.state.upperKey
    })
  }
  render () {
    const {
      steps, stepBasis, lowerKey, upperKey, step2, newStep
    } = this.state
    const { theme, t } = this.props
    const basisOptions = [
      { label: 'Weight', value: 'weight' },
      { label: 'CBM', value: 'cbm' },
      { label: 'Unit', value: 'unit' }
    ]
    const stepsArr = (
      <div className="flex-100 layout-row layout-align-start-center layout-wrap">
        {steps.map((ws, i) => (
          <div
            // eslint-disable-next-line react/no-array-index-key
            key={`ows_${i}`}
            className="flex-33 layout-row layout-wrap layout-align-center-start"
          >
            <div className="flex-100 layout-row">
              <p className="flex-none">{`${stepBasis.label} Range:  ${ws[lowerKey]} - ${
                ws[upperKey]
              }`}</p>
            </div>
          </div>
        ))}
      </div>
    )
    const basisSelector = (
      <div
        className={`flex-100 layout-row layout-align-none-center layout-wrap ${styles.price_cell}`}
      >
        <p className="flex-100"> {t('admin:howTruckingPricings')} </p>
        <NamedSelect
          classes={`${styles.select}`}
          value={stepBasis}
          options={basisOptions}
          className="flex-100"
          onChange={this.handleStepBasisChange}
        />
      </div>
    )

    const stepForm = (
      <div className="flex-100 layout-row layout-align-start-center layout-wrap height_100">
        <div className="flex-100 layout-row layout-align-start-center">
          <p className="flex-none">{`${t('admin:setPricingHead')} ${
            stepBasis.label
          } ${t('admin:setPricingTail')}`}</p>
        </div>
        <Formsy
          onValidSubmit={this.addStep}
          className="flex-100 layout-row layout-align-start-center"
        >
          <div className="
            flex-33
            layout-row
            layout-row
            layout-wrap
            layout-align-start-start
            input_box"
          >
            <FormsyInput
              type="number"
              name={lowerKey}
              value={newStep[lowerKey]}
              validations="isNumeric"
              placeholder={t('admin:lowerLimit')}
            />
          </div>
          <div className="
            flex-33
            layout-row
            layout-row
            layout-wrap
            layout-align-start-start
            input_box"
          >
            <FormsyInput
              type="number"
              name={upperKey}
              value={newStep[upperKey]}
              validations="isNumeric"
              placeholder={t('admin:upperLimit')}
            />
          </div>
          <div className="flex-33 layout-row layout-align-center-center">
            <RoundButton
              theme={theme}
              size="small"
              placeholder={t('admin:addAnother')}
              iconClass="fa-plus-square-o"
            />
          </div>
        </Formsy>
        <div className="flex-100 layout-row layout-align-start-center">{stepsArr}</div>
        <div className="flex-100 layout-row layout-align-end-center button_padding">
          <RoundButton
            theme={theme}
            size="small"
            text={t('common:next')}
            active
            handleNext={this.saveSteps}
            iconClass="fa-chevron-right"
          />
        </div>
      </div>
    )

    return (
      <div className="flex-100 layout-row layout-align-start-center">
        {step2 ? stepForm : basisSelector}
      </div>
    )
  }
}
TruckingStepSetter.propTypes = {
  theme: PropTypes.theme,
  saveSteps: PropTypes.func.isRequired,
  t: PropTypes.func.isRequired
}
TruckingStepSetter.defaultProps = {
  theme: {}
}
export default withNamespaces(['common', 'admin'])(TruckingStepSetter)
