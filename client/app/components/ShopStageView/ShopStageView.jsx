import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { cookieActions } from '../../actions'
import styles from './ShopStageView.scss'
import PropTypes from '../../prop-types'
import defs from '../../styles/default_classes.scss'
import { SHIPMENT_STAGES, QUOTE_STAGES } from '../../constants'
import {
  gradientTextGenerator, gradientGenerator, history, isQuote
} from '../../helpers'
import HelpContact from '../Help/Contact'

class ShopStageView extends Component {
  static goBack () {
    history.goBack()
  }

  constructor (props) {
    super(props)
    this.state = {}
    this.applicableStages =
      this.props.tenant.scope.closed_quotation_tool ||
        this.props.tenant.scope.open_quotation_tool
        ? QUOTE_STAGES : SHIPMENT_STAGES
  }

  componentWillReceiveProps (nextProps) {
    this.setStageHeader(nextProps.currentStage)
  }

  componentWillUnmount () {
    this.props.cookieDispatch.updateCookieHeight({ fixedHeight: 0 })
  }

  setStageHeader (currentStage) {
    const { header } = this.applicableStages.find(stage => stage.step === currentStage) || {}
    this.setState({ stageHeader: header })
  }

  handleClickStage (stage) {
    if (this.props.disabledClick) return

    this.props.setStage(stage)
  }

  showContactHelp () {
    this.setState({ showHelp: !this.state.showHelp })
  }

  stageBoxCircle (stage) {
    const { theme } = this.props
    const gradientStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.brightPrimary, theme.colors.brightSecondary)
        : theme.colors.brightPrimary

    const gradientCircle =
      theme && theme.colors
        ? gradientGenerator(theme.colors.brightPrimary, theme.colors.brightSecondary)
        : theme.colors.brightPrimary

    if (stage.step < this.props.currentStage) {
      return (
        <div
          className={
            `${styles.shop_stage_past} flex-none ` +
            `${this.props.disabledClick ? '' : 'pointy'} ` +
            'layout-column layout-align-center-center'
          }
          onClick={() => this.handleClickStage(stage)}
        >
          <i className="fa fa-check flex-none clip" style={gradientStyle} />
        </div>
      )
    }

    if (stage.step === this.props.currentStage) {
      return (
        <div className={styles.wrapper_shop_stage_current}>
          <div
            className={`layout-column layout-align-center-center ${
              styles.shop_stage_current
            } flex-none `}
          >
            <h3 className="flex-none" style={gradientStyle}>
              {' '}
              {stage.step}
              {' '}
            </h3>
          </div>
          <div style={gradientCircle} className={styles.shop_stage_current_border} />
        </div>
      )
    }

    return (
      <div className={`${styles.shop_stage_yet} layout-column layout-align-center-center`}>
        <h3 className="flex-none">
          {' '}
          {stage.step}
          {' '}
        </h3>
      </div>
    )
  }

  stageBox (stage) {
    return (
      <div
        key={stage.step}
        className={`${styles.stage_box} flex-none layout-column layout-align-start-center`}
      >
        {this.stageBoxCircle(stage)}
        <p className={`flex-none ${styles.stage_text}`}>{stage.text}</p>
      </div>
    )
  }

  render () {
    const {
      theme,
      hasNextStage,
      tenant,
      currentStage,
      t
    } = this.props
    const shouldHideNavButtons = currentStage > 5
    const stepBarShowStyle = shouldHideNavButtons ? styles.hide_nav_options : ''
    const { bookingProcessImage } = theme
    const bookingProcessImageWrapped = bookingProcessImage
      ? `url(${bookingProcessImage})`
      : "url('https://assets.itsmycargo.com/assets/cityimages/ssview_container_yard.jpg')"

    const { showHelp } = this.state
    const stageBoxes = this.applicableStages.map(stage => this.stageBox(stage))
    const gradientStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : theme.colors.primary

    const gradientCircle =
      theme && theme.colors
        ? gradientGenerator(theme.colors.primary, theme.colors.secondary)
        : theme.colors.primary
    const backBtn = (
      <div
        className={`${styles.stage_box} flex-none layout-column layout-align-start-center ${stepBarShowStyle}`}
        onClick={!shouldHideNavButtons ? () => ShopStageView.goBack() : null}
      >
        <div className={styles.wrapper_shop_stage_current}>
          <div
            className={`layout-column layout-align-center-center ${
              styles.shop_stage_current
            } flex-none `}
          >
            <i className="flex-none fa fa-chevron-left clip" style={gradientStyle} />
          </div>
          <div style={gradientCircle} className={styles.shop_stage_current_border} />
        </div>
        <p className={`flex-none ${styles.stage_text}`}>
          {t('common:previousStep')}
        </p>
      </div>
    )
    const help = (
      <div
        className="flex-none layout-row layout-align-center-center pointy"
        onClick={() => this.showContactHelp()}
      >
        <p className="flex-none">
          {t('help:needHelp')}
        </p>
        <i className="fa fa-question-circle" />
      </div>
    )
    const helpModal = showHelp ? <HelpContact tenant={tenant} parentToggle={() => this.showContactHelp()} /> : ''
    const fwdBtn = hasNextStage ? (
      <div
        className={`${styles.stage_box} flex-none layout-column layout-align-start-center`}
        onClick={() => this.props.goForward()}
      >
        <div className={styles.wrapper_shop_stage_current}>
          <div
            className={`layout-column layout-align-center-center ${
              styles.shop_stage_current
            } flex-none `}
          >
            <i className="flex-none fa fa-chevron-right clip" style={gradientStyle} />
          </div>
          <div style={gradientCircle} className={styles.shop_stage_current_border} />
        </div>
        <p className={`flex-none ${styles.stage_text}`}>
          {t('common:nextStep')}
        </p>
      </div>
    ) : (
      <div className={`${styles.stage_box} flex-none layout-column layout-align-start-center`} />
    )

    return (
      <div className="layout-row flex-100 layout-align-center layout-wrap">
        <div
          className={`${styles.shop_banner} layout-row flex-100 layout-align-center`}
          style={{ backgroundImage: bookingProcessImageWrapped }}
        >
          <div className={styles.fade} />
          <div
            className={`layout-row ${defs.content_width} layout-wrap layout-align-start-center ${
              styles.banner_content
            }`}
          >
            <h3 className="flex-none header">
              { isQuote(tenant) ? t('common:quotation') : t('common:booking') }
            </h3>
            <i className="fa fa-chevron-right fade" />
            <p className="flex-70 fade">
              {' '}
              {this.state.stageHeader}
              {' '}
            </p>
          </div>
        </div>
        <div
          className={`${styles.stage_row} layout-row flex-100 layout-align-center`}
          ref={(div) => {
            if (!div) return
            this.props.cookieDispatch.updateCookieHeight({ fixedHeight: div.offsetHeight })
          }}
        >
          {backBtn}
          <div>
            <div
              className={`${styles.line_box} layout-row layout-align-center flex-none ${stepBarShowStyle}`}
            >
              <div className={`${isQuote(tenant) ? styles.quote_line : styles.line} flex-none`} />
              {stageBoxes}
            </div>
          </div>
          {fwdBtn}
          {help}
        </div>
        {helpModal}
      </div>
    )
  }
}

ShopStageView.propTypes = {
  theme: PropTypes.theme,
  tenant: PropTypes.tenant,
  t: PropTypes.func.isRequired,
  setStage: PropTypes.func.isRequired,
  currentStage: PropTypes.number,
  disabledClick: PropTypes.bool,
  hasNextStage: PropTypes.bool,
  goForward: PropTypes.func,
  cookieDispatch: PropTypes.shape({
    updateCookieHeight: PropTypes.func
  }).isRequired
}

ShopStageView.defaultProps = {
  currentStage: 1,
  theme: null,
  tenant: {},
  disabledClick: false,
  hasNextStage: false,
  goForward: null
}

function mapDispatchToProps (dispatch) {
  return {
    cookieDispatch: bindActionCreators(cookieActions, dispatch)
  }
}

export default connect(null, mapDispatchToProps)(withNamespaces(['common', 'help'])(ShopStageView))
