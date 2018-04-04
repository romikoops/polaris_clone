import React, { Component } from 'react'
import PropTypes from '../../../prop-types'
import styles from './index.scss'

class NotesCard extends Component {
  static iconSwitcher (code) {
    switch (code) {
      case 'urgent':
        return <i className="fa fa-exclamation-triangle flex-none" />
      case 'important':
        return <i className="fa fa-exclamation flex-none " />
      case 'notification':
        return <i className="fa fa-flag flex-none " />
      case 'alert':
        return <i className="fa fa-bell flex-none " />

      default:
        return <i className="fa fa-bell flex-none " />
    }
  }
  render () {
    const { note } = this.props
    return (
      <div
        className={`${styles[note.level]} ${
          styles.note_card
        } layout-row flex-none layout-wrap layout-align-center`}
      >
        <div className="flex-100 layout-row layout-align-start-center">
          <div className="flex-15 layout-row layout-align-center-center">
            {NotesCard.iconSwitcher(note.level)}
          </div>
          <div className="flex layout-row layout-align-start-center">
            <p className="flex-none">{note.header}</p>
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-center-center">
          <p className="flex-90">{note.body}</p>
        </div>
      </div>
    )
  }
}
NotesCard.propTypes = {
  note: PropTypes.objectOf(PropTypes.any)
}

NotesCard.defaultProps = {
  note: null
}

export default NotesCard
