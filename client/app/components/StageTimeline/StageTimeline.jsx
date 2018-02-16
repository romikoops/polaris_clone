import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './StageTimeline.scss'
import defs from '../../styles/default_classes.scss'
import { capitalize } from '../../helpers/stringTools'
import { Tooltip } from '../Tooltip/Tooltip'

export class StageTimeline extends Component {
  constructor (props) {
    super(props)
    this.state = {
      currentStageIndex: props.currentStageIndex
    }
  }
  generateStageBox (index) {
    const { theme } = this.props
    const gradientStyle = {
      background: theme ? `-webkit-linear-gradient(left, ${theme.colors.brightPrimary} 0%, ${theme.colors.brightSecondary} 100%)` : 'black'
    }

    let stageBox
    if (index === this.props.currentStageIndex) {
      stageBox = (
        <div className={styles.wrapper_shop_stage_current} >
          <div
            className={`${styles.shop_stage_current} flex-none layout-column layout-align-center-center`}
          >
            <h3 className="flex-none" style={gradientStyle}>
              { index + 1 }
            </h3>
          </div>
          <div className={styles.shop_stage_current_border} style={gradientStyle} />
        </div>
      )
    } else {
      stageBox = (
        <div
          className={`${styles.shop_stage_yet} layout-column layout-align-center-center`}
        >
          <h3 className="flex-none"> { index + 1 } </h3>
        </div>
      )
    }
    return stageBox
  }

  render () {
    const { theme } = this.props
    const currentStage = index => index === this.props.currentStageIndex
    const stageBoxes = this.props.stages.map((stage, i) => (
      <div
        key={i}
        className="layout-column layout-align-start-center"
        onClick={() => this.props.setStage(i)}
      >
        { this.generateStageBox(i) }
        <p className={`flex-none ${styles.stage_text} ${currentStage(i) ? styles.current : ''}`}>
          { capitalize(stage) }
          <Tooltip
            theme={theme}
            icon="fa-info-circle"
            text={stage === 'notifyees' ? 'notifyee' : stage}
          />
        </p>
      </div>
    ))
    return (
      <div className="layout-row flex-100 layout-align-center layout-wrap">
        <div className="layout-row flex-100 layout-align-center">
          <div className={`layout-row ${defs.content_width} layout-align-start-center`}>
            <div className={`${styles.line_box} layout-row layout-wrap layout-align-space-between`}>
              <div className={` ${styles.line} flex-none`} />
              { stageBoxes }
            </div>
          </div>
        </div>
      </div>
    )
  }
}

StageTimeline.propTypes = {
  theme: PropTypes.theme,
  stages: PropTypes.array,
  setStage: PropTypes.func.isRequired,
  currentStageIndex: PropTypes.number
}

StageTimeline.defaultProps = {
  currentStageIndex: 0,
  theme: null,
  stages: []
}
