import React from 'react'
import PropTypes from '../../../prop-types'
import NotesCard from '../Card'
import styles from './index.scss'
import adminStyles from '../../Admin/Admin.scss'

const NotesRow = ({
  notes, theme, toggleNotesEdit, textStyle
}) => {
  const noteCards = notes.map(n =>
    <NotesCard note={n} theme={theme} />)

  return (
    <div className="layout-row flex-100 layout-wrap layout-align-center-center">
      <div
        className={`flex-100 layout-row layout-start-center ${adminStyles.sec_header}`}
      >
        <p className={`${adminStyles.sec_header_text} flex-none`}> Notes </p>
        <div
          className="flex-10 offset-5 layout-row alyout-align-center-center pointy"
          onClick={toggleNotesEdit}
        >
          <i className="fa fa-pencil clip pointy" style={textStyle} />
        </div>
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
