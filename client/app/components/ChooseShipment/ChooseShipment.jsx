import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import styles from './ChooseShipment.scss'
import { FlashMessages } from '../FlashMessages/FlashMessages'
import defs from '../../styles/default_classes.scss'
import { CardLinkRow } from '../CardLinkRow/CardLinkRow'
import { LOAD_TYPES } from '../../constants'
import { Tooltip } from '../Tooltip/Tooltip'
import { TextHeading } from '../TextHeading/TextHeading'
import { RoundButton } from '../RoundButton/RoundButton'
import { capitalize } from '../../helpers'

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
    console.log(loadType)
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
    const { theme, messages } = this.props
    const { loadType, direction } = this.state
    const flash = messages && messages.length > 0 ? <FlashMessages messages={messages} /> : ''
    const directionButtons = ['import', 'export'].map((dir) => {
      const buttonStyle = direction === dir ? styles.selected : styles.unselected
      return (
        <div
          className={`flex-none layout-row layout-align-center-center ${
            styles.direction_card
          } ${buttonStyle}`}
          onClick={() => this.setDirection(dir)}
        >
          <p className="flex-none">{capitalize(dir)}</p>
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
      <RoundButton
        theme={theme}
        size="small"
        text="Next Step"
        iconClass="fa-chevron-right"
      />
    )
    return (
      <div className={`${styles.card_link_row} layout-row flex-100 layout-align-center`}>
        {flash}
        <div
          className={`flex-none ${
            defs.content_width
          } layout-row layout-align-start-center layout-wrap`}
        >
          <div className={` ${styles.header} flex-100 layout-row layout-align-start-center`}>
            <div className="flex-none">
              <TextHeading theme={theme} size={1} text="Choose your shipment type:   " />
            </div>
            <Tooltip theme={theme} icon="fa-info-circle" text="shipment_mots" />
          </div>
          <div className="flex-100 layout-row layout-align-space-around-center">
            {directionButtons}
          </div>
          <CardLinkRow theme={theme} cardArray={this.state.cards} selectedType={loadType} />
          <div className="flex-100 layout-row layout-align-end-center">
            {loadType && direction ? activeBtn : disabledBtn}
          </div>
        </div>
      </div>
    )
  }
}

ChooseShipment.propTypes = {
  theme: PropTypes.theme,
  messages: PropTypes.arrayOf(PropTypes.string),
  selectLoadType: PropTypes.func.isRequired
}

ChooseShipment.defaultProps = {
  theme: null,
  messages: []
}

export default ChooseShipment
