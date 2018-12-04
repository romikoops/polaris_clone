import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import PropTypes from '../../prop-types'
import styles from './Admin.scss'
import { RoundButton } from '../RoundButton/RoundButton'
import {
  CONTAINER_DESCRIPTIONS,
  fclChargeGlossary,
  lclChargeGlossary,
  chargeGlossary
} from '../../constants'
import { history, gradientTextGenerator } from '../../helpers'
import { AdminPriceEditor } from './'

const containerDescriptions = CONTAINER_DESCRIPTIONS
const fclChargeGloss = fclChargeGlossary
const lclChargeGloss = lclChargeGlossary
const chargeGloss = chargeGlossary
export class AdminPricePanel extends Component {
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
    this.backToIndex = this.backToIndex.bind(this)
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
  render () {
    const {
      t, theme, pricingData, clientPricings, adminActions
    } = this.props
    const {
      editorBool, editTransport, editPricing, editHubRoute
    } = this.state
    console.log(this.props)

    if (!pricingData || !clientPricings) {
      return ''
    }

    const { itineraries, pricings, transportCategories } = pricingData
    const { client, userPricings, detailedItineraries } = clientPricings
    if (!client || !userPricings) {
      return ''
    }

    const textStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const backButton = (
      <div className="flex-none layout-row">
        <RoundButton
          theme={theme}
          size="small"
          text={t('common:basicBack')}
          handleNext={AdminPricePanel.backToIndex}
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
      // ;
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
              <i className="flex-none fa fa-pencil clip" style={textStyle} />
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
            className={`flex-33 layout-row layout-align-start-center ${styles.price_row_detail}`}
          >
            <p className="flex-none">{t('admin:modeOfTransport')}:</p>
            <div className="flex-5" />
            <p className="flex-none"> {transport.mode_of_transport}</p>
          </div>
          <div
            className={`flex-33 layout-row layout-align-start-center ${styles.price_row_detail}`}
          >
            <p className="flex-none">{t('admin:cargoType')}</p>
            <div className="flex-5" />
            <p className="flex-none">{transport.name}</p>
          </div>
          <div
            className={`flex-33 layout-row layout-align-start-center ${styles.price_row_detail}`}
          >
            <p className="flex-none">{t('admin:cargoClass')}</p>
            <div className="flex-5" />
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
          const gKey = `${hr.origin_stop_id}_${hr.destination_stop_id}_${tr.id}`
          const pricing = pricingsObj[uPriceObj[gKey]]
          if (pricing) {
            innerInner.push(<RPBInner
              key={v4()}
              hubRoute={hr}
              transport={tr}
              pricing={pricing}
              them={theme}
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
    const routeBoxes = itineraries.map((rt) => {
      const diArr = []
      detailedItineraries.forEach((di) => {
        if (rt.id === di.id) {
          diArr.push(di)
        }
      })

      return (
        <RoutePricingBox
          key={v4()}
          route={rt}
          hrArr={diArr}
          pricingsObj={pricings}
          uPriceObj={userPricings}
          transports={transportCategories}
        />
      )
    })

    return (
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
AdminPricePanel.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  clientPricings: PropTypes.shape({
    customer_id: PropTypes.number
  }),
  loading: PropTypes.func.isRequired,
  adminActions: PropTypes.func.isRequired,
  match: PropTypes.objectOf(PropTypes.any),
  pricingData: PropTypes.objectOf(PropTypes.any)

}

AdminPricePanel.defaultProps = {
  theme: null,
  clientPricings: [],
  match: {},
  pricingData: {}
}

export default withNamespaces(['admin', 'common'])(AdminPricePanel)
