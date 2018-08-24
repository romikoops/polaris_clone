import React from 'react'
import PropTypes from '../../../prop-types'
import NotesCard from '../Card'
import styles from './index.scss'

const NotesRow = ({ notes, theme }) => {
  const noteCards = notes.map(n =>
    <NotesCard note={n} theme={theme} />)
  return (
    <div className="layout-row flex-100 layout-wrap layout-align-center">
      <div
        className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
      >
        <p className={` ${styles.sec_header_text} flex-none`}> Notes </p>
      </div>
      <div className="flex-100 layout-row layout-align-start-center layout-wrap">
        {noteCards}
      </div>

    </div>
  )
}

NotesRow.propTypes = {
  notes: PropTypes.arrayOf(PropTypes.any),
  theme: PropTypes.theme
}

NotesRow.defaultProps = {
  notes: [],
  theme: {}
}

export default NotesRow
