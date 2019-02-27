import React from 'react'
import moment from 'moment'
import { withNamespaces } from 'react-i18next'
import DayPickerInput from 'react-day-picker/DayPickerInput'
import styles from './DayPickerSection.scss'
import { Tooltip } from '../../Tooltip/Tooltip'
import TextHeading from '../../TextHeading/TextHeading'
import IncotermBox from '../../Incoterm/Box'
import errorStyles from '../../../styles/errors.scss'

function DayPickerSection ({
  theme, nextStageAttempts, selectedDay, incoterm, hasPreCarriage, hasOnCarriage,
  hide, scope, direction, lastAvailableDate, setIncoterm, onDayChange, t, destination, origin
}) {
  if (hide) return ''

  const disabled = lastAvailableDate == null
  let freshDayPicker = false

  if (origin || destination === {}) {
    freshDayPicker = true
  }

  const showDayPickerError = nextStageAttempts > 0 && !selectedDay
  const showIncotermError = nextStageAttempts > 0 && !incoterm

  const formattedSelectedDay = selectedDay ? moment(selectedDay).format('DD/MM/YYYY') : ''

  const inputProps = { disabled }
  const dayPickerProps = {
    disabledDays: {
      before: new Date(moment().format()),
      after: new Date(moment(lastAvailableDate))
    },
    month: new Date(moment().add(7, 'days').format('YYYY'), moment().add(7, 'days').format('M') - 1),
    name: 'dayPicker'
  }
  const dayPickerToolip = hasPreCarriage ? 'planned_pickup_date' : 'planned_dropoff_date'
  const dayPickerText = hasPreCarriage ? t('cargo:cargoReadyDate') : t('cargo:availableAtTerm')

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
            className={`flex-none layout-row ${styles.dpb} ${(showDayPickerError || disabled) && !freshDayPicker ? styles.with_errors : ''}`}
          >
            <div className={`flex-none layout-row layout-align-center-center ${styles.dpb_icon}`}>
              <i className="flex-none fa fa-calendar" />
            </div>
            <DayPickerInput
              name="dayPicker"
              placeholder="DD/MM/YYYY"
              format="DD/MM/YYYY"
              value={formattedSelectedDay}
              onDayChange={onDayChange}
              inputProps={inputProps}
              dayPickerProps={dayPickerProps}
            />
            <span className={errorStyles.error_message}>
              {showDayPickerError ? t('errors:notBlank') : ''}
              {disabled && !freshDayPicker ? t('errors:noSchedulesForRoute') : ''}
            </span>
          </div>
        </div>
        <div className="flex-50 layout-row layout-wrap layout-align-end-center">
          <IncotermBox
            theme={theme}
            preCarriage={hasPreCarriage}
            onCarriage={hasOnCarriage}
            tenantScope={scope}
            incoterm={incoterm}
            setIncoterm={setIncoterm}
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

DayPickerSection.defaultProps = {
  theme: null,
  nextStageAttempts: false,
  hide: false,
  lastAvailableDate: null
}

export default withNamespaces('common', 'errors')(DayPickerSection)
