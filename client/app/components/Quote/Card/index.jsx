import React, { PureComponent } from 'react'
import styles from './index.scss'
import PropTypes from '../../../prop-types'
import { moment } from '../../../constants'
import { switchIcon, gradientTextGenerator, numberSpacing, capitalize } from '../../../helpers'
import { ChargeIcons } from './ChargeIcons'
import CollapsingBar from '../../CollapsingBar/CollapsingBar'

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
      isChecked: false
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

  render () {
    const {
      theme,
      tenant,
      schedule,
      cargo,
      handleInputChange,
      pickup,
      truckingTime
    } = this.props
    const {
      quote
    } = schedule
    const originHub = schedule.origin_hub
    const destinationHub = schedule.destination_hub
    const hasDates = !(!schedule.eta && !schedule.etd && !schedule.closing_date)
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
            {switchIcon(schedule.mode_of_transport, gradientStyle)}
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
        {hasDates ? (
          <div className={`flex-100 layout-row layout-align-start-center ${styles.dates_container}`}>
            <div className={`flex-75 layout-row ${styles.dates_row}`}>
              <div className="flex-25 layout-wrap layout-row layout-align-center-center">
                <div className="flex-100 layout-row">
                  <h4 className={styles.date_title}>{pickup ? 'Pickup Date' : 'Closing Date'}</h4>
                </div>
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
                  <h4 className={styles.date_title}>{`ETD ${QuoteCard.returnHubType(originHub)}`}</h4>
                </div>
                <div className="flex-100 layout-row">
                  <p className={`flex-none ${styles.sched_elem}`}>
                    {' '}
                    {moment(schedule.etd).format('DD-MM-YYYY')}{' '}
                  </p>
                </div>
              </div>
              <div className="flex-25 layout-wrap layout-row layout-align-center-center">
                <div className="flex-100 layout-row">
                  <h4 className={styles.date_title}>{`ETA ${QuoteCard.returnHubType(destinationHub)} `}</h4>
                </div>
                <div className="flex-100 layout-row">
                  <p className={`flex-none ${styles.sched_elem}`}>
                    {' '}
                    {moment(schedule.eta).format('DD-MM-YYYY')}{' '}
                  </p>
                </div>
              </div>
              <div className="flex-25 layout-wrap layout-row layout-align-center-center">
                <div className="flex-100 layout-row">
                  <h4 className={styles.date_title}> Estimated T/T </h4>
                </div>
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
              { schedule.carrier_name ? <div className="flex-100 layout-row layout-align-end-center">
                <i className="flex-none fa fa-ship" style={{ paddingRight: '7px' }} />
                <p className="layout-row layout-align-end-center no_m">{schedule.carrier_name}</p>
              </div> : '' }
              { schedule.vehicle_name ? <div className="flex-100 layout-row layout-align-end-center">
                <i className="flex-none fa fa-bell-o" style={{ paddingRight: '7px' }} />
                <p className="layout-row layout-align-end-center no_m">{capitalize(schedule.vehicle_name)}</p>
              </div> : '' }
            </div>
          </div>
        ) : (
          <div className="flex-100 layout-row layout-align-space-around-center">

            { schedule.carrier_name ? <div className="flex-50 layout-row layout-align-center-center">
              <i className="flex-none fa fa-ship" style={{ paddingRight: '7px' }} />
              <p className="layout-row layout-align-end-center margin_5">{`Carrier: ${schedule.carrier_name}`}</p>
            </div> : '' }
            { schedule.vehicle_name ? <div className="flex-50 layout-row layout-align-center-center">
              <i className="flex-none fa fa-bell-o" style={{ paddingRight: '7px' }} />
              <p className="layout-row layout-align-end-center margin_5">{`Service: ${capitalize(schedule.vehicle_name)}`}</p>
            </div> : '' }
          </div>)}
        {pricesArr}
        <div className="flex-100 layout-wrap layout-align-start-stretch">
          <div className={`flex-100 layout-row layout-align-start-stretch ${styles.total_row}`}>
            <div className="flex-50 layout-row layout-align-start-center">
              <span>Total</span>
            </div>
            <div className="flex-50 layout-row layout-align-end-center">
              <p>{numberSpacing(quote.total.value, 2)}&nbsp;{quote.total.currency}</p>
              <input
                className="pointy"
                name="checked"
                type="checkbox"
                onClick={e => this.handleClickChecked(e, schedule)}
                onChange={handleInputChange}
              />
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
  schedule: PropTypes.objectOf(PropTypes.any),
  cargo: PropTypes.arrayOf(PropTypes.any),
  handleInputChange: PropTypes.func,
  handleClick: PropTypes.func,
  pickup: PropTypes.bool
}

QuoteCard.defaultProps = {
  theme: null,
  truckingTime: 0,
  tenant: {},
  schedule: {},
  cargo: [],
  handleInputChange: null,
  handleClick: null,
  pickup: false
}

export default QuoteCard
