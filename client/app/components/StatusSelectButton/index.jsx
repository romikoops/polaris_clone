import React, { PureComponent } from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import styles from './index.scss'
import LoadingSpinner from '../LoadingSpinner/LoadingSpinner'
import GradientBorder from '../GradientBorder'
import { gradientBorderGenerator } from '../../helpers'
import { adminActions } from '../../actions'

class StatusSelectButton extends PureComponent {
  constructor (props) {
    super(props)
    this.statusOptions = [
      {
        label: 'Requested', value: 'requested', icon: 'fa-hourglass-o', iconColour: '#EF5B00'
      },
      {
        label: 'Ignore', value: 'ignore', icon: 'fa-trash', iconColour: '#EB5757'
      },
      {
        label: 'Archive', value: 'archive', icon: 'fa-archive', iconColour: '#F48A00'
      },
      { label: 'Finish', value: 'finished', icon: 'fa-flag-checkered' },
      {
        label: 'Accept', value: 'accept', icon: 'fa-check', iconColour: '#6FCF97'
      }
    ]
    this.state = {
      showOptions: false,
      requestMade: false
    }
    this.toggleOptions = this.toggleOptions.bind(this)
  }

  toggleOptions () {
    this.setState(prevState => ({ showOptions: !prevState.showOptions }))
  }

  handleClick (action) {
    const { adminDispatch, shipment } = this.props
    if (this.state.showOptions) {
      this.toggleOptions()
    }
    adminDispatch.confirmShipment(shipment.id, action)
  }

  determineAction () {
    const { status } = this.props.shipment
    let defaultValue
    let defaultVerb
    debugger
    switch (status) {
      case 'requested':
        defaultValue = 'accept'
        defaultVerb = 'Accept'
        break
      case 'requested_by_unconfirmed_account':
        defaultValue = 'accept'
        defaultVerb = 'Accept'
        break
      case 'confirmed':
        defaultValue = 'finished'
        defaultVerb = 'Finish'
        break
      case 'declined':
        defaultValue = 'archived'
        defaultVerb = 'Archive'
        break
      case 'archived':
        defaultValue = ''
        defaultVerb = 'Choose'
        break
      default:
        defaultValue = ''
        defaultVerb = ''
        break
    }

    return { defaultValue, defaultVerb }
  }

  render () {
    const {
      wrapperStyles, gradient, theme, showSpinner, shipment
    } = this.props
    
    const { showOptions } = this.state
    const { defaultValue, defaultVerb } = this.determineAction(shipment.status)
    const gradientBorderStyle =
    theme && theme.colors
      ? gradientBorderGenerator(theme.colors.primary, theme.colors.secondary)
      : { background: 'black' }
    const optionCards = this.statusOptions
      .filter(option => option.label !== defaultVerb)
      .map(option => (
        <div
          className={`flex-100 layout-row layout-align-start-center pointy ${styles.option_card}`}
          onClick={() => this.handleClick(option.value)}
        >
          {option.icon ? (
            <div className="flex-20 layout-row layout-align-center-center">
              <i className={`fa ${option.icon} flex-none`} style={{ color: option.iconColour }} />
            </div>
          )
            : ''}
          <div className="flex-80 layout-row layout-align-center-center">
            <p className="flex-none">{option.label}</p>
          </div>
        </div>
      ))
    const optionsClasses = showOptions ? `${styles.options_container} ${styles.show}` : styles.options_container
    const wrapperExpanded = showOptions ? `${styles.wrapper_show} ` : ''
    const defaultOption = this.statusOptions.filter(option => option.label === defaultVerb)[0] || {}
    const content = [<div className="flex-100 layout-row layout-align-end">
      <div
        className={`flex layout-row layout-align-center-center pointy ${styles.main_button}`}
        onClick={() => this.handleClick(defaultValue)}
      >
        {defaultOption.icon ? (
          <div className="flex-20 layout-row layout-align-center-center">
            <i className={`fa ${defaultOption.icon} flex-none pointy`} style={{ color: defaultOption.iconColour }} />
          </div>
        )
          : ''}
        <div className="flex layout-row layout-align-center-center">
          <p className="flex-none">{defaultVerb.toUpperCase()}</p>

          { showSpinner ? (
            <div className={`flex-none layout-row layout-align-center-center ${styles.spinner_box}`}>
              <LoadingSpinner size="extra_small" />
            </div>
          ) : '' }
        </div>
      </div>
      <div
        className={`flex-none layout-row layout-align-center-center ${styles.drop_down_button}`}
        onClick={this.toggleOptions}
      >
        <i className="fa fa-caret-down flex-none pointy" />
      </div>
    </div>,
    <div
      className={`flex-100 layout-row layout-wrap ${optionsClasses}`}
    >
      {optionCards}
    </div>]

    return (
      <div className="flex-100 layout-row layout-row layout-wrap relative">
        {showOptions ? <div className={`flex-none ${styles.backdrop}`} onClick={this.toggleOptions} /> : ''}
        {gradient
          ? (
            <GradientBorder
              wrapperClassName={`flex-100 layout-row layout-row layout-wrap ${wrapperStyles} ${wrapperExpanded}`}
              gradient={gradientBorderStyle}
              className="layout-row flex-100 layout-align-center-center layout-wrap relative"
              content={content}
            />
          )
          : (
            <div className={`flex-100 layout-row layout-row layout-wrap ${wrapperStyles} ${wrapperExpanded}`}>
              {content}
            </div>
          )
        }
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { admin } = state
  const {
    showSpinner, shipment
  } = admin

  return {
    showSpinner,
    shipment: shipment.shipment
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(StatusSelectButton)
