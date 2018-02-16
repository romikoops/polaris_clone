import React, { Component } from 'react'
import styles from './ShopStageView.scss'
import PropTypes from '../../prop-types'
import defs from '../../styles/default_classes.scss'
import { SHIPMENT_STAGES } from '../../constants'
import { gradientTextGenerator } from '../../helpers'

export class ShopStageView extends Component {
  constructor (props) {
    super(props)
    this.state = {
    }
  }
  componentWillReceiveProps (nextProps) {
    this.setStageHeader(nextProps.currentStage)
  }

  setStageHeader (currentStage) {
    const { header } = SHIPMENT_STAGES.find(stage => stage.step === currentStage)
    this.setState({ stageHeader: header })
  }

  stageFunction (stage) {
    const { theme } = this.props
    const gradientStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.brightPrimary, theme.colors.brightSecondary)
        : theme.colors.brightPrimary
    let stageBox
    if (stage.step < this.props.currentStage) {
      stageBox = (
        <div
          className={`${styles.shop_stage_past} flex-none layout-column layout-align-center-center`}
          onClick={() => this.props.setStage(stage)}
        >
          <i className="fa fa-check flex-none clip" style={gradientStyle} />
        </div>
      )
    } else if (stage.step === this.props.currentStage) {
      stageBox = (
        <div className={styles.wrapper_shop_stage_current}>
          <div
            className={`${
              styles.shop_stage_current
            } flex-none layout-column layout-align-center-center`}
          >
            <h3 className="flex-none" style={gradientStyle}>
              {' '}
              {stage.step}{' '}
            </h3>
          </div>
          <div style={gradientStyle} className={styles.shop_stage_current_border} />
        </div>
      )
    } else {
      stageBox = (
        <div className={`${styles.shop_stage_yet} layout-column layout-align-center-center`}>
          <h3 className="flex-none"> {stage.step} </h3>
        </div>
      )
    }
    return stageBox
  }
  render () {
    const stageBoxes = []
    SHIPMENT_STAGES.forEach((stage) => {
      stageBoxes.push(<div
        key={stage.step}
        className={`${styles.stage_box} flex-none layout-column layout-align-start-center`}
      >
        {this.stageFunction(stage)}
        <p className={`flex-none ${styles.stage_text}`}>{stage.text}</p>
      </div>)
    })
    return (
      <div className={`layout-row flex-100 layout-align-center layout-wrap ${styles.ss_view}`}>
        <div className={`${styles.shop_banner} layout-row flex-100 layout-align-center`}>
          <div className={styles.fade} />
          <div
            className={`layout-row ${defs.content_width} layout-wrap layout-align-start-center ${
              styles.banner_content
            }`}
          >
            <h3 className="flex-none header"> {this.props.shopType} </h3>
            <i className="fa fa-chevron-right fade" />
            <p className="flex-none fade"> {this.state.stageHeader} </p>
          </div>
        </div>
        <div className={`${styles.stage_row} layout-row flex-100 layout-align-center`}>
          <div className={`layout-row ${defs.content_width} layout-align-start-center`}>
            <div
              className={` ${styles.line_box} layout-row layout-wrap layout-align-center flex-none`}
            >
              <div className={` ${styles.line} flex-none`} />
              {stageBoxes}
            </div>
          </div>
        </div>
      </div>
    )
  }
}

ShopStageView.propTypes = {
  theme: PropTypes.theme,
  setStage: PropTypes.func.isRequired,
  currentStage: PropTypes.number,
  shopType: PropTypes.string.isRequired
}

ShopStageView.defaultProps = {
  currentStage: 1,
  theme: null
}

export default ShopStageView
