import React, { Component } from 'react'
import { withNamespaces } from 'react-i18next'
import { Redirect } from 'react-router'
import PropTypes from '../../prop-types'
import styles from './CardLink.scss'
import { tenantDefaults } from '../../constants'
import { gradientTextGenerator } from '../../helpers'

class CardLink extends Component {
  constructor (props) {
    super(props)
    this.state = {
      redirect: false
    }
  }
  render () {
    const {
      text, img, path, options, code, selectedType, allowedCargoTypes, t
    } = this.props
    if (this.state.redirect) {
      return <Redirect push to={this.props.path} />
    }
    const theme = this.props.theme ? this.props.theme : tenantDefaults.theme
    const handleClick = path ? () => this.setState({ redirect: true }) : this.props.handleClick
    const buttonStyle = code && selectedType === code ? styles.selected : styles.unselected
    const backgroundSize = options && options.contained ? 'contain' : 'cover'
    const imgStyles = { backgroundImage: `url(${img})`, backgroundSize }
    const gradientStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }
    const inActive = !allowedCargoTypes[code]
      ? (
        <div className={`${styles.inactive} flex-none layout-row layout-align-center-end`}>
          <h3 className="flex-none">{t('common:comingSoon')}</h3>
        </div>
      ) : ''

    return (
      <div
        className={`${styles.card_link}  layout-column flex-none ${buttonStyle}`}
        onClick={allowedCargoTypes[code] ? handleClick : ''}
      >
        {inActive}
        <div className={`${styles.card_img} flex-85`} style={imgStyles} />
        <div
          className={`${styles.card_action} flex-15 layout-row layout-align-space-between-center`}
        >
          <div className="flex-none layout-row layout-align-center-center">
            <p className="flex-none">{text} </p>
          </div>
          <div className="flex-none layout-row layout-align-center-center">
            {code && selectedType === code ? (
              <i className="flex-none fa fa-check" style={gradientStyle} />
            ) : (
              ''
            )}
          </div>
        </div>
      </div>
    )
  }
}

CardLink.propTypes = {
  text: PropTypes.string.isRequired,
  t: PropTypes.func.isRequired,
  img: PropTypes.string.isRequired,
  theme: PropTypes.theme,
  path: PropTypes.string.isRequired,
  selectedType: PropTypes.string,
  code: PropTypes.string,
  handleClick: PropTypes.func,
  options: PropTypes.shape({
    contained: PropTypes.bool
  }).isRequired,
  allowedCargoTypes: PropTypes.objectOf(PropTypes.bool)
}

CardLink.defaultProps = {
  theme: null,
  handleClick: null,
  selectedType: '',
  code: '',
  allowedCargoTypes: {}
}

export default withNamespaces('common')(CardLink)
