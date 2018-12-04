import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import ReactTooltip from 'react-tooltip'
import PropTypes from '../../prop-types'
import { AdminPriceEditor } from './'
import styles from './Admin.scss'
import AdminPromptConfirm from './Prompt/Confirm'
import {
  CONTAINER_DESCRIPTIONS,
  fclChargeGlossary,
  lclChargeGlossary,
  chargeGlossary,
  adminPricing as priceTip
} from '../../constants'
import { history } from '../../helpers'

const containerDescriptions = CONTAINER_DESCRIPTIONS
const fclChargeGloss = fclChargeGlossary
const lclChargeGloss = lclChargeGlossary
const chargeGloss = chargeGlossary
export class AdminPricingClientView extends Component {
  static backToIndex () {
    history.goBack()
  }

  constructor (props) {
    super(props)
    this.state = {
      editorBool: false,
      editTransport: false,
      editPricing: false,
      editHubRoute: false,
      open: {}
    }
    this.editThis = this.editThis.bind(this)
    this.viewThis = this.viewThis.bind(this)
    this.closeEdit = this.closeEdit.bind(this)
  }
  componentDidMount () {
    const {
      clientPricings, loading, adminActions, match
    } = this.props
    if (!clientPricings && !loading) {
      adminActions.getClientPricings(parseInt(match.params.id, 10), false)
    }
    window.scrollTo(0, 0)
  }
  editThis (pricing, hubRoute, transport) {
    this.setState({
      editPricing: pricing,
      editHubRoute: hubRoute,
      editTransport: transport,
      editorBool: true
    })
  }
  viewThis (pricingId) {
    this.setState({
      open: { ...this.state.open, [pricingId]: !this.state.open[pricingId] }
    })
  }
  closeEdit () {
    this.setState({
      editPricing: false,
      editHubRoute: false,
      editTransport: false,
      editorBool: false
    })
  }
  deletePricing () {
    const { adminActions } = this.props
    const { pricingToDelete } = this.state
    adminActions.deletePricing(pricingToDelete)
    this.closeConfirm()
  }
  confirmDelete (pricing) {
    this.setState({
      confirm: true,
      pricingToDelete: pricing
    })
  }
  closeConfirm () {
    this.setState({ confirm: false })
  }

  render () {
    const {
      t, theme, pricingData, clientPricings, adminActions
    } = this.props
    const {
      editorBool,
      editTransport,
      editPricing,
      editHubRoute,
      confirm,
      pricingToDelete
    } = this.state

    if (!pricingData || !clientPricings) {
      return ''
    }
    const confimPrompt = confirm ? (
      <AdminPromptConfirm
        theme={theme}
        heading={t('common:areYouSure')}
        text={t('admin:confirmDeletePricing')}
        confirm={() => this.deletePricing(pricingToDelete)}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )
    const { client, userPricings } = clientPricings
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const noPricing = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
            {client.first_name} {client.last_name}
          </p>
        </div>

        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          <h4 className="flex-none">{t('admin:noDedicatedPricings')}</h4>
        </div>
      </div>
    )
    if (!userPricings) {
      return noPricing
    }

    const RPBInner = ({ hubRoute, pricing, transport }) => {
      const panel = []
      let gloss
      let toggleStyle

      if (transport.cargo_class.includes('lcl')) {
        gloss = lclChargeGloss
      } else {
        gloss = fclChargeGloss
      }

      if (this.state.open[pricing.id]) {
        toggleStyle = styles.show_style
      } else {
        toggleStyle = styles.hide_style
      }

      const expandIcon = this.state.open[pricing.id] ? (
        <i className="flex-none fa fa-chevron-up clip" style={textStyle} />
      ) : (
        <i className="flex-none fa fa-chevron-down clip" style={textStyle} />
      )
      const dnrKeys = ['currency', 'rate_basis', 'range']
      Object.keys(pricing.data).forEach((key) => {
        const cells = []

        Object.keys(pricing.data[key]).forEach((chargeKey) => {
          if (dnrKeys.indexOf(chargeKey) < 0) {
            cells.push(<div
              className={`flex-25 layout-row layout-align-none-center layout-wrap ${
                styles.price_cell
              }`}
            >
              <p className="flex-100">{chargeGloss[chargeKey]}</p>
              <p className="flex">
                {pricing.data[key][chargeKey]} {pricing.data[key].currency}
              </p>
            </div>)
          } else if (chargeKey === 'rate_basis') {
            cells.push(<div
              className={`flex-25 layout-row layout-align-none-center layout-wrap ${
                styles.price_cell
              }`}
            >
              <p className="flex-100">{chargeGloss[chargeKey]}</p>
              <p className="flex">{chargeGloss[pricing.data[key][chargeKey]]}</p>
            </div>)
          }
        })
        panel.push(<div
          className={`flex-100 layout-row layout-align-none-center layout-wrap ${
            styles.expand_panel
          } ${toggleStyle}`}
        >
          <div
            className={`flex-100 layout-row layout-align-start-center ${styles.price_subheader}`}
          >
            <p className="flex-none">
              {key} - {gloss[key]}
            </p>
          </div>
          <div className="flex-100 layout-row layout-align-start-center">{cells}</div>
        </div>)
      })

      const tooltipId = v4()

      return (
        <div
          key={v4()}
          className={` ${
            styles.hub_route_price
          } flex-100 layout-row layout-wrap layout-align-center-start`}
        >
          <div className="flex-100 layout-row layout-align-start-center">
            <div className="flex-90 layout-row layout-align-start-center">
              <i className="fa fa-map-signs clip" style={textStyle} />
              <p className="flex-none offset-5">{hubRoute.name}</p>
            </div>
            <div
              className="flex-10 layout-row layout-align-center-center"
              onClick={() => this.editThis(pricing, hubRoute, transport)}
            >
              <i
                className="flex-none fa fa-pencil clip"
                style={textStyle}
                data-for={tooltipId}
                data-tip={priceTip.manage}
              />
              <ReactTooltip className={styles.tooltip} id={tooltipId} effect="solid" />
            </div>
            <div
              className="flex-10 layout-row layout-align-center-center"
              onClick={() => this.viewThis(pricing.id)}
            >
              {expandIcon}
            </div>
          </div>
          <div
            className={`flex-33 layout-row layout-align-space-between-center ${
              styles.price_row_detail
            }`}
          >
            <p className="flex-none">MoT:</p>
            <p className="flex-none"> {transport.mode_of_transport}</p>
          </div>
          <div
            className={`flex-33 layout-row layout-align-space-between-center ${
              styles.price_row_detail
            }`}
          >
            <p className="flex-none">{t('admin:cargoType')}</p>
            <p className="flex-none">{transport.name}</p>
          </div>
          <div
            className={`flex-33 layout-row layout-align-space-between-center ${
              styles.price_row_detail
            }`}
          >
            <p className="flex-none">{t('admin:cargoClass')}</p>
            <p className="flex-none"> {containerDescriptions[transport.cargo_class]}</p>
          </div>
          {panel}
        </div>
      )
    }
    const RoutePricingBox = ({ routeData, pricingsArr }) => {
      const inner = pricingsArr.map((pricingObj) => {
        const innerInner = []
        innerInner.push(<RPBInner
          key={v4()}
          hubRoute={routeData}
          transport={pricingObj.transport_category}
          pricing={pricingObj.pricing}
          theme={theme}
        />)

        return innerInner
      })

      return (
        <div
          key={v4()}
          className={` ${
            styles.route_price
          } flex-100 layout-row layout-wrap layout-align-start-start `}
        >
          <div className="flex-100 layout-row layout-align-start-center">
            <h3 className="flex-none clip"> {routeData.name} </h3>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
            {inner}
          </div>
        </div>
      )
    }
    const routeBoxes = Object.keys(userPricings).map((itKey) => {
      const { itinerary, pricings } = userPricings[itKey]

      return <RoutePricingBox key={v4()} routeData={itinerary} pricingsArr={pricings} />
    })

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start extra_padding">
        {confimPrompt}
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
            {client.first_name} {client.last_name}
          </p>
        </div>

        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          {routeBoxes}
        </div>
        {editorBool ? (
          <AdminPriceEditor
            closeEdit={this.closeEdit}
            theme={theme}
            hubRoute={editHubRoute}
            transport={editTransport}
            userId={client.id}
            isNew={false}
            pricing={editPricing}
            adminTools={adminActions}
          />
        ) : (
          ''
        )}
      </div>
    )
  }
}
AdminPricingClientView.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  adminActions: PropTypes.shape({
    getClientPricings: PropTypes.func
  }).isRequired,
  clientPricings: PropTypes.shape({
    client: PropTypes.client,
    userPricings: PropTypes.object
  }).isRequired,
  loading: PropTypes.bool,
  match: PropTypes.match.isRequired,
  pricingData: PropTypes.shape({
    routes: PropTypes.array,
    pricings: PropTypes.array,
    hubRoutes: PropTypes.array,
    transportCategories: PropTypes.array
  }).isRequired
}

AdminPricingClientView.defaultProps = {
  theme: null,
  loading: false
}

export default withNamespaces(['admin', 'common'])(AdminPricingClientView)
