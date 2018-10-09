import React from 'react'
import { translate } from 'react-i18next'
import PropTypes from '../../../prop-types'
import NotesCard from '../Card'
import styles from './index.scss'
import adminStyles from '../../Admin/Admin.scss'

const NotesRow = ({
  notes, theme, toggleNotesEdit, textStyle, t, adminDispatch, itinerary
}) => {
  const noteCards = notes.length > 0 ? notes.map(n =>
    <NotesCard note={n} itinerary={itinerary} adminDispatch={adminDispatch} theme={theme} />)
    : ''

  return (
    <div className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.notes_wrapper}`}>
      <div
        className={`flex-100 layout-row layout-start-center ${adminStyles.sec_header}`}
      >
        <p className={`${adminStyles.sec_header_text} flex-none`}>{t('common:notes')}</p>
        <div
          className="flex-10 layout-row alyout-align-center-center pointy"
          onClick={toggleNotesEdit}
        >
          <i className={`fa fa-plus clip pointy ${styles.plus}`} style={textStyle} />
        </div>
      </div>
      <div className="flex-100 layout-row card_margin_right layout-wrap">
        {noteCards}
      </div>

    </div>
  )
}

NotesRow.propTypes = {
  notes: PropTypes.arrayOf(PropTypes.any),
  itinerary: PropTypes.itinerary,
  adminDispatch: PropTypes.func,
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  toggleNotesEdit: PropTypes.func,
  textStyle: PropTypes.objectOf(PropTypes.style)
}

NotesRow.defaultProps = {
  notes: [],
  theme: {},
  itinerary: {},
  toggleNotesEdit: null,
  adminDispatch: null,
  textStyle: {}
}

export default translate('common')(NotesRow)
