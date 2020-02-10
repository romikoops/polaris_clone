import React from 'react'
import moment from 'moment'
import { withNamespaces } from 'react-i18next'
import styles from './QuoteCardScheduleList.scss'
import QuoteCardScheduleListItem from './Item'
import QuoteCardScheduleListItemPlaceholder from './Item/Placeholder'
import Pagination from '../../../../containers/Pagination'
import { getHubType } from '../../../../helpers'

function QuoteCardScheduleList ({
  schedules, theme, finalResults, originHub, destinationHub, onSelectSchedule, t, user
}) {
  const perPage = 5

  const sortedSchedules = schedules.sort((scheduleA, scheduleB) => (
    moment(scheduleA.closing_date).diff(scheduleB.closing_date)
  ))

  return (
    <div className="flex-100 layout-wrap layout-row">
      <Pagination items={sortedSchedules} pageNavigation={false} perPage={perPage}>
        {
          ({
            items, nextPage, prevPage, page, numPages
          }) => {
            const firstSchedule = items[0]
            const lastSchedule = items[items.length - 1]

            const _schedules = items.map(schedule => (
              <QuoteCardScheduleListItem schedule={schedule} theme={theme} onSelectSchedule={onSelectSchedule} user={user} />
            ))

            while (_schedules.length < perPage) {
              _schedules.push(<QuoteCardScheduleListItemPlaceholder />)
            }

            return [
              (
                <div className={`flex-100 layout-row ${styles.dates_row} ${styles.dates_container} ${styles.dates_header}`}>
                  <div className="flex-75 layout-row">
                    <div className="flex-25 layout-row">
                      <h4 className={styles.date_title}>{t('common:closingDate')}</h4>
                    </div>
                    <div className="flex-25 layout-row">
                      <h4 className={styles.date_title}>{`${t('common:etd')} ${getHubType(originHub)}`}</h4>
                    </div>
                    <div className="flex-25 layout-row">
                      <h4 className={styles.date_title}>{`${t('common:eta')} ${getHubType(destinationHub)} `}</h4>
                    </div>
                    <div className="flex-25 layout-row">
                      <h4 className={styles.date_title}>{t('quote:estimatedTT')}</h4>
                    </div>
                  </div>
                  <div className="flex-25 layout-row" />
                </div>
              ),
              _schedules,
              (
                <div className={`flex-100 layout-row layout-align-space-around-center ${styles.date_btns}`}>
                  <div
                    className={`flex-30 layout-row layout-align-center-center
                      ${page > 1 ? '' : styles.disabled} ${styles.date_btn}`}
                    onClick={prevPage}
                  >
                    <div className="flex-none layout-row layout-align-space-around-center">
                      <i className="flex-none fa fa-chevron-left" />
                      <p className="flex-none">{t('common:earlierDeparturesBase')}</p>
                    </div>
                  </div>
                  <div className="flex-40 layout-row layout-align-center hide-sm">
                    <p className="flex-100 center">
                      {`${moment(firstSchedule.closing_date).format('ll')} -
                        ${moment(lastSchedule.closing_date).format('ll')}
                      `}
                    </p>
                  </div>
                  <div
                    className={`flex-30 layout-row layout-align-center-center
                    ${page < numPages ? '' : styles.disabled} ${styles.date_btn} ${styles.date_btn}`}
                    onClick={nextPage}
                  >
                    <div className="flex-none layout-row layout-align-space-around-center">
                      <p className="flex-none" style={{ textAlign: 'right' }}>{t('common:laterDeparturesBase')}</p>
                      <i className="flex-none fa fa-chevron-right" />
                    </div>
                  </div>
                </div>
              )
            ]
          }
        }
      </Pagination>
    </div>
  )
}

export default withNamespaces('common')(QuoteCardScheduleList)
