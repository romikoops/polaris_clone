import React, { Component } from 'react'
import PropTypes from '../../../prop-types'
import styles from './index.scss'
import { gradientTextGenerator } from '../../../helpers'

class NotesCard extends Component {
  static iconSwitcher (code) {
    switch (code) {
      case 'urgent':
        return <i className={`${styles.warning_icon} fa fa-exclamation-triangle flex-none`} />
      case 'important':
        return <i className={`${styles.warning_icon} fa fa-exclamation flex-none `} />
      case 'notification':
        return <i className={`${styles.warning_icon} fa fa-flag flex-none `} />
      case 'alert':
        return <i className={`${styles.warning_icon} fa fa-bell flex-none `} />

      default:
        return <i className={`${styles.warning_icon} fa fa-bell flex-none `} />
    }
  }
  static motSwitcher (code, style) {
    switch (code) {
      case 'ocean':
        return <i className="fa fa-ship flex-none clip" style={style} />
      case 'air':
        return <i className="fa fa-plane flex-none clip " style={style} />
      case 'rail':
        return <i className="fa fa-train flex-none clip " style={style} />
      case 'truck':
        return <i className="fa fa-truck flex-none clip " style={style} />

      default:
        return <i className="fa fa-ship flex-none clip " style={style} />
    }
  }
  render () {
    const { note, theme } = this.props
    const iconStyle = theme && theme.colors ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary) : { color: 'black' }
    return (
      <div
        className={`${styles[note.level]} ${
          styles.note_card
        } layout-row flex-none layout-wrap layout-align-center`}
      >
        <div className={`${styles.note_route} flex-95 layout-row layout-align-start-center`}>
          <div className="flex-10 layout-row layout-align-center-center">
            {NotesCard.iconSwitcher(note.level)}
          </div>
          <div className="flex layout-row layout-align-start-center">
            <p className="flex-none">{note.itineraryTitle}</p>
          </div>
          <div className="flex-10 layout-row layout-align-center-center">
            {NotesCard.motSwitcher(note.mode_of_transport, iconStyle)}
          </div>
        </div>
        <div className="flex-100 layout-row layout-align-center-center">
          <p className={`${styles.note_header} flex-90`}>{note.header}</p>
        </div>
        <div className="flex-100 layout-row layout-align-center-center">
          <p className="flex-90">{note.body}</p>
        </div>
      </div>
    )
  }
}
NotesCard.propTypes = {
  note: PropTypes.objectOf(PropTypes.any),
  theme: PropTypes.theme
}

NotesCard.defaultProps = {
  note: null,
  theme: {}
}

export default NotesCard
