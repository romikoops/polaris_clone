import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { bookingProcessActions, shipmentActions } from '../../actions'
import styles from './ChooseShipment.scss'
import defs from '../../styles/default_classes.scss'
import { CardLinkRow } from '../CardLinkRow/CardLinkRow'
import { LOAD_TYPES } from '../../constants'
import { RoundButton } from '../RoundButton/RoundButton'
import {
  capitalize, gradientTextGenerator, hexToRGB, humanizedMotAndLoadType
} from '../../helpers'
import TextHeading from '../TextHeading/TextHeading'

class ChooseShipment extends Component {
  constructor (props) {
    super(props)
    this.state = {}
    this.cards = LOAD_TYPES.map(loadType => ({
      name: humanizedMotAndLoadType(props.scope, loadType.code),
      img: loadType.img,
      code: loadType.code,
      options: { contained: true },
      handleClick: () => this.setLoadType(loadType.code)
    }))
    this.setLoadType = this.setLoadType.bind(this)
    this.setDirection = this.setDirection.bind(this)
    this.nextStep = this.nextStep.bind(this)
    this.chooseShipmentDetails = this.chooseShipmentDetails.bind(this)
  }

  componentDidMount () {
    const { bookingProcessDispatch, shipmentDispatch } = this.props
    bookingProcessDispatch.resetStore()
    shipmentDispatch.clearLoading()
    window.scrollTo(0, 0)
    this.determineAvailableOptions()
  }

  setLoadType (loadType) {
    this.setState({ loadType })
  }

  setDirection (direction) {
    this.setState({ direction })
  }

  determineAvailableOptions () {
    if (this.props && this.props.scope) {
      const { scope, user } = this.props
      const allowedCargoTypeCount = { cargo_item: 0, container: 0 }
      const allowedCargoTypes = { cargo_item: false, container: false }

      Object.keys(scope.modes_of_transport).forEach((mot) => {
        allowedCargoTypeCount.cargo_item += scope.modes_of_transport[mot].cargo_item
        allowedCargoTypeCount.container += scope.modes_of_transport[mot].container
      })
      if (allowedCargoTypeCount.container > 0) {
        allowedCargoTypes.container = true
      }
      if (allowedCargoTypeCount.cargo_item > 0) {
        allowedCargoTypes.cargo_item = true
      }

      const showCargoTypes = allowedCargoTypes.cargo_item && allowedCargoTypes.container
      const showDirections = !scope.default_direction
      if (!showCargoTypes && showDirections) {
        const loadType = allowedCargoTypes.cargo_item ? 'cargo_item' : 'container'
        this.setState({
          allowedCargoTypes, showCargoTypes, showDirections, loadType
        })
      } else if (showCargoTypes && !showDirections) {
        const direction = scope.default_direction
        this.setState({
          allowedCargoTypes, showCargoTypes, showDirections, direction
        })
      } else if (!showCargoTypes && !showDirections) {
        const direction = scope.default_direction
        const loadType = allowedCargoTypes.cargo_item ? 'cargo_item' : 'container'
        this.chooseShipmentDetails({ loadType, direction })
      } else {
        this.setState({ allowedCargoTypes, showCargoTypes, showDirections })
      }
    }
  }

  chooseShipmentDetails ({ loadType, direction }) {
    const { selectLoadType, bookingProcessDispatch } = this.props
    selectLoadType({ loadType, direction })

    bookingProcessDispatch.updateShipment('loadType', loadType)
    bookingProcessDispatch.updateShipment('direction', direction)
  }

  nextStep () {
    const { loadType, direction } = this.state
    this.chooseShipmentDetails({ loadType, direction })
  }

  render () {
    const { theme, t } = this.props

    const {
      loadType,
      direction,
      allowedCargoTypes,
      showDirections,
      showCargoTypes
    } = this.state
    const gradientStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }

    const directionButtons = ['export', 'import'].map((dir) => {
      const buttonStyle = direction === dir ? styles.selected : styles.unselected
      const commercialAction = { import: 'Buying', export: 'Selling' }

      return (
        <div
          className={
            `${styles.direction_card} ${buttonStyle} ` +
            'flex-none layout-row layout-align-center-center'
          }
          onClick={() => this.setDirection(dir)}
        >
          <div className="flex-80 layout-row layout-align-space-between-center">
            <p className="flex-none">
              {' '}
              {t('shipment:chooseDirection', { commercialAction: commercialAction[dir], direction: capitalize(dir) })}
            </p>
            {direction === dir ? (
              <i className="flex-none fa fa-check clip" style={gradientStyle} />
            ) : (
              ''
            )}
          </div>
        </div>
      )
    })
    const activeBtn = (
      <RoundButton
        theme={theme}
        size="full"
        active
        handleNext={this.nextStep}
        text={t('common:nextStep')}
        iconClass="fa-chevron-right"
      />
    )
    const disabledBtn = (
      <RoundButton
        theme={theme}
        size="full"
        text={t('common:nextStep')}
        iconClass="fa-chevron-right"
      />
    )

    return (
      <div className={`${styles.card_link_row} layout-row flex-100 layout-align-center-center`}>
        <div
          className={
            `flex-none ${defs.content_width} layout-row layout-align-center-center layout-wrap`
          }
        >
          {
            showDirections
              ? (
                <div className="flex-100 layout-row layout-align-space-around-center layout-wrap">
                  <div className="flex-100 layout-row layout-align-start-center">
                    <TextHeading theme={theme} size={4} text={t('common:importOrExport')} />
                  </div>
                  {directionButtons}
                </div>
              )
              : <div className={`flex-100 layout-row layout-wrap ${styles.empty_row} `} />
          }
          {
            showCargoTypes
              ? (
                <div
                  className={
                    `flex-100 layout-row layout-wrap ${styles.section} ` +
                  `${direction ? '' : styles.inactive}`
                  }
                >
                  <div className="flex-100 layout-row layout-align-start-center">
                    <TextHeading
                      theme={theme}
                      size={4}
                      text={t('common:itemsOrContainers')}
                    />
                  </div>
                  <CardLinkRow
                    theme={theme}
                    cards={this.cards}
                    allowedCargoTypes={allowedCargoTypes}
                    selectedType={loadType}
                  />
                </div>
              )
              : <div className={`flex-100 layout-row layout-wrap ${styles.empty_row} `} />
          }
          <div
            className={
              `${styles.next_step_sec} flex-100 layout-row layout-align-center ` +
              `${styles.section} ${direction && loadType ? '' : styles.inactive}`
            }
          >
            <div
              className={`${styles.mot_sec} flex-80 layout-row layout-wrap layout-align-center`}
              style={{
                color: `${theme && hexToRGB(theme.colors.primary, 0.8)}`
              }}
            >
              <div className={`${styles.next_step_btn_sec} flex-100 layout-row layout-align-end`}>
                <div className="flex-gt-sm-70 flex-100 layout-row layout-align-end-start">
                  <p className={`${styles.mot_note} flex-60`}>
                    {t('common:availabilities')}
                  </p>
                  <div className="flex-40 layout-row layout-align-center-center">
                    {loadType && direction ? activeBtn : disabledBtn}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

ChooseShipment.defaultProps = {
  theme: null
}

function mapStateToProps (state) {
  const {
    users, authentication, bookingData, app
  } = state
  const {
    user, loggedIn, loggingIn, registering
  } = authentication
  const { currencies, tenant } = app
  const { loading, modal } = bookingData

  return {
    user,
    users,
    tenant,
    loggedIn,
    bookingData,
    modal,
    loggingIn,
    registering,
    loading,
    currencies
  }
}

function mapDispatchToProps (dispatch) {
  return {
    bookingProcessDispatch: bindActionCreators(bookingProcessActions, dispatch),
    shipmentDispatch: bindActionCreators(shipmentActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces('shipment')(ChooseShipment))
