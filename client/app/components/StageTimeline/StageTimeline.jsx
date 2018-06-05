import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { v4 } from 'uuid'
import styles from './StageTimeline.scss'
import defs from '../../styles/default_classes.scss'
import { capitalize } from '../../helpers/stringTools'
import { Tooltip } from '../Tooltip/Tooltip'
import { gradientTextGenerator, gradientGenerator } from '../../helpers/gradient'

export default class StageTimeline extends Component {
  constructor (props) {
    super(props)
    this.state = { }
  }
  generateStageBox (index) {
    const { theme } = this.props
    const gradientStyle = theme && theme.colors
      ? gradientTextGenerator(theme.colors.brightPrimary, theme.colors.brightSecondary)
      : theme.colors.brightPrimary

    const gradientCircle = theme && theme.colors
      ? gradientGenerator(theme.colors.brightPrimary, theme.colors.brightSecondary)
      : theme.colors.brightPrimary

    let stageBox
    if (index === this.props.currentStageIndex) {
      stageBox = (
        <div className={styles.wrapper_shop_stage_current} >
          <div
            className={`${styles.shop_stage_current} flex-none layout-row layout-align-center-center`}
          >
            <h3 className="flex-none" style={gradientStyle}>
              { index + 1 }
            </h3>
          </div>
          <div className={styles.shop_stage_current_border} style={gradientCircle} />
        </div>
      )
    } else {
      stageBox = (
        <div
          className={`${styles.shop_stage_yet} layout-row layout-align-center-center`}
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
    console.log(this.props.stages)
    const stageBoxes = this.props.stages.map((stage, i) => (
      <div
        key={v4()}
        style={{ position: 'relative' }}
        className="layout-column layout-align-start-center flex-none"
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
            <div name="timeline-Box" className={`${styles.line_box} flex-none layout-row layout-wrap layout-align-space-between`}>
              <div name="timeline-Line" className={` ${styles.line} flex-none layout-align-center-center`} />
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
  stages: PropTypes.arrayOf(Number),
  setStage: PropTypes.func.isRequired,
  currentStageIndex: PropTypes.number
}

StageTimeline.defaultProps = {
  currentStageIndex: 0,
  theme: null,
  stages: []
}
