import React, { PureComponent } from 'react'
import styles from './index.scss'
import PropTypes from '../../../prop-types'
import { moment } from '../../../constants'
import { switchIcon, gradientTextGenerator, numberSpacing, capitalize } from '../../../helpers'
import { ChargeIcons } from './ChargeIcons'
import CollapsingBar from '../../CollapsingBar/CollapsingBar'
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
  static determineSubKey (key) {
    switch (key) {
      case 'trucking_lcl' || 'trucking_fcl':
        return 'Trucking Rate'

      default:
        return key
    }
  }
  constructor (props) {
    super(props)
    this.state = {
      expander: {},
      isChecked: false,
      showSchedules: true
    }
    this.handleClickChecked = this.handleClickChecked.bind(this)
  }
  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }
  handleClickChecked (e, value) {
    const { handleClick } = this.props
    this.setState({
      isChecked: e.target.checked
    })

    return handleClick(e, value)
  }
  toggleShowSchedules (key) {
    this.setState(prevState => (
      {
        showSchedules: !prevState.showSchedules
      }
    ), () => this.toggleExpander(key))
  }

  selectSchedule (schedule) {
    const { result, selectResult } = this.props
    selectResult({ schedule, total: result.quote.total })
  }

  render () {
    const {
      theme,
      tenant,
      result,
      cargo,
      handleInputChange,
      pickup,
      truckingTime,
      isQuotationTool
    } = this.props
    const {
      quote,
      schedules
    } = result
    const {
      showSchedules
    } = this.state
    const originHub = result.meta.origin_hub
    const destinationHub = result.meta.destination_hub
    const hasDates = result.schedules && result.schedules.length > 0 && result.schedules[0].etd !== null
    const gradientStyle = gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
    const calcPayload = cargo.reduce((a, b) => ({ total: a.payload_in_kg + b.payload_in_kg }))
    const pricesArr = Object.keys(quote).splice(2).length !== 0 ? (
      Object.keys(quote).splice(2).map(key => (<CollapsingBar
        showArrow
        collapsed={!this.state.expander[`${key}`]}
        theme={theme}
        contentStyle={styles.sub_price_row_wrapper}
        headerWrapClasses="flex-100 layout-row layout-wrap layout-align-start-center"
        handleCollapser={() => this.toggleExpander(`${key}`)}
        mainWrapperStyle={{ borderTop: '1px solid #E0E0E0', minHeight: '50px' }}
        contentHeader={(
          <div className={`flex-100 layout-row layout-align-start-center ${styles.price_row}`}>
            <div className="flex-none layout-row layout-align-start-center" />
            <div className="flex-45 layout-row layout-align-start-center">
              {key === 'trucking_pre' ? (
                <span>Pick-up</span>
              ) : ''}
              {key === 'trucking_on' ? (
                <span>Delivery</span>
              ) : ''}
              <span>{key === 'trucking_pre' || key === 'trucking_on' ? '' : capitalize(key)}</span>
            </div>
            <div className="flex-50 layout-row layout-align-end-center">
              <p>{numberSpacing(quote[`${key}`].total.value, 2)}&nbsp;{quote.total.currency}</p>
            </div>
          </div>
        )}
        content={Object.entries(quote[`${key}`])
          .map(array => array.filter(value =>
            value !== 'total' && value !== 'edited_total'))
          .filter(value => value.length !== 1).map((price) => {
            const subPrices = (<div className={`flex-100 layout-row layout-align-start-center ${styles.sub_price_row}`}>
              <div className="flex-45 layout-row layout-align-start-center">
                <span>{key === 'cargo' ? 'Freight rate' : QuoteCard.determineSubKey(price[0])}</span>
              </div>
              <div className="flex-50 layout-row layout-align-end-center">
                <p>{numberSpacing(price[1].value || price[1].total.value, 2)}&nbsp;{quote.total.currency}</p>
              </div>
            </div>)

            return subPrices
          })}
      />))
    ) : ''

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
              {moment(schedule.eta).diff(schedule.etd, 'days')}
              {' Days'}
            </p>
          </div>
        </div>
      </div>
      <div className="flex-25 layout-row layout-wrap" style={{ textAlign: 'right' }}>
        <RoundButton
          size="small"
          handleNext={() => this.selectSchedule(schedule)}
          theme={theme}
          text="Select"
        />
      </div>
    </div>))

    const showPriceBreakdownBtn = (
      <div
        className={`flex layout-row layout-align-start-center pointy ${styles.view_switch}`}
        onClick={() => this.toggleShowSchedules('prices')}
      >
        <p className="flex-none">View Price Breakdown</p>
      </div>
    )
    const showSchedulesBtn = hasDates ? (
      <div
        className={`flex layout-row layout-align-start-center pointy ${styles.view_switch}`}
        onClick={() => this.toggleShowSchedules('schedules')}
      >
        <p className="flex-none">View Schedules</p>
      </div>
    ) : (<div
      className="flex layout-row layout-align-center-center"
    />)

    return (
      <div
        className={`flex-100 layout-row layout-wrap ${styles.wrapper} ${this.state.isChecked ? styles.wrapper_selected : ''}`}
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
              <p>From: <span>{originHub.name}</span></p>
              <p>To: <span>{destinationHub.name}</span></p>
            </div>
          </div>
          <div className="flex layout-row layout-wrap layout-align-end-center">
            <div className={`flex-100 layout-row layout-wrap layout-align-end-center ${styles.charge_icons}`}>
              <ChargeIcons
                theme={theme}
                tenant={tenant}
                onCarriage={quote.trucking_on}
                preCarriage={quote.trucking_pre}
                originFees={quote.export}
                destinationFees={quote.import}
              />
            </div>
            <div className={`flex-100 layout-row layout-wrap layout-align-end-center ${styles.unit_info}`}>
              <p className="flex-100 layout-row layout-align-end-center">
                Kg:&nbsp; <span>{`${numberSpacing(calcPayload.total, 1)} kg`}</span>
              </p>
            </div>
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-space-around-center" style={{ paddingBottom: '18px' }}>

          { result.meta.carrier_name ? <div className="flex-50 layout-row layout-align-center-center">
            <i className="flex-none fa fa-ship" style={{ paddingRight: '7px' }} />
            <p className="layout-row layout-align-end-center margin_5">{`Carrier: ${result.meta.carrier_name}`}</p>
          </div> : '' }
          { result.meta.service_level ? <div className="flex-50 layout-row layout-align-center-center">
            <i className="flex-none fa fa-bell-o" style={{ paddingRight: '7px' }} />
            <p className="layout-row layout-align-end-center margin_5">{`Service: ${capitalize(result.meta.service_level)}`}</p>
          </div> : '' }
        </div>

        <CollapsingContent
          collapsed={!showSchedules}
          content={(
            <div className="flex-100 layout-wrap layout-row">
              <div className={`flex-100 layout-row ${styles.dates_row} ${styles.dates_container} ${styles.dates_header}`}>
                <div className="flex-75 layout-row">
                  <div className="flex-25 layout-row">
                    <h4 className={styles.date_title}>{pickup ? 'Pickup Date' : 'Closing Date'}</h4>
                  </div>
                  <div className="flex-25 layout-row">
                    <h4 className={styles.date_title}>{`ETD ${QuoteCard.returnHubType(originHub)}`}</h4>
                  </div>
                  <div className="flex-25 layout-row">
                    <h4 className={styles.date_title}>{`ETA ${QuoteCard.returnHubType(destinationHub)} `}</h4>
                  </div>
                  <div className="flex-25 layout-row">
                    <h4 className={styles.date_title}> Estimated T/T </h4>
                  </div>
                </div>
                <div className="flex-25 layout-row" />
              </div>

              {schedulesArr}
            </div>
          )}
        />
        <CollapsingContent
          collapsed={showSchedules}
          content={pricesArr}
        />
        <div className="flex-100 layout-wrap layout-align-start-stretch">
          <div className={`flex-100 layout-row layout-align-space-between-stretch ${styles.total_row}`}>
            <div className="flex-60 layout-row layout-align-start-center" style={{ textAlign: 'left' }}>
              {showSchedules ? showPriceBreakdownBtn : showSchedulesBtn}
            </div>
            <div className="flex-10 layout-row layout-align-start-center">
              <span style={{ textAlign: 'right' }}>Total</span>
            </div>
            <div className="flex-35 layout-row layout-align-end-center">
              <p style={!isQuotationTool ? { paddingRight: '18px' } : {}}>{numberSpacing(quote.total.value, 2)}&nbsp;{quote.total.currency}</p>
              {isQuotationTool ? (
                <input
                  className="pointy"
                  name="checked"
                  type="checkbox"
                  onClick={e => this.handleClickChecked(e, result)}
                  onChange={handleInputChange}
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
  tenant: PropTypes.tenant,
  truckingTime: PropTypes.number,
  result: PropTypes.objectOf(PropTypes.any),
  cargo: PropTypes.arrayOf(PropTypes.any),
  handleInputChange: PropTypes.func,
  handleClick: PropTypes.func,
  selectResult: PropTypes.func,
  pickup: PropTypes.bool,
  isQuotationTool: PropTypes.bool
}

QuoteCard.defaultProps = {
  theme: null,
  truckingTime: 0,
  tenant: {},
  result: {},
  cargo: [],
  handleInputChange: null,
  selectResult: null,
  handleClick: null,
  pickup: false,
  isQuotationTool: false
}

export default QuoteCard
