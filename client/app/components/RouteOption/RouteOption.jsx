import React, { Component } from 'react'
import PropTypes from '../../prop-types'
import styles from './RouteOption.scss'

export class RouteOption extends Component {
  static faIcon (modeOfTransport) {
    const faKeywords = {
      ocean: 'ship',
      air: 'plane',
      train: 'train'
    }
    const faClass = `fa fa-${faKeywords[modeOfTransport]}`
    return <i className={faClass} />
  }
  static dashedGradient (color1, color2) {
    return `linear-gradient(to right, transparent 70%, white 30%), linear-gradient(to right, ${color1}, ${color2})`
  }
  constructor (props) {
    super(props)
    this.routeSelected = this.routeSelected.bind(this)
  }
  routeSelected () {
    this.props.routeSelected(this.props.route)
  }

  render () {
    const { theme, route } = this.props
    const originNexus = route.origin_nexus
    const destinationNexus = route.destination_nexus
    const modesOfTransport = Object.keys(route.modes_of_transport)
      .filter(mot => route.modes_of_transport[mot])
    // const modesOfTransport  = ['ocean', 'air', 'train'];
    // route.dedicated = Math.random() < 0.3;
    const dashedLineStyles = {
      marginTop: '6px',
      height: '2px',
      width: '100%',
      background:
        theme && theme.colors
          ? RouteOption.dashedGradient(theme.colors.primary, theme.colors.secondary)
          : 'black',
      backgroundSize: '16px 2px, 100% 2px'
    }
    const icons = modesOfTransport.map(mot => RouteOption.faIcon(mot))
    const dedicatedDecoratorStyles = {
      borderTop: route.dedicated
        ? `28px solid ${theme.colors.primary}66`
        : '28px solid transparent',
      borderLeft: '55px solid transparent'
    }
    const dedicatedDecoratorIconStyles = {
      WebkitTextFillColor: 'transparent',
      WebkitTextStroke: route.dedicated ? '2px white' : '0px transparent'
    }

    return (
      <div className={`${styles.route_option} flex-30`} onClick={this.routeSelected}>
        <div className={`flex-100 layout-row layout-align-center ${styles.top_row}`}>
          <div className={styles.dedicated_decorator} style={dedicatedDecoratorStyles}>
            <i className="fa fa-star" style={dedicatedDecoratorIconStyles} />
          </div>

          <div className={` flex-none ${styles.connection_graphics}`}>
            <i className={`fa fa-map-marker ${styles.map_marker}`} />
            <i className={`fa fa-flag-o ${styles.flag}`} />
            <div className="flex-none layout-row layout-align-center-center">{icons}</div>
            <div style={dashedLineStyles} />
          </div>
        </div>
        <div className={`flex-100 layout-row layout-align-space-between ${styles.top_row}`}>
          <div className={` flex-50 layout-row layout-align-center-center ${styles.header_hub}`}>
            {/* <div className="flex-100 layout-row"> */}
            <h4 className="flex-100"> {originNexus} </h4>
            {/* </div> */}
          </div>
          <div className={` flex-50 layout-row layout-align-center-center ${styles.header_hub}`}>
            {/* <div className="flex-100 layout-row"> */}
            <h4 className="flex-100"> {destinationNexus} </h4>
            {/* </div> */}
          </div>
        </div>
      </div>
    )
  }
}
RouteOption.propTypes = {
  theme: PropTypes.theme,
  route: PropTypes.route.isRequired,
  routeSelected: PropTypes.bool
}
RouteOption.defaultProps = {
  theme: null,
  routeSelected: false
}
export default RouteOption
