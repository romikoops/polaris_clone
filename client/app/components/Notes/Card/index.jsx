import React, { Component } from 'react'
import PropTypes from '../../../prop-types'
import styles from './index.scss'
import GreyBox from '../../GreyBox/GreyBox'

class NotesCard extends Component {
  static iconSwitcher (code) {
    switch (code) {
      case 'urgent':
        return (
          <div
            className={`${styles.button} ${styles.urgent} flex-none layout-row layout-align-center-center pointy`}
          >
            <i className="fa fa-exclamation-triangle flex-none" />
          </div>
        )
      case 'important':
        return (
          <div
            className={`${styles.button} ${styles.important} flex-none layout-row layout-align-center-center pointy`}
          >
            <i className="fa fa-exclamation flex-none" />
          </div>
        )
      case 'notification':
        return (
          <div
            className={`${styles.button} ${styles.notification} flex-none layout-row layout-align-center-center pointy`}
          >
            <i className="fa fa-flag flex-none" />
          </div>
        )
      case 'alert':
        return (
          <div
            className={`${styles.button} ${styles.alert} flex-none layout-row layout-align-center-center pointy`}
          >
            <i className="fa fa-bell flex-none" />
          </div>
        )

      default:
        return (
          <div
            className={`${styles.button} ${styles.alert} flex-none layout-row layout-align-center-center pointy`}
          >
            <i className="fa fa-bell flex-none" />
          </div>
        )
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
  static styleSwitcher (level) {
    switch (level) {
      case 'urgent':
        return styles.urgent_border_style
      case 'important':
        return styles.important_border_style
      case 'notification':
        return styles.notification_border_style
      case 'alert':
        return styles.alert_border_style

      default:
        return styles.alert_border_style
    }
  }
  render () {
    const { note } = this.props

    return (
      <GreyBox
        flex="30"
        wrapperClassName="margin_bottom"
        borderStyle={NotesCard.styleSwitcher(note.level)}
        content={(<div
          className={`${
            styles.note_card
          } flex-none layout-wrap layout-align-center`}
        >
          <div className={`${styles.note_route} flex-100 layout-row layout-align-start-center`}>
            <div className="flex-none layout-row layout-align-center-center">
              {NotesCard.iconSwitcher(note.level)}
              <span className="flex-90">{note.header}</span>
            </div>
            {/* <div className="flex-10 layout-row layout-align-center-center">
              {NotesCard.motSwitcher(note.mode_of_transport, iconStyle)}
            </div> */}
          </div>
          <div className="flex-100 layout-row layout-align-start-center">
            <p className="flex-90">{note.body}</p>
          </div>
        </div>)}
      />

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
