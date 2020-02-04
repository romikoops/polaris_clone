import React from 'react'
import moment from 'moment'
import { withNamespaces } from 'react-i18next'
import { RoundButton } from '../../../../RoundButton/RoundButton'
import styles from './QuoteCardScheduleListItem.scss'

function QuoteCardScheduleListItem ({ schedule, theme, onSelectSchedule, t, user }) {
  return (
    <div className={`flex-100 layout-row layout-align-start-center ${styles.dates_container}`}>
      <div className={`flex-75 layout-row ${styles.dates_row}`}>
        <div className="flex-25 layout-wrap layout-row layout-align-center-center">
          <div className="flex-100 layout-row">
            <p className={`flex-none ${styles.sched_elem}`}>
              {' '}
              {moment(schedule.closing_date).format('DD-MM-YYYY')}
              {' '}
            </p>
          </div>
        </div>
        <div className="flex-25 layout-wrap layout-row layout-align-center-center">
          <div className="flex-100 layout-row">
            <p className={`flex-none ${styles.sched_elem}`}>
              {' '}
              {moment(schedule.etd).format('DD-MM-YYYY')}
              {' '}
            </p>
          </div>
        </div>
        <div className="flex-25 layout-wrap layout-row layout-align-center-center">
          <div className="flex-100 layout-row">
            <p className={`flex-none ${styles.sched_elem}`}>
              {' '}
              {moment(schedule.eta).format('DD-MM-YYYY')}
              {' '}
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
          size="full"
          handleNext={() => onSelectSchedule(schedule)}
          theme={theme}
          active={!user.guest}
          disabled={user.guest}
          text={t('common:select')}
        />
      </div>
    </div>
  )
}

export default withNamespaces('common')(QuoteCardScheduleListItem)
