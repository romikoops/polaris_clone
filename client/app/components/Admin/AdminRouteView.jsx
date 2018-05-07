import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import PropTypes from '../../prop-types'
import { AdminTripPanel, AdminHubTile } from './'
import styles from './Admin.scss'
import { gradientTextGenerator } from '../../helpers'
import { RoundButton } from '../RoundButton/RoundButton'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import AdminPromptConfirm from './Prompt/Confirm'
import NotesWriter from '../../containers/Notes/Writer'
import NotesRow from '../Notes/Row'

export class AdminRouteView extends Component {
  constructor (props) {
    super(props)
    this.state = {
      scheduleLimit: 20,
      panelViewer: {},
      confirm: false,
      editNotes: false
    }
    this.toggleShowPanel = this.toggleShowPanel.bind(this)
  }
  componentDidMount () {
    window.scrollTo(0, 0)
  }
  toggleShowPanel (id) {
    if (!this.state.panelViewer[id]) {
      this.props.adminDispatch.getLayovers(id, 'itinerary')
    }
    this.setState({
      panelViewer: {
        ...this.state.panelViewer,
        [id]: !this.state.panelViewer[id]
      }
    })
  }
  handleNavChange (e) {
    const { adminDispatch, itineraryData } = this.props
    const { itinerary } = itineraryData
    switch (e.value) {
      case 'schedules':
        adminDispatch.loadItinerarySchedules(itinerary.id, true)
        break
      case 'pricings':
        adminDispatch.getPricings()
        adminDispatch.getItineraryPricings(itinerary.id, true)
        break
      default:
        break
    }
  }
  deleteItinerary (id) {
    const { adminDispatch } = this.props
    adminDispatch.deleteItinerary(id)
    this.closeConfirm()
  }
  confirmDelete () {
    this.setState({
      confirm: true
    })
  }
  closeConfirm () {
    this.setState({ confirm: false })
  }
  doNothing () {
    console.log(this.props)
  }
  toggleNotesEdit () {
    this.setState({ editNotes: !this.state.editNotes })
  }
  render () {
    const {
      theme, itineraryData, hubHash, adminDispatch
    } = this.props
    // ;s
    if (!itineraryData) {
      return ''
    }
    const { panelViewer, confirm, editNotes } = this.state
    const {
      itinerary, hubs, schedules, layovers, notes
    } = itineraryData
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const confimPrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading="Are you sure?"
        text="This will delete the route and all related data (pricings, schedules etc)"
        confirm={() => this.deleteItinerary(itinerary.id)}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )
    const hubArr = hubs.map(hubObj => (
      <AdminHubTile
        key={v4()}
        hub={hubHash[hubObj.id]}
        theme={theme}
        handleClick={() => adminDispatch.getHub(hubObj.id, true)}
      />
    ))

    const schedArr = schedules.map((trip, i) => {
      if (i <= this.state.scheduleLimit) {
        return (
          <AdminTripPanel
            key={v4()}
            trip={trip}
            showPanel={panelViewer[trip.trip_id]}
            toggleShowPanel={this.toggleShowPanel}
            layovers={layovers}
            adminDispatch={adminDispatch}
            itinerary={itinerary}
            hubs={hubs}
            theme={theme}
          />
        )
      }
      return ''
    })
    const navOptions = [
      { value: 'pricings', label: 'Pricings' },
      { value: 'schedules', label: 'Schedules' }
    ]

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        {confimPrompt}
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
            {itinerary.name}
          </p>
          <div className="flex-40 layout-row layout-align-space-between-center">
            <div className="flex-70 layout-row layout-align-end-center">
              <NamedSelect
                theme={theme}
                className="flex-100"
                options={navOptions}
                placeholder="Jump to..."
                onChange={e => this.handleNavChange(e)}
              />
            </div>
            <div className="flex-25 layout-row layout-align-end-center">
              <RoundButton
                theme={theme}
                text="Delete"
                iconClass="fa-trash"
                size="small"
                handleNext={() => this.confirmDelete()}
              />
            </div>
          </div>
        </div>
        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}> Route Stops</p>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-start-start">{hubArr}</div>
        </div>
        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}> Schedules </p>
          </div>
          {schedArr}
        </div>
        <div className="flex-100 layout-row layout-align-space-between-center layout-wrap">
          <div className="flex-100 layout-row layout-align-space-between-center">
            <div className="flex-60 layout-row layout-align-start-cetner">
              <p className="flex-none">Notes</p>
            </div>
            <div
              className="flex-10 layout-row alyout-align-center-center"
              onClick={() => this.toggleNotesEdit()}
            >
              <i className="fa fa-pencil clip" style={textStyle} />
            </div>
          </div>
          <div className="flex-100 layout-row">
            {editNotes ? (
              <NotesWriter theme={theme} targetId={itinerary.id} />
            ) : (
              <NotesRow notes={notes} theme={theme} />
            )}
          </div>
        </div>
      </div>
    )
  }
}
AdminRouteView.propTypes = {
  theme: PropTypes.theme,
  hubHash: PropTypes.objectOf(PropTypes.hub),
  adminDispatch: PropTypes.shape({
    getHub: PropTypes.func,
    getLayovers: PropTypes.func
  }).isRequired,
  itineraryData: PropTypes.objectOf(PropTypes.any).isRequired
}

AdminRouteView.defaultProps = {
  theme: null,
  hubHash: {}
}

export default AdminRouteView
