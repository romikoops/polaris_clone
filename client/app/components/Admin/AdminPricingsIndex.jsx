import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { Redirect } from 'react-router'
import ReactTooltip from 'react-tooltip'
import { AdminPriceCreator } from './'
import { RoundButton } from '../RoundButton/RoundButton'
import { AdminSearchableRoutes, AdminSearchableClients } from './AdminSearchables'
import FileUploader from '../../components/FileUploader/FileUploader'
import { adminPricing as priceTip } from '../../constants'

import styles from './Admin.scss'

export class AdminPricingsIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {
      redirectRoutes: false,
      redirectClients: false
    }
    this.viewAllRoutes = this.viewAllRoutes.bind(this)
    this.viewAllClients = this.viewAllClients.bind(this)
    this.viewClient = this.viewClient.bind(this)
    this.viewRoute = this.viewRoute.bind(this)
    this.toggleCreator = this.toggleCreator.bind(this)
  }
  toggleCreator () {
    this.setState({ newPricing: !this.state.newPricing })
  }
  viewAllRoutes () {
    this.setState({ redirectRoutes: true })
  }
  viewAllClients () {
    this.setState({ redirectClients: true })
  }
  viewClient (client) {
    const { adminDispatch } = this.props
    adminDispatch.getClientPricings(client.id, true)
  }
  viewRoute (route) {
    const { adminDispatch } = this.props
    adminDispatch.getItineraryPricings(route.id, true)
  }
  lclUpload (file) {
    const { documentDispatch } = this.props
    documentDispatch.uploadPricings(file, 'lcl', false)
  }
  fclUpload (file) {
    const { documentDispatch } = this.props
    documentDispatch.uploadPricings(file, 'fcl', false)
  }
  render () {
    const {
      theme, hubs, pricingData, clients, adminDispatch
    } = this.props
    const { newPricing } = this.state
    if (!pricingData) {
      return ''
    }

    if (this.state.redirectRoutes) {
      return <Redirect push to="/admin/pricings/routes" />
    }
    if (this.state.redirectClients) {
      return <Redirect push to="/admin/pricings/clients" />
    }
    const newButton = (
      <div className={styles.btn_wrapper}>
        <p data-tip={priceTip.new} data-for="newPriceTip">
          <RoundButton
            text="New Pricing"
            theme={theme}
            size="small"
            handleNext={this.toggleCreator}
            iconClass="fa-plus"
            active
          />
        </p>
        <ReactTooltip id="newPriceTip" className={styles.tooltip} effect="solid" />
      </div>
    )
    const { itineraries, detailedItineraries, transportCategories } = pricingData
    const lclUrl = '/admin/pricings/ocean_lcl_pricings/process_csv'
    const fclUrl = '/admin/pricings/ocean_fcl_pricings/process_csv'

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          <div
            className={`flex-33 layout-row layout-wrap layout-align-space-between-center ${
              styles.sec_upload
            }`}
          >
            <p className="flex-100">Upload LCL Pricings Sheet</p>
            <FileUploader
              theme={theme}
              url={lclUrl}
              dispatchFn={e => this.lclUpload(e)}
              tooltip={priceTip.upload_lcl}
              type="xlsx"
              text="Dedicated Pricings .xlsx"
            />
          </div>
          <div
            className={`flex-33 layout-row layout-wrap layout-align-space-between-center ${
              styles.sec_upload
            }`}
          >
            <p className="flex-100">Upload FCL Pricings Sheet</p>
            <FileUploader
              theme={theme}
              url={fclUrl}
              dispatchFn={e => this.fclUpload(e)}
              tooltip={priceTip.upload_fcl}
              type="xlsx"
              text="FCL Pricings .xlsx"
            />
          </div>
          <div
            className={`flex-33 layout-row layout-wrap layout-align-space-between-center ${
              styles.sec_upload
            }`}
          >
            <p className={`${styles.new_margin} flex-100`}>New Pricing Creator</p>
            {newButton}
          </div>
        </div>
        <AdminSearchableRoutes
          itineraries={detailedItineraries}
          theme={theme}
          hubs={hubs}
          handleClick={this.viewRoute}
          seeAll={() => adminDispatch.goTo('/admin/pricings/routes')}
          tooltip={priceTip.routes}
          showTooltip
        />
        <AdminSearchableClients
          theme={theme}
          clients={clients}
          handleClick={this.viewClient}
          seeAll={() => adminDispatch.goTo('/admin/pricings/clients')}
          tooltip={priceTip.clients}
          showTooltip
        />
        {newPricing ? (
          <AdminPriceCreator
            theme={theme}
            itineraries={itineraries}
            clients={clients}
            adminDispatch={adminDispatch}
            detailedItineraries={detailedItineraries}
            transportCategories={transportCategories}
            closeForm={this.toggleCreator}
          />
        ) : (
          ''
        )}
      </div>
    )
  }
}
AdminPricingsIndex.propTypes = {
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  clients: PropTypes.arrayOf(PropTypes.client),
  adminDispatch: PropTypes.shape({
    getClientPricings: PropTypes.func,
    getRoutePricings: PropTypes.func
  }).isRequired,
  pricingData: PropTypes.shape({
    routes: PropTypes.array
  })
}

AdminPricingsIndex.defaultProps = {
  theme: null,
  hubs: [],
  clients: [],
  pricingData: null
}

export default AdminPricingsIndex
