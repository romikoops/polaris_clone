import React, { Component } from 'react'
import { Redirect } from 'react-router'
import PropTypes from '../../prop-types'
// import { Link } from 'react'
import styles from './CardLink.scss'
// import { connect } from 'react-redux';
import { tenantDefaults } from '../../constants'

export class CardLink extends Component {
  constructor (props) {
    super(props)
    this.state = {
      redirect: false
    }
  }
  render () {
    const {
      text, img, path, options
    } = this.props
    if (this.state.redirect) {
      return <Redirect push to={this.props.path} />
    }
    const theme = this.props.theme
      ? this.props.theme
      : tenantDefaults.theme
    const handleClick = path ? () => this.setState({ redirect: true }) : this.props.handleClick

    const backgroundSize = options && options.contained ? 'contain' : 'cover'
    const imgClass = { backgroundImage: `url(${img})`, backgroundSize }
    const gradientStyle = {
      background: theme ? `-webkit-linear-gradient(left, ${theme.colors.brightPrimary} 0%, ${theme.colors.brightSecondary} 100%)` : 'black'
    }
    return (
      <div className={`${styles.card_link}  layout-column flex-100 flex-gt-sm-30`} onClick={handleClick} >
        <div className={`${styles.card_img}  flex-85`} style={imgClass} />
        <div className={`${styles.card_action}  flex-15 layout-row layout-align-space-between-center`}>
          <div className="flex-none layout-row layout-align-center-center" >
            <p className="flex-none">{text} </p>
          </div>
          <div className="flex-none layout-row layout-align-center-center">
            <i className="flex-none fa fa-chevron-right" style={gradientStyle} />
          </div>
        </div>
      </div>
    )
  }
}

CardLink.propTypes = {
  text: PropTypes.string.isRequired,
  img: PropTypes.string.isRequired,
  theme: PropTypes.theme,
  path: PropTypes.string.isRequired,
  handleClick: PropTypes.func,
  options: PropTypes.shape({
    contained: PropTypes.bool
  }).isRequired
}

CardLink.defaultProps = {
  theme: null,
  handleClick: null
}

export default CardLink
