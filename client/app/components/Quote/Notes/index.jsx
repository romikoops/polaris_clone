import React, { Fragment } from 'react'
import styles from './index.scss'

const NoteReader = (props) => {
  const { t, notes, closeModal } = props
  const htmlNotes = notes.filter(note => note.contains_html)
  const stringNotes = notes.filter(note => !note.contains_html)
  const stdNoteCards = stringNotes.map(note => (
    <div className="flex-100 alyout-row layout-wrap">
      <div className={`flex-100 layout-row layout-align-start-center ${styles.note_header}`}>
        <p className="flex">
          {note.header}
          {' '}
        </p>
      </div>
      <div className={`flex-100 layout-row layout-align-start-center ${styles.note_body}`}>
        <p className="flex">
          {note.body}
          {' '}
        </p>
      </div>
    </div>
  ))
  const htmlNoteCards = htmlNotes.map(note => (
    <div className="flex-100 alyout-row layout-wrap">
      <div className={`flex-100 layout-row layout-align-start-center ${styles.note_header}`}>
        <p className="flex">
          {note.header}
          {' '}
        </p>
      </div>
      <div className={`flex-100 layout-row layout-align-start-center ${styles.note_body}`}>
        <Fragment>
          <div dangerouslySetInnerHTML={{ __html: note.body }} />
        </Fragment>
      </div>
    </div>
  ))

  return (
    <div className="flex-100 layout-row layout-align-start-center layout-row layout-wrap">
      <div className={`flex-100 layout-row layout-align-space-between-center" ${styles.reader_title}`}>
        <h3 className="flex">{t('common:notesAndInfo') }</h3>
        <div className="flex-10 layout-row layout-align-center-center" onClick={closeModal}>
          <i className="flex-none fa fa-times" />
        </div>
      </div>
      <div className="flex-100 layout-row layout-align-center-start layout-wrap scroll">
        <div className="flex-100 layout-row layout-align-center-start layout-wrap">
          {stdNoteCards}
        </div>
        <div className="flex-100 layout-row layout-align-center-start layout-wrap">
          {htmlNoteCards}
        </div>
      </div>
    </div>
  )
}

export default NoteReader
