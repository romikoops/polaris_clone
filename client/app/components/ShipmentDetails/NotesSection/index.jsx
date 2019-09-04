import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { connect } from 'react-redux'
import { isEmpty } from 'lodash'
import { bindActionCreators } from 'redux'
import NotesCard from '../../Notes/Card'
import { shipmentActions } from '../../../actions'
import styles from './index.scss'

class NotesSection extends Component {
  static getDerivedStateFromProps (nextProps, prevState) {
    const nextState = {}

    if (NotesSection.shouldFetchNotes(nextProps.shipment) && prevState.availableRoutes !== nextProps.availableRoutes) {
      nextProps.shipmentDispatch.getNotes(nextProps.availableRoutes.map(x => x.itineraryId))
      nextState.availableRoutes = nextProps.availableRoutes
    }

    return nextState
  }

  static shouldFetchNotes (shipment) {
    const { origin, destination } = shipment

    return (!!origin && !!destination) && (!isEmpty(origin) && !isEmpty(destination))
  }

  constructor (props) {
    super(props)
    this.state = {}
  }

  render () {
    const { notes, shipment, t } = this.props
    if (!NotesSection.shouldFetchNotes(shipment)) {
      return ''
    }
    const noteCards = notes.map(note => <NotesCard note={note} />)

    return (
      <div className="flex-100 layout-row layout-align-center">
        <div className={`flex-none content_width_booking ${styles.note_section}`}>
          <div className="flex-100 layout-row layout-wrap layout-align-center-center">
            {noteCards}
          </div>
        </div>
      </div>
    )
  }
}

function mapStateToProps (state) {
  const { bookingProcess, bookingData } = state
  const { ShipmentDetails, shipment } = bookingProcess
  const { stage1 } = bookingData.response
  const { notes } = stage1
  const { availableRoutes } = ShipmentDetails

  return {
    notes,
    availableRoutes,
    shipment
  }
}

function mapDispatchToProps (dispatch) {
  return {
    shipmentDispatch: bindActionCreators(shipmentActions, dispatch)
  }
}

NotesSection.defaultProps = {
  notes: []
}

export default withNamespaces('common')(connect(mapStateToProps, mapDispatchToProps)(NotesSection))
