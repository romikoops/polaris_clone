import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import styles from './ChooseShipment.scss'
import { FlashMessages } from '../FlashMessages/FlashMessages'
import defs from '../../styles/default_classes.scss'
import { CardLinkRow } from '../CardLinkRow/CardLinkRow'
import { LOAD_TYPES } from '../../constants'
import { RoundButton } from '../RoundButton/RoundButton'
import { capitalize, gradientTextGenerator, switchIcon, percentageToHex } from '../../helpers'

export class ChooseShipment extends Component {
  constructor (props) {
    super(props)
    const cards = LOAD_TYPES.map(loadType => ({
      name: loadType.name,
      img: loadType.img,
      code: loadType.code,
      options: { contained: true },
      handleClick: () => this.setLoadType(loadType.code)
    }))
    this.state = { cards }
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
    const { theme, scope, messages } = this.props
    const { loadType, direction } = this.state
    const flash = messages && messages.length > 0 ? <FlashMessages messages={messages} /> : ''
    const gradientStyle = theme && theme.colors ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary) : { color: 'black' }
    const directionButtons = ['import', 'export'].map((dir) => {
      const buttonStyle = direction === dir ? styles.selected : styles.unselected
      return (
        <div
          className={
            `${styles.direction_card} ${buttonStyle} ` +
            'flex-none layout-row layout-align-center-center'
          }
          onClick={() => this.setDirection(dir)}
        >
          <div className="flex-80 layout-row layout-align-space-between-center">
            <p className="flex-none">{capitalize(dir)}</p>
            {
              direction === dir
                ? <i className="flex-none fa fa-check clip" style={gradientStyle} />
                : ''
            }
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

    const modesOfTransportJSX = Object.keys(scope.modes_of_transport)
      .filter(mot => scope.modes_of_transport[mot])
      .map(mot => switchIcon(mot))

    return (
      <div className={`${styles.card_link_row} layout-row flex-100 layout-align-center`}>
        {flash}
        <div className={
          `flex-none ${defs.content_width} ` +
          'layout-row layout-align-start-center layout-wrap'
        }
        >
          <div className="flex-100 layout-row layout-align-space-around-center">
            { directionButtons }
          </div>
          <div className={
            `flex-100 layout-row ${styles.section} ` +
            `${direction ? '' : styles.inactive}`
          }
          >
            <CardLinkRow theme={theme} cardArray={this.state.cards} selectedType={loadType} />
          </div>
          <div className={
            `${styles.next_step_sec} flex-100 layout-row layout-align-center ` +
            `${styles.section} ${direction && loadType ? '' : styles.inactive}`
          }
          >
            <div
              className={`${styles.mot_sec} flex-80 layout-row layout-wrap layout-align-center`}
              style={{
                color: `${theme && theme.colors.primary + percentageToHex('80%')}`
              }}
            >
              <div className="flex-100">
                <hr />
              </div>
              <div className="flex-100 layout-row layout-align-center">
                <h3>Search results will include the following modes of transport</h3>
              </div>
              <div className={
                `${styles.mot_icons} flex-20 layout-row ` +
                'layout-align-space-around-center'
              }
              >
                { modesOfTransportJSX }
              </div>
              <div className={`${styles.next_step_btn_sec} flex-100 layout-row layout-align-center`}>
                { loadType && direction ? activeBtn : disabledBtn }
              </div>
              <div className="flex-100">
                <hr />
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
