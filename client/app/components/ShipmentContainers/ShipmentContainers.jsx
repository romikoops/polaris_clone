import React, { Component } from 'react'
import { translate } from 'react-i18next'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import '../../styles/select-css-custom.css'
import styles from './ShipmentContainers.scss'
import { CONTAINER_DESCRIPTIONS, CONTAINER_TARE_WEIGHTS } from '../../constants'
import Checkbox from '../Checkbox/Checkbox'
import defs from '../../styles/default_classes.scss'
import ValidatedInput from '../ValidatedInput/ValidatedInput'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import { Tooltip } from '../Tooltip/Tooltip'

const containerDescriptions = CONTAINER_DESCRIPTIONS
const containerTareWeights = CONTAINER_TARE_WEIGHTS

class ShipmentContainers extends Component {
  constructor (props) {
    super(props)
    this.state = {
      selectors: [{}],
      firstRenderInputs: !this.props.nextStageAttempt
    }
    this.handleContainerSelect = this.handleContainerSelect.bind(this)
    this.handleContainerQ = this.handleContainerQ.bind(this)
    this.toggleDangerousGoods = this.toggleDangerousGoods.bind(this)
    this.setFirstRenderInputs = this.setFirstRenderInputs.bind(this)
    this.addContainer = this.addContainer.bind(this)
  }
  setFirstRenderInputs (bool) {
    this.setState({ firstRenderInputs: bool })
  }
  handleContainerSelect (optionSelected) {
    const { index } = optionSelected
    const modifiedEventSizeClass = {
      target: { name: `${index}-sizeClass`, value: optionSelected.value }
    }
    const modifiedEventTareWeight = {
      target: { name: `${index}-tareWeight`, value: optionSelected.tare_weight }
    }
    const { selectors } = this.state
    selectors[index] = {
      sizeClass: optionSelected.value,
      tareWeight: optionSelected.tare_weight
    }
    this.setState({ selectors })
    this.props.handleDelta(modifiedEventSizeClass)
    this.props.handleDelta(modifiedEventTareWeight)
  }

  handleContainerQ (event) {
    const modifiedEvent = { target: event }
    this.props.handleDelta(modifiedEvent)
  }

  toggleDangerousGoods (i) {
    const event = {
      target: {
        name: `${i}-dangerous_goods`,
        value: !this.props.containers[i].dangerous_goods
      }
    }
    this.props.handleDelta(event)
  }

  deleteCargo (index) {
    this.setState((prevState) => {
      const { selectors } = prevState
      selectors.splice(index, 1)

      return {
        selectors
      }
    })
    this.props.deleteItem('containers', index)
  }

  addContainer () {
    this.props.addContainer()

    const { selectors } = this.state
    selectors.push({})

    this.setState({ selectors, firstRenderInputs: true })
  }

  render () {
    const {
      containers, handleDelta, theme, scope, toggleModal, t
    } = this.props
    const { selectors } = this.state

    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${
            theme.colors.primary
          },${
            theme.colors.secondary
          })`
          : 'black'
    }

    const containerOptions = []
    Object.keys(containerDescriptions).forEach((key) => {
      if (key !== 'lcl') {
        containerOptions.push({
          value: key,
          label: containerDescriptions[key],
          tare_weight: containerTareWeights[key]
        })
      }
    })
    const numberOptions = []
    for (let i = 1; i <= 20; i++) {
      numberOptions.push({ label: i, value: i })
    }

    const optionsWithIndex = (options, index) => options.map((option) => {
      const optionCopy = Object.assign([], option)
      optionCopy.index = index

      return optionCopy
    })
    const generateSeparator = () => (
      <div key={v4()} className={`${styles.separator} flex-100`}>
        <hr />
      </div>
    )
    const generateContainer = (container, i) => {
      const tareWeight = container ? selectors[i].tareWeight : 0
      const maxValue = 35000 - tareWeight

      return (
        <div
          key={i}
          name={`${i}-container`}
          className="layout-row flex-100 layout-wrap layout-align-start-center"
          style={{ position: 'relative' }}
        >
          <div className="layout-row flex layout-wrap layout-align-start-center">
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">
              <p className={`${styles.input_label} flex-none`}>{t('common:containerSize')}</p>
              <Tooltip theme={theme} icon="fa-info-circle" text="size_class" />
            </div>
            <NamedSelect
              placeholder={container ? container.sizeClass : ''}
              className="flex-95"
              name={`${i}-container_size`}
              value={container ? selectors[i].sizeClass : ''}
              options={container ? optionsWithIndex(containerOptions, i) : []}
              onChange={this.handleContainerSelect}
            />
          </div>
          <div className="layout-row flex layout-wrap layout-align-start-center">
            <p className={`${styles.input_label} flex-none`}>{t('cargo:cargoGrossWeight')}</p>
            <div className={`flex-95 layout-row ${styles.input_box}`}>
              {container ? (
                <ValidatedInput
                  wrapperClassName="flex-80"
                  name={`${i}-payload_in_kg`}
                  value={container ? container.payload_in_kg : ''}
                  type="number"
                  onChange={handleDelta}
                  firstRenderInputs={this.state.firstRenderInputs}
                  setFirstRenderInputs={this.setFirstRenderInputs}
                  nextStageAttempt={this.props.nextStageAttempt}
                  validations={{
                    nonNegative: (values, _value) => _value > 0,
                    maxValue: (values, _value) => _value <= maxValue
                  }}
                  validationErrors={{
                    maxValue: `${t('errors:maxValue')} ${maxValue} ${t('acronym:kg')}`,
                    nonNegative: t('errors:nonNegative'),
                    isDefaultRequiredValue: t('errors:notBlank')
                  }}

                  required={!!container}
                />
              ) : (
                <input className="flex-80" type="number" />
              )}
              <div className="flex layout-row layout-align-center-center">{t('acronym:kg')}</div>
            </div>
          </div>
          <div className="layout-row flex layout-wrap layout-align-start-center">
            <p className={`${styles.input_label} flex-none`}>{t('common:numberContainers')}</p>
            <NamedSelect
              placeholder={container ? container.quantity : ''}
              className="flex-95"
              name={`${i}-quantity`}
              value={container ? container.quantity : ''}
              options={numberOptions}
              onChange={this.handleContainerQ}
            />
          </div>
          <div className="layout-row flex layout-wrap layout-align-start-center">
            <div className="layout-row flex-100 layout-wrap layout-align-start-center">
              <p className={`${styles.input_label} flex-none`}>{t('common:dangerousGoods')}</p>
              <Tooltip theme={theme} icon="fa-info-circle" text="dangerous_goods" />
            </div>
            <Checkbox
              onChange={() => this.toggleDangerousGoods(i)}
              checked={container ? container.dangerous_goods : false}
              theme={theme}
              size="34px"
              disabled={!scope.dangerous_goods}
              onClick={scope.dangerous_goods ? '' : () => toggleModal('noDangerousGoods')}
            />
          </div>

          {container ? (
            <i
              className={`fa fa-trash ${styles.delete_icon}`}
              onClick={() => this.deleteCargo(i)}
            />
          ) : (
            ''
          )}
        </div>
      )
    }
    const containersAdded = []

    if (containers) {
      containers.forEach((container, i) => {
        if (i > 0) containersAdded.push(generateSeparator())
        if (!selectors[i] || (selectors[i] && !selectors[i].sizeClass)) {
          const currentSizeClassSelection = container.sizeClass
            ? optionsWithIndex(containerOptions, i)
              .find(option => option.value === container.sizeClass)
            : optionsWithIndex(containerOptions, i)[0]
          this.handleContainerSelect(currentSizeClassSelection)
        }
        containersAdded.push(generateContainer(container, i))
      })
    }

    return (
      <div className="layout-row flex-100 layout-wrap layout-align-center-start">
        <div
          className={`layout-row flex-none ${
            defs.content_width
          } layout-wrap layout-align-start-center`}
          style={{ margin: '30px 0 70px 0' }}
        >
          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            {containersAdded}
          </div>

          <div className="layout-row flex-100 layout-wrap layout-align-start-center">
            <div className={`${styles.add_unit_wrapper} content_width`}>
              <div
                className="layout-row flex-none layout-align-start-center"
                onClick={this.addContainer}
              >
                <p>{t('shipment:addUnit')}&nbsp;&nbsp;</p>
                <i className="fa fa-plus-square-o clip" style={textStyle} />
              </div>
            </div>
            <div className={`${styles.new_container_placeholder} flex-100`}>
              {generateSeparator(null, -1)}
              {generateContainer(null, -1)}
            </div>
          </div>
        </div>
      </div>
    )
  }
}

ShipmentContainers.propTypes = {
  theme: PropTypes.theme,
  addContainer: PropTypes.func.isRequired,
  t: PropTypes.func.isRequired,
  containers: PropTypes.arrayOf(PropTypes.shape({
    dangerous_goods: PropTypes.bool
  })),
  deleteItem: PropTypes.func.isRequired,
  handleDelta: PropTypes.func.isRequired,
  nextStageAttempt: PropTypes.bool,
  scope: PropTypes.shape({
    dangerous_goods: PropTypes.bool
  }).isRequired,
  toggleModal: PropTypes.func
}

ShipmentContainers.defaultProps = {
  theme: null,
  nextStageAttempt: false,
  toggleModal: null,
  containers: []
}

export default translate(['common', 'cargo', 'shipment', 'errors', 'acronym'])(ShipmentContainers)
