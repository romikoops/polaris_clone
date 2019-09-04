import React from 'react'
import { withNamespaces } from 'react-i18next'
import styles from './index.scss'

function NoteCard (props) {
  const { note } = props

  return (
    <div className={`flex-33 layout-row layout-wrap ${styles.note_card}`}>
      <div className={`flex-100 layout-row layout-wrap ${styles.note_header}`}>
        <p className="flex">{note.header}</p>
      </div>
      <div className={`flex-100 layout-row layout-wrap ${styles.note_body}`}>
        <p className="flex-100">{note.body}</p>
      </div>
    </div>
  )
}

export default withNamespaces('common')(NoteCard)
