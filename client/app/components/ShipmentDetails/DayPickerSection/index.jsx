import React from 'react'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import moment from 'moment'
import { withNamespaces } from 'react-i18next'
import FormsyDayPickerInput from '../../Formsy/DayPickerInput'
import styles from './index.scss'
import { Tooltip } from '../../Tooltip/Tooltip'
import TextHeading from '../../TextHeading/TextHeading'
import IncotermBox from '../../Incoterm/Box'
import errorStyles from '../../../styles/errors.scss'
import { isQuote } from '../../../helpers'
import { bookingProcessActions } from '../../../actions'

class DayPickerSection extends React.PureComponent {
  constructor (props) {
    super(props)

    this.setIncoterm = this.setIncoterm.bind(this)
    this.handleDayChange = this.handleDayChange.bind(this)
  }

  setIncoterm (e) {
    console.log(e, this.props)
  }

  handleDayChange (selectedDay, modifiers, dayPickerInput) {
    const { bookingProcessDispatch } = this.props
    bookingProcessDispatch.updateShipment(dayPickerInput.getInput().name, selectedDay)
  }

  render () {
    const {
      tenant, theme, scope, shipment, t
    } = this.props

    if (isQuote(tenant)) return ''

    const {
      selectedDay, incoterm, preCarriage, onCarriage, direction, lastAvailableDate
    } = shipment

    // TODO: implement
    const nextStageAttempts = 0

    const showIncotermError = nextStageAttempts > 0 && !incoterm

    const formattedSelectedDay = selectedDay ? moment(selectedDay).format('DD/MM/YYYY') : ''

    const inputProps = { disabled: lastAvailableDate == null }
    const dayPickerProps = {
      disabledDays: {
        before: new Date(moment().format()),
        after: new Date(moment(lastAvailableDate))
      },
      month: new Date(moment().add(7, 'days').format('YYYY'), moment().add(7, 'days').format('M') - 1),
      name: 'dayPicker'
    }
    const dayPickerToolip = preCarriage ? 'planned_pickup_date' : 'planned_dropoff_date'
    const dayPickerText = preCarriage ? t('cargo:cargoReadyDate') : t('cargo:availableAtTerm')

    return (
      <div className={`${styles.date_sec} layout-row flex-100 layout-wrap layout-align-center-center`}>
        <div className="content_width_booking layout-row flex-none layout-align-start-center">
          <div className="layout-row flex-70 layout-align-start-center layout-wrap">
            <div className="flex-none layout-row layout-align-start-center" style={{ paddingRight: '15px' }}>
              <div className="flex-none layout-align-space-between-end">
                <TextHeading theme={theme} text={`${dayPickerText}:`} size={3} />
              </div>
              <Tooltip theme={theme} text={dayPickerToolip} icon="fa-info-circle" />
            </div>
            <div
              name="dayPicker"
              className={`flex-none layout-row ${styles.dpb}`}
            >
              <div className={`flex-none layout-row layout-align-center-center ${styles.dpb_icon}`}>
                <i className="flex-none fa fa-calendar" />
              </div>
              <FormsyDayPickerInput
                name="selectedDay"
                value={formattedSelectedDay}
                onDayChange={this.handleDayChange}
                inputProps={inputProps}
                dayPickerProps={dayPickerProps}
                validatePristine={lastAvailableDate == null}
                validations={{
                  noAvailableDate: () => lastAvailableDate != null,
                  isBlank: (values, value) => !!value
                }}
                validationErrors={{
                  noAvailableDate: t('errors:noSchedulesForRoute'),
                  isBlank: t('errors:notBlank')
                }}
              />
            </div>
          </div>
          <div className="flex-50 layout-row layout-wrap layout-align-end-center">
            <IncotermBox
              theme={theme}
              preCarriage={preCarriage}
              onCarriage={onCarriage}
              tenantScope={scope}
              incoterm={incoterm}
              setIncoterm={this.setIncoterm}
              errorStyles={errorStyles}
              direction={direction}
              showIncotermError={showIncotermError}
              nextStageAttempt={nextStageAttempts > 0}
              firstStep
            />
          </div>
        </div>
      </div>
    )
  }
}

DayPickerSection.defaultProps = {
  theme: null,
  nextStageAttempts: false,
  hide: false,
  lastAvailableDate: null
}

function mapStateToProps (state) {
  const { bookingProcess, app } = state
  const { shipment } = bookingProcess
  const { tenant } = app
  const { theme, scope } = tenant

  return {
    shipment, theme, scope, tenant
  }
}

function mapDispatchToProps (dispatch) {
  return {
    bookingProcessDispatch: bindActionCreators(bookingProcessActions, dispatch)
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(withNamespaces('common', 'errors')(DayPickerSection))
