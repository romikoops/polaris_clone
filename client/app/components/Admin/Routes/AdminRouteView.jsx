import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import styles from '../Admin.scss'
import { gradientTextGenerator } from '../../../helpers'
import { RoundButton } from '../../RoundButton/RoundButton'
import { NamedSelect } from '../../NamedSelect/NamedSelect'
import AdminPromptConfirm from '../Prompt/Confirm'
import AdminSchedulesList from '../Schedules/List'
import NotesWriter from '../../../containers/Notes/Writer'
import NotesRow from '../../Notes/Row'
import { AdminClientMargins } from '../Clients'
import ValidatorResultsViewer from './ValidatorResult/Viewer'

export class AdminRouteView extends Component {
  constructor (props) {
    super(props)
    this.state = {
      confirm: false,
      editNotes: false,
      editMargins: false
    }
    
    this.toggleMarginEdit = this.toggleMarginEdit.bind(this)
  }

  componentWillMount () {
    const { adminDispatch, match } = this.props
    adminDispatch.getItinerary(match.params.id)
  }

  componentDidMount () {
    window.scrollTo(0, 0)
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
        adminDispatch.getItineraryPricings(itinerary.id, null, true)
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

  toggleMarginEdit () {
    const { clientsDispatch, id } = this.props
    this.setState((prevState) => {
      if (prevState.editMargins) {
        clientsDispatch.viewGroup(id)
      }

      return { editMargins: !prevState.editMargins }
    })
  }

  render () {
    const {
      theme, itineraryData, adminDispatch, t
    } = this.props

    if (!itineraryData) {
      return ''
    }
    const { confirm, editNotes, editMargins } = this.state
    const {
      itinerary, notes
    } = itineraryData
    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const confimPrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading={t('common:areYouSure')}
        text={t('admin:confirmDeleteRoute')}
        confirm={() => this.deleteItinerary(itinerary.id)}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )
    const navOptions = [
      { value: 'pricings', label: 'Pricings' },
      { value: 'schedules', label: 'Schedules' }
    ]
    const itineraryName = itinerary.transshipment ? `${itinerary.name} (${itinerary.transshipment})` : itinerary.name

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start extra_padding_left">
        {confimPrompt}
        <div
          className={`flex-95 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <p className={` ${styles.sec_title_text} flex-none ccb_itinerary_name`} style={textStyle}>
            {itineraryName}
          </p>
          <div className="flex-40 layout-row layout-align-space-between-center">
            <div className="flex-40 layout-row layout-align-end-center">
              <NamedSelect
                theme={theme}
                className="flex-100"
                options={navOptions}
                placeholder={t('admin:jumpTo')}
                onChange={e => this.handleNavChange(e)}
              />
            </div>
            <div className="flex-55 layout-row layout-align-end-center">
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
            <p className={` ${styles.sec_header_text} flex-none`}>
              {' '}
              {t('admin:validationResults')}
              {' '}
            </p>
          </div>
          <div className="layout-row flex-95 layout-wrap layout-align-start-center">
            <ValidatorResultsViewer
           
            />
          </div>
        </div>
        <div className="layout-row flex-95 layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}>
              {' '}
              {t('admin:margins')}
              {' '}
            </p>
          </div>
          <div className="layout-row flex-95 layout-wrap layout-align-start-center">
            <AdminClientMargins
              targetId={itinerary.id}
              targetType="itinerary"
              editable={editMargins}
              toggleEdit={this.toggleMarginEdit}
            />
          </div>
        </div>
        <div className="layout-row flex-95 layout-wrap layout-align-start-center">
          <div
            className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_header}`}
          >
            <p className={` ${styles.sec_header_text} flex-none`}>
              {' '}
              {t('admin:schedules')}
              {' '}
            </p>
          </div>
          <div className="layout-row flex-95 layout-wrap layout-align-start-center">
            <AdminSchedulesList itineraryId={itinerary.id} />
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

AdminRouteView.defaultProps = {
  theme: null,
  hubHash: {}
}

export default withNamespaces(['common', 'admin'])(AdminRouteView)
