import React, { Component } from 'react'
import { v4 } from 'node-uuid'
import ReactTooltip from 'react-tooltip'
import PropTypes from '../../prop-types'
import { AdminPriceEditor } from './'
import styles from './Admin.scss'
import { RoundButton } from '../RoundButton/RoundButton'
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
      theme, pricingData, clientPricings, adminActions
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
        heading="Are you sure?"
        text="This will delete the pricing immediately and all related data"
        confirm={() => this.deletePricing(pricingToDelete)}
        deny={() => this.closeConfirm()}
      />
    ) : (
      ''
    )
    const {
      routes, pricings, hubRoutes, transportCategories
    } = pricingData
    const { client, userPricings } = clientPricings
    const textStyle = {
      background:
        theme && theme.colors
          ? `-webkit-linear-gradient(left, ${theme.colors.primary},${theme.colors.secondary})`
          : 'black'
    }
    const backButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text="Back"
          handleNext={AdminPricingClientView.backToIndex}
          iconClass="fa-chevron-left"
        />
      </div>
    )

    const noPricing = (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
            {client.first_name} {client.last_name}
          </p>
          {backButton}
        </div>

        <div className="layout-row flex-100 layout-wrap layout-align-start-center">
          <h4 className="flex-none"> No dedicated pricings available</h4>
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
      // eslint-disable-next-line no-underscore-dangle
      if (pricing._id.includes('lcl')) {
        gloss = lclChargeGloss
      } else {
        gloss = fclChargeGloss
      }
      // eslint-disable-next-line no-underscore-dangle
      if (this.state.open[pricing._id]) {
        toggleStyle = styles.show_style
      } else {
        toggleStyle = styles.hide_style
      }
      // eslint-disable-next-line no-underscore-dangle
      const expandIcon = this.state.open[pricing._id] ? (
        <i className="flex-none fa fa-chevron-up clip" style={textStyle} />
      ) : (
        <i className="flex-none fa fa-chevron-down clip" style={textStyle} />
      )
      Object.keys(pricing.data).forEach((key) => {
        const cells = []
        Object.keys(pricing.data[key]).forEach((chargeKey) => {
          if (chargeKey !== 'currency' && chargeKey !== 'rate_basis') {
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
              // eslint-disable-next-line no-underscore-dangle
              onClick={() => this.viewThis(pricing._id)}
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
            <p className="flex-none">Cargo Type: </p>
            <p className="flex-none">{transport.name}</p>
          </div>
          <div
            className={`flex-33 layout-row layout-align-space-between-center ${
              styles.price_row_detail
            }`}
          >
            <p className="flex-none">Cargo Class:</p>
            <p className="flex-none"> {containerDescriptions[transport.cargo_class]}</p>
          </div>
          {panel}
        </div>
      )
    }
    const RoutePricingBox = ({
      route, hrArr, uPriceObj, pricingsObj, transports
    }) => {
      // if (!uPriceObj) {
      //     return '';
      // }
      const inner = hrArr.map((hr) => {
        const innerInner = []
        transports.forEach((tr) => {
          const gKey = `${hr.id}_${tr.id}`
          const pricing = pricingsObj[uPriceObj[gKey]]
          if (pricing) {
            innerInner
              .push(<RPBInner
                key={v4()}
                hubRoute={hr}
                transport={tr}
                pricing={pricing}
                theme={theme}
              />)
          }
        })
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
            <h3 className="flex-none clip"> {route.name} </h3>
          </div>
          <div className="flex-100 layout-row layout-wrap layout-align-space-between-center">
            {inner}
          </div>
        </div>
      )
    }
    const routeBoxes = routes.map((rt) => {
      const relHR = []
      hubRoutes.forEach((hr) => {
        if (hr.route_id === rt.id) {
          relHR.push(hr)
        }
      })
      return (
        <RoutePricingBox
          key={v4()}
          route={rt}
          hrArr={relHR}
          pricingsObj={pricings}
          uPriceObj={userPricings}
          transports={transportCategories}
        />
      )
    })

    return (
      <div className="flex-100 layout-row layout-wrap layout-align-start-start">
        {confimPrompt}
        <div
          className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_title}`}
        >
          <p className={` ${styles.sec_title_text} flex-none`} style={textStyle}>
            {client.first_name} {client.last_name}
          </p>
          {backButton}
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

export default AdminPricingClientView
