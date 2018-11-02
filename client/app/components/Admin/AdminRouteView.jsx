import React, { Component } from 'react'
import { v4 } from 'uuid'
import { withNamespaces } from 'react-i18next'
import ReactTable from 'react-table'
import 'react-table/react-table.css'
import PropTypes from '../../prop-types'
import { AdminHubTile } from './'
import styles from './Admin.scss'
import { gradientTextGenerator } from '../../helpers'
import { RoundButton } from '../RoundButton/RoundButton'
import { NamedSelect } from '../NamedSelect/NamedSelect'
import AdminPromptConfirm from './Prompt/Confirm'
import NotesWriter from '../../containers/Notes/Writer'
import NotesRow from '../Notes/Row'
import { moment } from '../../constants'

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
      theme, itineraryData, hubHash, adminDispatch, t
    } = this.props

    if (!itineraryData) {
      return ''
    }
    const { confirm, editNotes } = this.state
    const {
      itinerary, hubs, schedules, notes
    } = itineraryData
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const confimPrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading={t('common: areYouSure')}
        text={t('admin:confirmDeleteRoute')}
        confirm={() => this.deleteItinerary(itinerary.id)}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )
    const hubArr = []
    hubs.forEach((hubObj, i) => {
      if (i > 0) {
        hubArr.push(<div className="flex-5" />)
      }
      hubArr.push(<AdminHubTile
        key={v4()}
        hub={hubHash[hubObj.id]}
        theme={theme}
        handleClick={() => adminDispatch.getHub(hubObj.id, true)}
      />)
    })
    const columns = [
      {
        Header: t('common:closingDate'),
        accessor: 'closing_date',
        Cell: row => (
          moment(row.value).format('ll')
        )
      },
      {
        Header: t('common:eta'),
        accessor: 'start_date',
        Cell: row => (
          moment(row.value).format('ll')
        )
      },
      {
        Header: t('common:etd'),
        accessor: 'end_date',
        Cell: row => (
          moment(row.value).format('ll')
        )
      },
      {
        Header: t('common:voyageCode'),
        accessor: 'voyage_code'
      },
      {
        Header: t('common:vesselName'),
        accessor: 'vessel'
      }
    ]

    const navOptions = [
      { value: 'pricings', label: 'Pricings' },
      { value: 'schedules', label: 'Schedules' }
    ]

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start extra_padding_left">
        {confimPrompt}
        <div
          className={`flex-95 layout-row layout-align-space-between-center ${styles.sec_title}`}
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
                placeholder={t('admin:jumpTo')}
                onChange={e => this.handleNavChange(e)}
              />
            </div>
            <div className="flex-25 layout-row layout-align-end-center">
              <RoundButton
                theme={theme}
                text={t('common:delete')}
                iconClass="fa-trash"
                size="small"
                handleNext={() => this.confirmDelete()}
              />
            </div>
          </div>
        </div>
        <div className="layout-row flex-95 layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}> {t('admin:routeStops')}</p>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-start-start">{hubArr}</div>
        </div>
        <div className="layout-row flex-95 layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}> {t('admin:schedules')} </p>
          </div>
          <div className="layout-row flex-95 layout-wrap layout-align-start-center">
            <ReactTable
              className="flex-100 height_100"
              data={schedules}
              columns={columns}
              defaultSorted={[
                {
                  id: 'closing_date',
                  desc: true
                }
              ]}
              defaultPageSize={20}
            />
          </div>
        </div>
        <div className="flex-95 layout-row layout-align-space-between-center layout-wrap">
          <div className="flex-100 layout-row">
            {editNotes ? (
              <NotesWriter
                theme={theme}
                targetId={itinerary.id}
                toggleView={() => this.toggleNotesEdit()}
              />
            ) : (
              <NotesRow
                notes={notes}
                textStyle={textStyle}
                toggleNotesEdit={() => this.toggleNotesEdit()}
                theme={theme}
                adminDispatch={adminDispatch}
                itinerary={itinerary}
              />
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
    getLayovers: PropTypes.func,
    deleteItineraryNote: PropTypes.func
  }).isRequired,
  itineraryData: PropTypes.objectOf(PropTypes.any).isRequired,
  t: PropTypes.func.isRequired
}

AdminRouteView.defaultProps = {
  theme: null,
  hubHash: {}
}

export default withNamespaces(['common', 'admin'])(AdminRouteView)
