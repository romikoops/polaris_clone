import React, { Component } from 'react'
import { withRouter } from 'react-router-dom'
import ReactTooltip from 'react-tooltip'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import PropTypes from '../../../prop-types'
import { adminActions } from '../../../actions'
import styles from './index.scss'
import adminStyles from '../../../components/Admin/Admin.scss'
import { RoundButton } from '../../../components/RoundButton/RoundButton'

class NotesWriter extends Component {
  static iconSwitcher (code, level) {
    switch (code) {
      case 'urgent':
        return (
          <div className="flex-100 layout-row layout-align-center-center">
            <i
              className="fa fa-exclamation-triangle flex-none"
              data-for="urgent"
              data-tip="Urgent"
            />
            <ReactTooltip className={adminStyles.tooltip} id="urgent" effect="solid" />
          </div>)
      case 'important':
        return (
          <div className="flex-100 layout-row layout-align-center-center">
            <i
              className="fa fa-exclamation flex-none"
              data-for="important"
              data-tip="Important"
            />
            <ReactTooltip className={adminStyles.tooltip} id="important" effect="solid" />
          </div>)
      case 'notification':
        return (
          <div className="flex-100 layout-row layout-align-center-center">
            <i
              className="fa fa-flag flex-none"
              data-for="notification"
              data-tip="Notification"
            />
            <ReactTooltip className={adminStyles.tooltip} id="notification" effect="solid" />
          </div>
        )
      case 'alert':
        return (
          <div className="flex-100 layout-row layout-align-center-center">
            <i
              className="fa fa-bell flex-none"
              data-for="alert"
              data-tip="Alert"
            />
            <ReactTooltip className={adminStyles.tooltip} id="alert" effect="solid" />
          </div>
        )

      default:
        return <i className="fa fa-bell flex-none " />
    }
  }
  static styleSwitcher (level) {
    switch (level) {
      case 'urgent':
        return { background: '#D73C1D' }
      case 'important':
        return { background: '#FF9626' }
      case 'notification':
        return { background: '#FFCF32' }
      case 'alert':
        return { background: '#6DC66B' }

      default:
        return { background: '#FF9626' }
    }
  }
  constructor () {
    super()
    this.state = {
      itineraryNotes: {
        body: '',
        header: ''
      }
    }
  }

  setImportanceLevel (level) {
    this.setState({
      itineraryNotes: {
        ...this.state.itineraryNotes,
        level
      }
    })
  }
  handleItineraryNotes (e, target) {
    const { value } = e.target
    this.setState({
      itineraryNotes: {
        ...this.state.itineraryNotes,
        [target]: value
      }
    })
  }
  saveItineraryNotes () {
    const { itineraryNotes } = this.state
    const { adminDispatch, targetId } = this.props
    adminDispatch.saveItineraryNotes(targetId, itineraryNotes)
    this.props.toggleView()
  }
  render () {
    const { itineraryNotes } = this.state
    const { theme } = this.props
    const nbLevels = ['urgent', 'important', 'notification', 'alert']

    const importanceLevels = nbLevels.map((l) => {
      const style = l === itineraryNotes.level ? styles[`${l}_selected`] : styles[l]

      return (
        <div
          className={`${style} flex-none layout-row layout-align-center-center pointy`}
          style={this.state.itineraryNotes.level === l ? NotesWriter.styleSwitcher(l) : {}}
          onClick={() => this.setImportanceLevel(l)}
        >
          {NotesWriter.iconSwitcher(l, this.state.itineraryNotes.level)}
          {/* <div className="flex layout-row layout-align-start-center">
            <p className="flex-none">{capitalize(l)}</p>
          </div> */}
        </div>
      )
    })

    return (
      <div className="layout-row flex-100 layout-wrap layout-align-space-between">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${adminStyles.sec_header}`}
        >
          <p className={` ${adminStyles.sec_header_text} flex-none`}> Comments </p>
        </div>
        <div className="flex-65 layout-row layout-align-start-start layout-wrap">
          <div className={`flex-100 layou-row input_box_full ${styles.form}`} >
            <div className="flex-70 layout-row layout-wrap layout-align-center-center">
              <input
                type="text"
                name="title"
                className={`flex-100 layout-row ${styles.title_input}`}
                placeholder="Place title here"
                value={itineraryNotes.header}
                onChange={e => this.handleItineraryNotes(e, 'header')}
              />
              <label className={`flex-100 layout-row ${styles.title_label}`} htmlFor="title">Title</label>
            </div>
            <div className={`flex-50 layout-row layout-align-space-around-center ${styles.levels_row}`}>
              <p className="layout-row layout-align-start-center">Importance:</p>
              {importanceLevels}
            </div>
          </div>
          <div className="flex-100 input_box_full" style={{ margin: '10px 0' }}>
            <textarea
              rows="5"
              cols="100"
              placeholder="Description"
              className="flex-100"
              value={itineraryNotes.body}
              onChange={e => this.handleItineraryNotes(e, 'body')}
            />
          </div>
        </div>
        <div className="flex-30 layout-row layout-wrap layout-align-center-space-around" />
        <div className="flex-90" style={{ margin: '20px 0' }}>
          <RoundButton
            theme={theme}
            text="save"
            size="small"
            handleNext={() => this.saveItineraryNotes()}
            active
          />
        </div>
      </div>
    )
  }
}
NotesWriter.propTypes = {
  theme: PropTypes.theme,
  adminDispatch: PropTypes.objectOf(PropTypes.func).isRequired,
  targetId: PropTypes.number,
  toggleView: PropTypes.func
}

NotesWriter.defaultProps = {
  theme: null,
  targetId: null,
  toggleView: null
}

function mapStateToProps (state) {
  const { users, authentication, app } = state
  const { tenant } = app
  const { user, loggedIn } = authentication

  return {
    user,
    users,
    tenant,
    theme: tenant.theme,
    loggedIn
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(NotesWriter))
