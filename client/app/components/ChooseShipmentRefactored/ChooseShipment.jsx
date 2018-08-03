import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import styles from './ChooseShipment.scss'
import { FlashMessages } from '../FlashMessages/FlashMessages'
import defs from '../../styles/default_classes.scss'
import { CardLinkRow } from '../CardLinkRow/CardLinkRow'
import { LOAD_TYPES } from '../../constants'
import { RoundButton } from '../RoundButton/RoundButton'
import { capitalize, gradientTextGenerator, hexToRGB, humanizedMotAndLoadType } from '../../helpers'
import { TextHeading } from '../TextHeading/TextHeading'
import { ALIGN_CENTER, trim, ROW, WRAP_ROW, COLUMN } from '../../classNames'

const CONTAINER = trim(`
  CHOOSE_SHIPMENT
  ${styles.card_link_row} 
  ${ROW(100)} 
  layout-align-center
`)

export class ChooseShipment extends Component {
  constructor (props) {
    super(props)
    this.state = {}

    this.cards = LOAD_TYPES.map(loadType => ({
      code: loadType.code,
      handleClick: () => this.setLoadType(loadType.code),
      img: loadType.img,
      name: humanizedMotAndLoadType(props.scope, loadType.code),
      options: { contained: true }
    }))
    this.setLoadType = this.setLoadType.bind(this)
    this.setDirection = this.setDirection.bind(this)
    this.nextStep = this.nextStep.bind(this)
  }
  setLoadType (loadType) {
    this.setState({ loadType })
  }
  setDirection (direction) {
    this.setState({ direction })
  }
  nextStep () {
    const { loadType, direction } = this.state
    this.props.selectLoadType({ loadType, direction })
  }
  render () {
    const { loadType, direction } = this.state
    const {
      messages,
      scope,
      theme
    } = this.props
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

    const flash = messages && messages.length > 0 ? <FlashMessages messages={messages} /> : ''

    const gradientStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }

    const directionButtons = ['export', 'import'].map((dir) => {
      const buttonStyle = direction === dir ? styles.selected : styles.unselected
      const commercialAction = { import: 'Buying', export: 'Selling' }
      const container = trim(`
            ${styles.direction_card} 
            ${buttonStyle}
            ${ROW('none')}
            ${ALIGN_CENTER} 
          `)
      const Icon = direction === dir
        ? <i className="flex-none fa fa-check clip" style={gradientStyle} />
        : ''

      return (
        <div
          className={container}
          onClick={() => this.setDirection(dir)}
        >
          <div className={`${ROW(80)} layout-align-space-between-center`}>
            <p className="flex-none">
              {' '}
                  I am {commercialAction[dir]} ({capitalize(dir)})
            </p>
            {Icon}
          </div>
        </div>
      )
    })

    const activeBtn = (
      <RoundButton
        theme={theme}
        size="small"
        active
        handleNext={this.nextStep}
        text="Next Step"
        iconClass="fa-chevron-right"
      />
    )
    const disabledBtn = (
      <RoundButton theme={theme} size="small" text="Next Step" iconClass="fa-chevron-right" />
    )
    const ItemsOrContainers = (<TextHeading
      theme={theme}
      size={4}
      text="Are you shipping cargo items or containers?"
    />)
    const CardLinkRowComponent = (<CardLinkRow
      theme={theme}
      cards={this.cards}
      allowedCargoTypes={allowedCargoTypes}
      selectedType={loadType}
    />)
    const ImportOrExport = (<TextHeading
      theme={theme}
      size={4}
      text="Are you importing or exporting?"
    />)

    return (
      <div className={CONTAINER}>
        {flash}

        <div className={trim(`
          ${WRAP_ROW('none')}
          ${defs.content_width} 
          layout-align-start-center
        `)}
        >
          <div className={`${WRAP_ROW(100)} layout-align-space-around-center`}>
            <div className={`${ROW(100)} layout-align-start-center`}>
              {ImportOrExport}
            </div>
            {directionButtons}
          </div>

          <div className={trim(`
            ${WRAP_ROW(100)} 
            ${styles.section}
            ${direction ? '' : styles.inactive}
          `)}
          >
            <div className={`${ROW(100)} layout-align-start-center`}>
              {ItemsOrContainers}
            </div>
            {CardLinkRowComponent}
          </div>

          <div
            className={
              `${styles.next_step_sec} flex-100 layout-row layout-align-center ` +
              `${styles.section} ${direction && loadType ? '' : styles.inactive}`
            }
          >
            <div
              style={{
                color: `${theme && hexToRGB(theme.colors.primary, 0.8)}`
              }}
              className={`${styles.mot_sec} ${WRAP_ROW(80)} layout-align-center`}
            >
              <div className={`${styles.next_step_btn_sec} ${ROW(100)} layout-align-end`}>
                <div className={`${COLUMN('none')} ${ALIGN_CENTER}`}>
                  <div className={`${ROW('none')} layout-align-center-start`}>
                    <p className={styles.mot_note}>
                      Availabilities will be shown for all applicable<br /> modes of transport for
                      your shipment
                    </p>
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

ChooseShipment.propTypes = {
  theme: PropTypes.theme,
  messages: PropTypes.arrayOf(PropTypes.string),
  selectLoadType: PropTypes.func.isRequired,
  scope: PropTypes.objectOf(PropTypes.any).isRequired
}

ChooseShipment.defaultProps = {
  theme: null,
  messages: []
}

export default ChooseShipment
