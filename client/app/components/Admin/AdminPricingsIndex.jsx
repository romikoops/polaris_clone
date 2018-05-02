import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { Redirect } from 'react-router'
import { AdminPriceCreator } from './'
import { AdminSearchableClients } from './AdminSearchables'
// import FileUploader from '../../components/FileUploader/FileUploader'
// import DocumentsDownloader from '../../components/Documents/Downloader'
import { adminPricing as priceTip } from '../../constants'
import CardPricingIndex from './CardPricingIndex'

// import styles from './Admin.scss'

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
      theme, pricingData, clients, adminDispatch, scope
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
    // const newButton = (
    //   <div className={styles.btn_wrapper}>
    //     <p data-tip={priceTip.new} data-for="newPriceTip">
    //       <RoundButton
    //         text="New Pricing"
    //         theme={theme}
    //         size="small"
    //         handleNext={this.toggleCreator}
    //         iconClass="fa-plus"
    //         active
    //       />
    //     </p>
    //     <ReactTooltip id="newPriceTip" className={styles.tooltip} effect="solid" />
    //   </div>
    // )
    const { itineraries, detailedItineraries, transportCategories } = pricingData

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <CardPricingIndex
          itineraries={detailedItineraries}
          theme={theme}
          scope={scope}
          adminDispatch={adminDispatch}
          toggleCreator={this.toggleCreator}
        />
        {/* <AdminSearchableRoutes
          itineraries={detailedItineraries}
          theme={theme}
          hubs={hubs}
          handleClick={this.viewRoute}
          seeAll={() => adminDispatch.goTo('/admin/pricings/routes')}
          tooltip={priceTip.routes}
          showTooltip
        /> */}
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
  clients: PropTypes.arrayOf(PropTypes.client),
  adminDispatch: PropTypes.shape({
    getClientPricings: PropTypes.func,
    getRoutePricings: PropTypes.func
  }).isRequired,
  documentDispatch: PropTypes.shape({
    closeViewer: PropTypes.func,
    uploadPricings: PropTypes.func
  }).isRequired,
  pricingData: PropTypes.shape({
    routes: PropTypes.array
  }),
  scope: PropTypes.scope
}

AdminPricingsIndex.defaultProps = {
  theme: null,
  clients: [],
  pricingData: null,
  scope: null
}

export default AdminPricingsIndex
