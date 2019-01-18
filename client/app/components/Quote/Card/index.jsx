import React, { PureComponent } from 'react'
import { get } from 'lodash'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'
import {
  switchIcon,
  gradientTextGenerator,
  numberSpacing,
  capitalize,
  formattedPriceValue,
  isQuote,
  onlyUnique
} from '../../../helpers'
import { ChargeIcons } from './ChargeIcons'
import QuoteChargeBreakdown from '../../QuoteChargeBreakdown/QuoteChargeBreakdown'
import { RoundButton } from '../../RoundButton/RoundButton'
import CollapsingContent from '../../CollapsingBar/Content'
import QuoteCardScheduleList from './ScheduleList'

class QuoteCard extends PureComponent {
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
    this.handleSelectSchedule = this.handleSelectSchedule.bind(this)
  }

  componentDidMount () {
    const { tenant } = this.props
    if (isQuote(tenant)) {
      this.setState({
        showSchedules: false
      })
    }
  }

  handleClickChecked () {
    const { onClickAdd } = this.props
    this.setState(prevState => ({
      isChecked: !prevState.isChecked
    }), () => onClickAdd(this.state.isChecked))
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

  shouldHideGrandTotal () {
    const { result, tenant } = this.props
    const { quote } = result
    const { scope } = tenant
    if (scope.hide_grand_total) return true
    if (scope.hide_converted_grand_total) {
      const topKeys = ['cargo', 'trucking_pre', 'trucking_on', 'import', 'export']
      const currencies = []
      topKeys.forEach((k) => {
        const charge = quote[k]
        if (charge) {
          if (['trucking_pre', 'trucking_on'].includes(k)) {
            currencies.push(charge.total.currency)
          }
          if (['import', 'export'].includes(k)) {
            Object.keys(charge)
              .filter(key => !['name', 'total', 'edited_total'].includes(key))
              .forEach((subKey) => {
                currencies.push(charge[subKey].currency)
              })
          }
          if (k === 'cargo') {
            Object.keys(charge)
              .filter(key => !['name', 'total', 'edited_total'].includes(key))
              .forEach((subKey) => {
                Object.keys(charge[subKey])
                  .filter(key => !['name', 'total', 'edited_total', 'unknown'].includes(key))
                  .forEach((cargoKey) => {
                    currencies.push(get(charge, [subKey, cargoKey, 'currency'], false))
                  })
              })
          }
        }
      })

      return currencies.filter(val => val).filter(onlyUnique).length > 1
    }

    return false
  }

  handleSelectSchedule (schedule) {
    const { result, selectResult } = this.props
    const ammendedSchedule = {
      ...schedule,
      charge_trip_id: result.meta.charge_trip_id
    }

    selectResult({ schedule: ammendedSchedule, total: result.quote.total })
  }

  handleSchedulesRequest (delta) {
    const { result, onScheduleRequest } = this.props
    const { schedules } = result
    const tripId = delta > 0 ? schedules[schedules.length - 1].trip_id : schedules[0].trip_id
    onScheduleRequest({ tripId, delta })
  }

  buttonToDisplay () {
    const { tenant, result, t } = this.props
    const { scope } = tenant
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

    if (scope.detailed_billing && result.schedules.length > 0 && result.schedules[0].eta !== null) {
      return (
        <div className="flex-40 layout-row layout-align-start-center" style={{ textAlign: 'left' }}>
          {showSchedules ? showPriceBreakdownBtn : showSchedulesBtn}
        </div>
      )
    }

    if (!scope.detailed_billing && result.schedules.length > 1) {
      return (
        <div className="flex-40 layout-row layout-align-start-center" style={{ textAlign: 'left' }} />
      )
    }

    if (!scope.detailed_billing && (!result.schedules || result.schedules.length < 1)) {
      return (
        <div className="flex-40 layout-row layout-align-start-center" style={{ textAlign: 'left' }} />
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
      aggregatedCargo,
      onClickAdd,
      t,
      shipment
    } = this.props
    const { scope } = tenant
    const {
      quote,
      meta,
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
    const calcVolume = aggregatedCargo && aggregatedCargo.id
      ? aggregatedCargo.volume
      : cargo.reduce((sum, cargoUnit) => (
        sum + 
        (+cargoUnit.dimension_x *
        +cargoUnit.dimension_y *
        +cargoUnit.dimension_z /
        1000000)
        * +cargoUnit.quantity), 0)

    const responsiveFlex = isQuote(tenant) ? 'flex-lg-80 offset-lg-20' : ''
    const hideGrandTotal = this.shouldHideGrandTotal()

    return (
      <div className={`
        flex-100 layout-row layout-wrap offer_result ${responsiveFlex}
        ${styles.wrapper} ${isQuote(tenant) && this.state.isChecked ? styles.wrapper_selected : ''}
      `}
      >
        {isQuote(tenant) && this.state.isChecked ? (
          <div className={`${styles.wrapper_gradient}`}>
            <div className={`${styles.gradient}`} style={gradientStyle} />
          </div>
        ) : ''}
        <div className={`flex-100 layout-row layout-align-start-center ${styles.container}`}>
          <div className={`flex-10 layout-row layout-align-center-center ${styles.mot_icon}`}>
            {switchIcon(result.meta.mode_of_transport, gradientStyle)}
          </div>
          <div className={`flex-55 layout-row layout-align-start-center ${styles.origin_destination}`}>
            <div className="layout-column layout-align-center-start flex-100">
              <p>
                {`${t('common:from')}: `}<span>{originHub.name}</span>
                
              </p>
              <p>
                {`${t('common:to')}: `}<span>{destinationHub.name}</span>
              </p>
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
            <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${styles.unit_info}`}>
              <div className={`flex-100 layout-row layout-align-start-center ${styles.unit_info}`}>
                <p className="flex-100 layout-row layout-align-start">
                  {`${capitalize(t('cargo:totalWeight'))}: `}
                  <span className="flex layout-row layout-align-end">
                  { ` ${numberSpacing(calcPayload, 2)} kg` }
                </span>
                </p>
               
              </div>
              <div className={`flex-100 layout-row layout-align-start-center ${styles.unit_info}`}>
                <p className="flex-100 layout-row layout-align-start">
                  {`${capitalize(t('cargo:totalVolume'))}: `}
                  <span className="flex layout-row layout-align-end">
                  { ` ${numberSpacing(calcVolume, 3)} m` }
                  <sup>3</sup>
                </span>
                
                </p>
                
              </div>
            </div>
            
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-start-center" style={{ paddingBottom: '18px' }}>

          { result.meta.carrier_name ? (
            <div className="flex-50 layout-row layout-align-center-center">
              {switchIcon(result.meta.mode_of_transport)}
              <p
                className="layout-row layout-align-end-center margin_5"
                style={{ paddingLeft: '7px' }}
              >
                {t('quote:carrier', { carrierName: result.meta.carrier_name })}
              </p>
            </div>
          ) : '' }
          {
            result.meta.service_level_count > 1
              ? (
                <div className="flex-50 layout-row layout-align-center-center">
                  <i className="flex-none fa fa-bell-o" style={{ paddingRight: '7px' }} />
                  <p className="layout-row layout-align-end-center margin_5">
                    {t('quote:service', { serviceLevel: capitalize(result.meta.service_level) })}
                  </p>
                </div>
              )
              : ''
          }
        </div>
        <CollapsingContent collapsed={!showSchedules}>
          <QuoteCardScheduleList
            schedules={schedules}
            theme={theme}
            finalResults={finalResults}
            originHub={originHub}
            destinationHub={destinationHub}
            onSelectSchedule={this.handleSelectSchedule}
          />
        </CollapsingContent>
        <CollapsingContent collapsed={showSchedules}>
          <QuoteChargeBreakdown
            theme={theme}
            scope={tenant.scope}
            quote={quote}
            meta={meta}
            cargo={cargo}
            trucking={shipment.trucking}
            mot={result.meta.mode_of_transport}
          />
        </CollapsingContent>
        <div className="flex-100 layout-wrap layout-align-start-stretch">
          <div className={`flex-100 layout-row layout-align-space-between-stretch layout-wrap ${styles.total_row}`}>

            <div className={`${isQuote(tenant) ? 'flex' : 'flex-40'} layout-row layout-align-start-center`}>
              <span style={{ textAlign: 'right' }}>{hideGrandTotal ? '' : t('common:total')}</span>
            </div>
            <div className={`${isQuote(tenant) ? 'flex-75' : 'flex'}  layout-row layout-align-end-center`}>
              <p style={!isQuote(tenant) ? { paddingRight: '18px' } : {}}>
                {hideGrandTotal
                  ? ''
                  : `${formattedPriceValue(quote.total.value)} ${quote.total.currency}`}
              </p>
              {isQuote(tenant) && onClickAdd ? (
                <div className="flex-gt-md-25 flex-33 layout-row layout-align-end-center">
                  <RoundButton
                    active={!this.state.isChecked}
                    flexContainer="100"
                    classNames={`ccb_select_quote pointy layout-row layout-align-center-center ${styles.add_button} ${!this.state.isChecked ? styles.shorter : styles.longer}`}
                    size="small"
                    handleNext={() => this.handleClickChecked()}
                    theme={theme}
                    text={!this.state.isChecked ? t('common:add') : t('common:remove')}
                  />
                </div>
              ) : ''}

            </div>
            <div className="flex-100 layout-row layout-align-end-center">
              {this.buttonToDisplay()}
              <div className="flex-60 layout-row layout-align-end-center layout-wrap">
                { scope.offer_disclaimers && scope.offer_disclaimers.length
                  ? scope.offer_disclaimers.map(disclaimer => <p className={`flex-100 ${styles.disclaimers}`}>{t(`disclaimers:${disclaimer}`, { carrier: result.meta.carrier_name })}</p>)
                  : ''
                }
              </div>
            </div>
          </div>

        </div>
      </div>
    )
  }
}

QuoteCard.defaultProps = {
  theme: null,
  truckingTime: 0,
  tenant: {},
  result: {},
  cargo: [],
  selectResult: null,
  onScheduleRequest: null,
  onClickAdd: null,
  pickup: false,
  isChecked: false,
  aggregatedCargo: {}
}

export default withNamespaces(['common', 'cargo', 'acronym', 'shipment', 'quote', 'disclaimers'])(QuoteCard)
