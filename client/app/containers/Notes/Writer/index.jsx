import React, { Component } from 'react'
import { withRouter } from 'react-router-dom'
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux'
import PropTypes from '../../../prop-types'
import { adminActions } from '../../../actions'
import { capitalize } from '../../../helpers'
import styles from './index.scss'
import { RoundButton } from '../../../components/RoundButton/RoundButton'

class NotesWriter extends Component {
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
  }
  render () {
    const { itineraryNotes } = this.state
    const { theme } = this.props
    const nbLevels = ['urgent', 'important', 'notification', 'alert']

    const importanceLevels = nbLevels.map((l) => {
      const style = l === itineraryNotes.level ? styles[`${l}_selected`] : styles[l]
      debugger // eslint-disable-line no-debugger

      return (
        <div
          className={`${style} flex-90 layout-row layout-align-center-center pointy`}
          onClick={() => this.setImportanceLevel(l)}
        >
          <div className="flex-25 layout-row layout-align-center-center">
            {NotesWriter.iconSwitcher(l)}
          </div>
          <div className="flex layout-row layout-align-start-center">
            <p className="flex-none">{capitalize(l)}</p>
          </div>
        </div>
      )
    })

    return (
      <div className="layout-row flex-100 layout-wrap layout-align-center">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
        >
          <p className={` ${styles.sec_header_text} flex-none`}> Comments </p>
        </div>
        <div className="flex-70 layout-row layout-align-start-start layout-wrap">
          <div className="flex-100 input_box_full" style={{ margin: '10px 0' }}>
            <input
              type="text"
              className="flex-100"
              placeholder="Title"
              value={itineraryNotes.header}
              onChange={e => this.handleItineraryNotes(e, 'header')}
            />
          </div>
          <div className="flex-100 input_box_full" style={{ margin: '10px 0' }}>
            <textarea
              rows="10"
              cols="100"
              placeholder="Body"
              className="flex-100"
              value={itineraryNotes.body}
              onChange={e => this.handleItineraryNotes(e, 'body')}
            />
          </div>
        </div>
        <div className="flex-25 layout-row layout-wrap layout-align-center-space-around">
          {importanceLevels}
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
      </div>
    )
  }
}
NotesWriter.propTypes = {
  theme: PropTypes.theme,
  adminDispatch: PropTypes.objectOf(PropTypes.func).isRequired,
  targetId: PropTypes.number
}

NotesWriter.defaultProps = {
  theme: null,
  targetId: null
}

function mapStateToProps (state) {
  const { users, authentication, tenant } = state
  const { user, loggedIn } = authentication

  return {
    user,
    users,
    tenant,
    theme: tenant.data.theme,
    loggedIn
  }
}
function mapDispatchToProps (dispatch) {
  return {
    adminDispatch: bindActionCreators(adminActions, dispatch)
  }
}

export default withRouter(connect(mapStateToProps, mapDispatchToProps)(NotesWriter))
