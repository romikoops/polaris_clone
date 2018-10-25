import React, { PureComponent } from 'react'
import { translate } from 'react-i18next'
import styles from './index.scss'
import PropTypes from '../../../prop-types'
import { moment } from '../../../constants'
import {
  switchIcon,
  gradientTextGenerator,
  numberSpacing,
  capitalize,
  formattedPriceValue
} from '../../../helpers'
import { ChargeIcons } from './ChargeIcons'
import QuoteChargeBreakdown from '../../QuoteChargeBreakdown/QuoteChargeBreakdown'
import { RoundButton } from '../../RoundButton/RoundButton'
import CollapsingContent from '../../CollapsingBar/Content'

class QuoteCard extends PureComponent {
  static returnHubType (hub) {
    let hubType = ''
    switch (hub.hub_type) {
      case 'ocean':
        hubType = 'Port'
        break
      case 'air':
        hubType = 'Airport'
        break
      case 'rail':
        hubType = 'Railyard'
        break
      case 'truck':
        hubType = 'Depot'
        break
      default:
        break
    }

    return hubType
  }
  constructor (props) {
    super(props)
    this.state = {
      isChecked: props.isChecked,
      showSchedules: (props.result &&
        props.result.schedules &&
        props.result.schedules.length > 0 &&
        props.result.schedules[0].etd !== null),
      expander: {}
    }
    this.handleClickChecked = this.handleClickChecked.bind(this)
  }
  componentDidMount () {
    const { isQuotationTool } = this.props
    if (isQuotationTool) {
      this.setState({
        showSchedules: false
      })
    }
  }
  handleClickChecked () {
    const { handleClick } = this.props
    this.setState(prevState => ({
      isChecked: !prevState.isChecked
    }), () => handleClick(this.state.isChecked))
  }
  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }
  toggleShowSchedules (key) {
    this.setState(prevState => ({
      showSchedules: !prevState.showSchedules
    }
    ), () => this.toggleExpander(key))
  }

  selectSchedule (schedule) {
    const { result, selectResult } = this.props
    const ammendedSchedule = {
      ...schedule,
      charge_trip_id: result.meta.charge_trip_id
    }

    selectResult({ schedule: ammendedSchedule, total: result.quote.total })
  }

  handleSchedulesRequest (delta) {
    const { result, handleScheduleRequest } = this.props
    const { schedules } = result
    const tripId = delta > 0 ? schedules[schedules.length - 1].trip_id : schedules[0].trip_id
    handleScheduleRequest({ tripId, delta })
  }

  buttonToDisplay () {
    const { tenant, result, t } = this.props
    const { scope } = tenant.data
    const { showSchedules } = this.state
    const showPriceBreakdownBtn = (
      <div
        className={`flex layout-row layout-align-start-center pointy ${styles.view_switch}`}
        onClick={() => this.toggleShowSchedules('prices')}
      >
        <p className="flex-none">{t('quote:viewPriceBreakdown')}</p>
      </div>
    )
    const showSchedulesBtn = (
      <div
        className={`flex layout-row layout-align-start-center pointy ${styles.view_switch}`}
        onClick={() => this.toggleShowSchedules('schedules')}
      >
        <p className="flex-none">{t('quote:viewSchedules')}</p>
      </div>
    )
    if (scope.detailed_billing && result.schedules.length > 1) {
      return (
        <div className="flex-50 layout-row layout-align-start-center" style={{ textAlign: 'left' }}>
          {showSchedules ? showPriceBreakdownBtn : showSchedulesBtn}
        </div>
      )
    } else if (!scope.detailed_billing && result.schedules.length > 1) {
      return (
        <div className="flex-50 layout-row layout-align-start-center" style={{ textAlign: 'left' }} />
      )
    } else if (!scope.detailed_billing && (!result.schedules || result.schedules.length < 1)) {
      return (
        <div className="flex-50 layout-row layout-align-start-center" style={{ textAlign: 'left' }} />
      )
    }

    return ''
  }

  render () {
    const {
      theme,
      tenant,
      result,
      cargo,
      pickup,
      truckingTime,
      isQuotationTool,
      aggregatedCargo,
      t
    } = this.props
    const { scope } = tenant.data
    const {
      quote,
      schedules,
      finalResults
    } = result
    const {
      showSchedules
    } = this.state
    const originHub = result.meta.origin_hub
    const destinationHub = result.meta.destination_hub
    const gradientStyle = gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
    const calcPayload = aggregatedCargo && aggregatedCargo.id
      ? aggregatedCargo.weight
      : cargo.reduce((sum, cargoUnit) => (sum + +cargoUnit.payload_in_kg * +cargoUnit.quantity), 0)

    const schedulesArr = schedules.map(schedule => (<div className={`flex-100 layout-row layout-align-start-center ${styles.dates_container}`}>
      <div className={`flex-75 layout-row ${styles.dates_row}`}>
        <div className="flex-25 layout-wrap layout-row layout-align-center-center">
          <div className="flex-100 layout-row">
            <p className={`flex-none ${styles.sched_elem}`}>
              {' '}
              {pickup
                ? moment(schedule.closing_date).subtract(truckingTime, 'seconds').format('DD-MM-YYYY')
                : moment(schedule.closing_date).format('DD-MM-YYYY')}{' '}
            </p>
          </div>
        </div>
        <div className="flex-25 layout-wrap layout-row layout-align-center-center">
          <div className="flex-100 layout-row">
            <p className={`flex-none ${styles.sched_elem}`}>
              {' '}
              {moment(schedule.etd).format('DD-MM-YYYY')}{' '}
            </p>
          </div>
        </div>
        <div className="flex-25 layout-wrap layout-row layout-align-center-center">
          <div className="flex-100 layout-row">
            <p className={`flex-none ${styles.sched_elem}`}>
              {' '}
              {moment(schedule.eta).format('DD-MM-YYYY')}{' '}
            </p>
          </div>
        </div>
        <div className="flex-25 layout-wrap layout-row layout-align-center-center">
          <div className="flex-100 layout-row">
            <p className={`flex-none ${styles.sched_elem}`}>
              {' '}
              {moment(schedule.eta).diff(schedule.etd, t('common:days'))}
              {t('common:capitalDays')}
            </p>
          </div>
        </div>
      </div>
      <div className="flex-25 layout-row layout-wrap" style={{ textAlign: 'right' }}>
        <RoundButton
          classNames="quote_card_select"
          size="small"
          handleNext={() => this.selectSchedule(schedule)}
          theme={theme}
          text={t('common:select')}
        />
      </div>
    </div>))
    const firstSchedule = schedules[0]
    const lastSchedule = schedules[result.schedules.length - 1]
    const earlierDate = schedules[0] ? firstSchedule.closing_date : false
    const showEarlierBtn = earlierDate && moment(earlierDate).diff(moment(), t('common:days')) > 5

    return (
      <div
        className={`flex-100 layout-row layout-wrap offer_result ${styles.wrapper} ${this.state.isChecked ? styles.wrapper_selected : ''}`}
      >
        {this.state.isChecked ? (
          <div className={`${styles.wrapper_gradient}`}>
            <div className={`${styles.gradient}`} style={gradientStyle} />
          </div>
        ) : ''}
        <div className={`flex-100 layout-row layout-align-start-center ${styles.container}`}>
          <div className={`flex-10 layout-row layout-align-center-center ${styles.mot_icon}`}>
            {switchIcon(result.meta.mode_of_transport, gradientStyle)}
          </div>
          <div className={`flex-60 layout-row layout-align-start-center ${styles.origin_destination}`}>
            <div className="layout-column layout-align-center-start">
              <p>{t('common:from')}: <span>{originHub.name}</span></p>
              <p>{t('common:to')}: <span>{destinationHub.name}</span></p>
            </div>
          </div>
          <div className="flex layout-row layout-wrap layout-align-end-center">
            <div className={`flex-100 layout-row layout-wrap layout-align-end-center ${styles.charge_icons}`}>
              <ChargeIcons
                theme={theme}
                tenant={tenant}
                mot={result.meta.mode_of_transport}
                onCarriage={quote.trucking_on}
                preCarriage={quote.trucking_pre}
                originFees={quote.export}
                destinationFees={quote.import}
              />
            </div>
            <div className={`flex-100 layout-row layout-wrap layout-align-end-center ${styles.unit_info}`}>
              <p className="flex-100 layout-row layout-align-end-center">
                {capitalize(t('acronym:kg'))}:&nbsp;
                <span>
                  { numberSpacing(calcPayload, 1) } kg
                </span>
              </p>
            </div>
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-start-center" style={{ paddingBottom: '18px' }}>

          { result.meta.carrier_name ? <div className="flex-50 layout-row layout-align-center-center">
            <i className="flex-none fa fa-ship" style={{ paddingRight: '7px' }} />
            <p className="layout-row layout-align-end-center margin_5">{t('quote:carrier', { carrierName: result.meta.carrier_name })}</p>
          </div> : '' }
          { result.meta.service_level ? <div className="flex-50 layout-row layout-align-center-center">
            <i className="flex-none fa fa-bell-o" style={{ paddingRight: '7px' }} />
            <p className="layout-row layout-align-end-center margin_5">{t('quote:service', { serviceLevel: capitalize(result.meta.service_level) })}</p>
          </div> : '' }
        </div>

        <CollapsingContent
          collapsed={!showSchedules}
          content={(
            <div className="flex-100 layout-wrap layout-row">
              <div className={`flex-100 layout-row ${styles.dates_row} ${styles.dates_container} ${styles.dates_header}`}>
                <div className="flex-75 layout-row">
                  <div className="flex-25 layout-row">
                    <h4 className={styles.date_title}>{pickup ? t('common:pickupDate') : t('common:closingDate')}</h4>
                  </div>
                  <div className="flex-25 layout-row">
                    <h4 className={styles.date_title}>{`${t('common:etd')} ${QuoteCard.returnHubType(originHub)}`}</h4>
                  </div>
                  <div className="flex-25 layout-row">
                    <h4 className={styles.date_title}>{`${t('common:eta')} ${QuoteCard.returnHubType(destinationHub)} `}</h4>
                  </div>
                  <div className="flex-25 layout-row">
                    <h4 className={styles.date_title}>{t('quote:estimatedTT')}</h4>
                  </div>
                </div>
                <div className="flex-25 layout-row" />
              </div>

              {schedulesArr}
              <div className={`flex-100 layout-row layout-align-space-around-center ${styles.date_btns}`}>
                <div
                  className={`flex-30 layout-row layout-align-center-center
                   ${showEarlierBtn ? '' : styles.disabled} ${styles.date_btn}`}
                  onClick={showEarlierBtn ? () => this.handleSchedulesRequest(-1) : null}
                >
                  <div className="flex-none layout-row layout-align-space-around-center">
                    <i className="flex-none fa fa-chevron-left" />
                    <p className="flex-none">{t('common:earlierDeparturesBase')}</p>
                  </div>
                </div>
                <div className="flex-40 layout-row layout-align-center">
                  <p className="flex-100 center">
                    {`${moment(firstSchedule.closing_date).format('ll')} -
                      ${moment(lastSchedule.closing_date).format('ll')}
                    `}
                  </p>
                </div>
                <div
                  className={`flex-30 layout-row layout-align-center-center
                  ${!finalResults ? '' : styles.disabled} ${styles.date_btn} ${styles.date_btn}`}
                  onClick={!finalResults ? () => this.handleSchedulesRequest(1) : null}
                >
                  <div className="flex-none layout-row layout-align-space-around-center">
                    <p className="flex-none">{t('common:laterDeparturesBase')}</p>
                    <i className="flex-none fa fa-chevron-right" />
                  </div>
                </div>
              </div>
            </div>
          )}
        />
        <CollapsingContent collapsed={showSchedules}>
          <QuoteChargeBreakdown
            theme={theme}
            scope={tenant.data.scope}
            quote={quote}
          />
        </CollapsingContent>
        <div className="flex-100 layout-wrap layout-align-start-stretch">
          <div className={`flex-100 layout-row layout-align-space-between-stretch ${styles.total_row}`}>
            {this.buttonToDisplay()}
            <div className={`${isQuotationTool ? 'flex' : 'flex-10'} layout-row layout-align-start-center`}>
              <span style={{ textAlign: 'right' }}>{scope.hide_grand_total ? '' : t('common:total')}</span>
            </div>
            <div className="flex layout-row layout-align-end-center">
              <p style={!isQuotationTool ? { paddingRight: '18px' } : {}}>
                {
                  scope.hide_grand_total
                    ? ''
                    : `${formattedPriceValue(quote.total.value)} ${quote.total.currency}`
                }
              </p>
              {isQuotationTool ? (
                <RoundButton
                  active={!this.state.isChecked}
                  classNames={`pointy layout-row layout-align-center-center ${styles.add_button} ${!this.state.isChecked ? styles.shorter : styles.longer}`}
                  size="small"
                  handleNext={() => this.handleClickChecked()}
                  theme={theme}
                  text={!this.state.isChecked ? t('common:add') : t('common:remove')}
                />
              ) : ''}

            </div>
          </div>
        </div>
      </div>
    )
  }
}

QuoteCard.propTypes = {
  theme: PropTypes.theme,
  t: PropTypes.func.isRequired,
  tenant: PropTypes.tenant,
  truckingTime: PropTypes.number,
  result: PropTypes.objectOf(PropTypes.any),
  cargo: PropTypes.arrayOf(PropTypes.any),
  handleClick: PropTypes.func,
  selectResult: PropTypes.func,
  handleScheduleRequest: PropTypes.func,
  pickup: PropTypes.bool,
  isChecked: PropTypes.bool,
  isQuotationTool: PropTypes.bool,
  aggregatedCargo: PropTypes.objectOf(PropTypes.string)
}

QuoteCard.defaultProps = {
  theme: null,
  truckingTime: 0,
  tenant: {},
  result: {},
  cargo: [],
  selectResult: null,
  handleScheduleRequest: null,
  handleClick: null,
  pickup: false,
  isQuotationTool: false,
  isChecked: false,
  aggregatedCargo: {}
}

export default translate(['common', 'cargo', 'acronym', 'shipment', 'quote'])(QuoteCard)
