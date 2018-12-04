import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { v4 } from 'uuid'
import PropTypes from '../../../prop-types'
import styles from './Card.scss'
import adminStyles from '../Admin.scss'
import {
  PricingButton,
  CardRoutes
} from './SubComponents'

import PricingSearchBar from './SubComponents/PricingSearchBar'
import { filters } from '../../../helpers'

class CardRoutesIndex extends Component {
  constructor (props) {
    super(props)
    this.state = {
      expander: {},
      searchText: '',
      page: 1,
      numPerPage: 12
    }
    this.handleClick = this.handleClick.bind(this)
    this.iconClasses = {
      ocean: 'anchor',
      air: 'paper-plane',
      rail: 'subway'
    }
  }
  componentDidMount () {
    this.prepPages()
  }

  handleClick (id) {
    const { adminDispatch, handleClick } = this.props
    if (handleClick) {
      handleClick(id)
    } else {
      adminDispatch.getItinerary(id, true)
    }
  }
  prepPages () {
    const { itineraries } = this.props
    const numPages = Math.ceil(itineraries.length / 12)
    this.setState({ numPages })
  }
  generateViewType (mot, limit) {
    return (
      <div className="layout-row flex-100 layout-align-start-center ">
        <div className="layout-row flex-100 layout-align-start-center layout-wrap">
          {this.generateCards(mot, limit)}
        </div>
      </div>
    )
  }
  toggleExpander (key) {
    this.setState({
      expander: {
        ...this.state.expander,
        [key]: !this.state.expander[key]
      }
    })
  }
  generateCards (mot, limit) {
    const { page, numPerPage } = this.state
    const {
      itineraries, hubs, theme, t
    } = this.props
    let itinerariesArr = []
    const sliceStartIndex = (page - 1) * numPerPage
    const sliceEndIndex = (page * numPerPage)

    itinerariesArr = this.updateSearch(itineraries)
      .slice(sliceStartIndex, sliceEndIndex)
      .map((rt, i) => (
        <CardRoutes
          key={v4()}
          hubs={hubs}
          itinerary={rt}
          theme={theme}
          handleClick={this.handleClick}
        />
      ))

    if (itinerariesArr.length < 1) {
      itinerariesArr.push(<h3 className="flex-none">{t('admin:noRoutes')}</h3>)
    }

    return itinerariesArr
  }

  updateSearch (array) {
    const { searchText } = this.state

    return filters.handleSearchChange(searchText, ['name'], array)
  }
  handlePricingSearch (event) {
    const { itineraries } = this.props
    this.setState(
      {
        searchText: event.target.value,
        page: 1
      },
      () => this.updateSearch(itineraries)
    )
  }
  deltaPage (val) {
    this.setState((prevState) => {
      const newPageVal = prevState.page + val
      const page = (newPageVal < 1 && newPageVal > prevState.numPages) ? 1 : newPageVal

      return { page }
    })
  }

  render () {
    const { searchText, page, numPages } = this.state
    const {
      limit, scope, toggleNew, mot, newText, sideMenuNodes, t
    } = this.props
    if (!scope) return ''

    return (
      <div className="flex-100 layout-row layout-align-md-space-between-start layout-align-space-around-start">

        <div
          className={`${styles.flex_titles} ${adminStyles.margin_box_right} margin_bottom
          flex-80 flex-sm-100 flex-xs-100 layout-row layout-wrap layout-align-start-start`}
        >

          <div
            className={`flex-100 layout-row layout-wrap layout-align-center-start card_padding_right ${
              styles.titles_btn
            }`}
          >

            <div className="flex-100 layout-row layout-align-center-start" style={{ minHeight: '560px' }}>
              {this.generateViewType(mot, limit)}
            </div>
            <div className="flex-95 layout-row layout-align-center-center margin_bottom">
              <div
                className={`
                      flex-15 layout-row layout-align-center-center pointy
                      ${styles.navigation_button} ${page === 1 ? styles.disabled : ''}
                    `}
                onClick={page > 1 ? () => this.deltaPage(-1) : null}
              >
                <i className="fa fa-chevron-left" />
                <p>&nbsp;&nbsp;&nbsp;&nbsp;{t('common:basicBack')}</p>
              </div>
              {}
              <p>{page}</p>
              <div
                className={`
                      flex-15 layout-row layout-align-center-center pointy
                      ${styles.navigation_button} ${page < numPages ? '' : styles.disabled}
                    `}
                onClick={page < numPages ? () => this.deltaPage(1) : null}
              >
                <p>{t('common:next')}&nbsp;&nbsp;&nbsp;&nbsp;</p>
                <i className="fa fa-chevron-right" />
              </div>
            </div>
          </div>

        </div>
        <div className="flex-20 layout-row layout-align-end-end">

          <div className="hide-sm hide-xs flex-100">
            <PricingSearchBar
              onChange={(e, target) => this.handlePricingSearch(e, target)}
              value={searchText}
              target={mot}
            />
            {sideMenuNodes}
            {toggleNew && scope.show_beta_features ? <PricingButton
              onClick={toggleNew}
              text={newText}
              onDisabledClick={() => console.log('this button is disabled')}
            /> : ''}

          </div>
        </div>
      </div>
    )
  }
}
CardRoutesIndex.propTypes = {
  t: PropTypes.func.isRequired,
  theme: PropTypes.theme,
  hubs: PropTypes.arrayOf(PropTypes.hub),
  itineraries: PropTypes.arrayOf(PropTypes.itinerary),
  limit: PropTypes.number,
  toggleNew: PropTypes.func,
  handleClick: PropTypes.func,
  adminDispatch: PropTypes.shape({
    getClientPricings: PropTypes.func,
    getRoutePricings: PropTypes.func
  }).isRequired,
  scope: PropTypes.scope,
  mot: PropTypes.string,
  newText: PropTypes.string,
  sideMenuNodes: PropTypes.arrayOf(PropTypes.node)
}

CardRoutesIndex.defaultProps = {
  theme: null,
  mot: '',
  hubs: [],
  itineraries: [],
  scope: null,
  limit: 9,
  toggleNew: null,
  handleClick: null,
  newText: '',
  sideMenuNodes: null
}

export default withNamespaces(['admin', 'common'])(CardRoutesIndex)
