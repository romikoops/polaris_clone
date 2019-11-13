import React, { PureComponent } from 'react'
import { get } from 'lodash'
import { withNamespaces } from 'react-i18next'
import { moment } from '../../../constants'
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
import RatesOverview from './Rates'
import NoteReader from '../Notes'
import UnitsWeight from '../../Units/Weight'
import Modal from '../../Modal/Modal'

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
    this.toggleNotesModal = this.toggleNotesModal.bind(this)
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

    selectResult({ schedule: ammendedSchedule, total: result.quote.total, meta: result.meta })
  }

  handleSchedulesRequest (delta) {
    const { result, onScheduleRequest } = this.props
    const { schedules } = result
    const tripId = delta > 0 ? schedules[schedules.length - 1].trip_id : schedules[0].trip_id
    onScheduleRequest({ tripId, delta })
  }

  buttonToDisplay () {
    const { tenant, result, t } = this.props
    const { scope, theme } = tenant
    const { showSchedules } = this.state
    const showPriceBreakdownBtn = (
      <RoundButton
        active
        size="full"
        classNames={`pointy layout-row layout-align-center-center ${styles.add_button}`}
        handleNext={() => this.toggleShowSchedules('prices')}
        theme={theme}
        text={t('quote:viewPriceBreakdown')}
      />
    )
    const showSchedulesBtn = (
      <RoundButton
        active
        size="full"
        classNames={`pointy layout-row layout-align-center-center ${styles.add_button}`}
        handleNext={() => this.toggleShowSchedules('schedules')}
        theme={theme}
        text={t('quote:viewSchedules')}
      />
    )

    if (scope.detailed_billing && result.schedules.length > 0 && result.schedules[0].eta !== null) {
      return (
        <div className="flex layout-row layout-align-start-center" style={{ textAlign: 'left' }}>
          {showSchedules ? showPriceBreakdownBtn : showSchedulesBtn}
        </div>
      )
    }

    if (!scope.detailed_billing && result.schedules.length > 1) {
      return (
        <div className="flex layout-row layout-align-start-center" style={{ textAlign: 'left' }} />
      )
    }

    if (!scope.detailed_billing && (!result.schedules || result.schedules.length < 1)) {
      return (
        <div className="flex layout-row layout-align-start-center" style={{ textAlign: 'left' }} />
      )
    }

    return ''
  }

  toggleNotesModal () {
    this.setState(prevState => ({ showNotesModal: !prevState.showNotesModal }))
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
      shipment,
      validUntil
    } = this.props
    const { scope } = tenant
    const {
      quote,
      meta,
      schedules,
      finalResults,
      notes
    } = result
    const {
      showSchedules,
      showNotesModal
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
        1000000) *
        +cargoUnit.quantity), 0)

    const responsiveFlex = isQuote(tenant) ? 'flex-lg-80 offset-lg-20' : ''
    const hideGrandTotal = this.shouldHideGrandTotal()
    const voyageInfo = get(scope, ['voyage_info'], {})
    const hasNotes = notes && notes.length > 0

    const notesModal = (
      <Modal
        component={(
          <NoteReader notes={notes} t={t} closeModal={this.toggleNotesModal} />
        )}
        verticalPadding="30px"
        horizontalPadding="40px"
        parentToggle={this.toggleNotesModal}
      />
    )
    const freeOutLabel = (<small>({t('common:freeOut')})</small>)

    return (
      <div className={`
        flex-100 layout-row layout-wrap offer_result ${responsiveFlex}
        ${styles.wrapper} ${isQuote(tenant) && this.state.isChecked ? styles.wrapper_selected : ''}
      `}
      >
        { showNotesModal && notesModal }
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
                {`${t('common:from')}: `}
                <span>
                  {originHub.name}
                  {originHub.free_out && freeOutLabel}
                </span>

              </p>
              <p>
                {`${t('common:to')}: `}
                <span>
                  {destinationHub.name}
                  {destinationHub.free_out && freeOutLabel}
                </span>
              </p>
            </div>
          </div>
          <div className="flex layout-row layout-wrap layout-align-end-center">
            { get(scope, ['quote_card', 'sections', 'charge_icons'], false) ? (
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
            ) : '' }
            <div className={`flex-100 layout-row layout-wrap layout-align-start-center ${styles.unit_info}`}>
              <div className={`flex-100 layout-row layout-align-start-center ${styles.unit_info}`}>
                <p className="flex-100 layout-row layout-align-start">
                  {`${capitalize(t('cargo:totalWeight'))}: `}
                  <UnitsWeight value={calcPayload} />
                </p>

              </div>
              { result.meta.load_type === 'cargo_item'
                ? (
                  <div className={`flex-100 layout-row layout-align-start-center ${styles.unit_info}`}>
                    <p className="flex-100 layout-row layout-align-start">
                      {`${capitalize(t('cargo:totalVolume'))}: `}
                      <span className="flex layout-row layout-align-end">
                        { ` ${numberSpacing(calcVolume, 3)} m` }
                        <sup>3</sup>
                      </span>

                    </p>

                  </div>
                ) : '' }
            </div>
          </div>
        </div>
        <div className={styles.details}>
          <div className={styles.details_row}>
            {voyageInfo.carrier && result.meta.carrier_name && (
              <div>
                {switchIcon(result.meta.mode_of_transport)}
                {t("quote:carrier", { carrierName: result.meta.carrier_name })}
              </div>
            )}
            {voyageInfo.service_level && result.meta.service_level && (
              <div>
                <i className="flex-none fa fa-bell-o" />
                {t("quote:service", { serviceLevel: capitalize(result.meta.service_level) })}
              </div>
            )}
            {validUntil && (
              <div>
                <i className="flex-none fa fa-clock-o" />
                {t("quote:validUntil", { date: moment(validUntil).utc().format('DD/MM/YYYY')}) }
              </div>
            )}
          </div>
          <div className={styles.details_row}>
            {voyageInfo.transshipmentVia && result.meta.transshipmentVia && (
              <div>
                <i className="flex-none fa fa-exchange" />
                {t("quote:transshipmentVia", { transshipment: result.meta.transshipmentVia })}
              </div>
            )}
          </div>
        </div>
        {
          hasNotes && (
            <div
              className={`flex-100 layout-row layout-align-space-between-center pointy ${styles.notes_bar_button}`}
              onClick={this.toggleNotesModal}
            >
              <span>{t('common:notesAndInfo')}</span>
              <i className="flex-none fa fa-question-circle" />
            </div>
          )
        }
        { scope.show_rate_overview ? (<RatesOverview ratesObject={result.meta.pricing_rate_data} />) : '' }
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
            { isQuote(tenant)
              ? '' : (
                <div className="flex-30 layout-row layout-align-start-center">
                  {this.buttonToDisplay()}
                </div>
              ) }

            <div className={`${isQuote(tenant) ? 'flex-100' : 'flex'}  layout-row layout-align-end-center`}>
              {isQuote(tenant) && onClickAdd ? (
                <div className=" flex-33 layout-row layout-align-end-center">
                  <RoundButton
                    active={!this.state.isChecked}
                    flexContainer="100"
                    classNames={`ccb_select_quote pointy layout-row layout-align-center-center ${styles.add_button}`}
                    size="full"
                    handleNext={() => this.handleClickChecked()}
                    theme={theme}
                    text={!this.state.isChecked ? t('common:select') : t('common:remove')}
                  />
                </div>
              ) : ''}
              <p className="flex-none" style={{ textAlign: 'right' }}>{hideGrandTotal ? '' : t('common:total')}</p>
              <p
                style={{ paddingRight: '18px' }}
                className="flex"
              >
                {hideGrandTotal
                  ? ''
                  : `${formattedPriceValue(quote.total.value)} ${quote.total.currency}`}
              </p>
            </div>
            {result.meta.remarkNote && (
              <div className={`flex-100 layout-row layout-align-end-center ${styles.remark_note}`}>
                {result.meta.remarkNote}
              </div>
            )}
            <div className="flex-100 layout-row layout-align-end-center">

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
  result: {
    notes: []
  },
  cargo: [],
  selectResult: null,
  onScheduleRequest: null,
  onClickAdd: null,
  pickup: false,
  isChecked: false,
  aggregatedCargo: {},
  validUntil: null
}

export default withNamespaces(['common', 'cargo', 'acronym', 'shipment', 'quote', 'disclaimers'])(QuoteCard)
