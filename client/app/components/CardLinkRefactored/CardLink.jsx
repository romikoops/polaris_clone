import React, { Component } from 'react'
import { Redirect } from 'react-router'
import PropTypes from '../../prop-types'
import styles from './CardLink.scss'
import { tenantDefaults } from '../../constants'
import { gradientTextGenerator } from '../../helpers'
import { trim } from '../../classNames'

export class CardLink extends Component {
  constructor (props) {
    super(props)
    this.state = {
      redirect: false
    }
  }
  render () {
    const {
      allowedCargoTypes,
      code,
      img,
      options,
      path,
      selectedType,
      text
    } = this.props
    if (this.state.redirect) {
      return <Redirect push to={this.props.path} />
    }
    const theme = this.props.theme ? this.props.theme : tenantDefaults.theme

    const handleClickFn = () => this.setState({ redirect: true })
    const handleClick = path ? handleClickFn : this.props.handleClick

    const buttonStyle = code && selectedType === code ? styles.selected : styles.unselected

    const backgroundSize = options && options.contained ? 'contain' : 'cover'

    const imgStyles = {
      backgroundImage: `url(${img})`, backgroundSize
    }
    const gradientStyle =
      theme && theme.colors
        ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
        : { color: 'black' }

    const inActive = () => {
      if (allowedCargoTypes[code]) {
        return ''
      }

      return (
        <div className={trim(`
          ${styles.inactive} 
          flex-none 
          layout-row 
          layout-align-center-end
        `)}
        >
          <h3 className="flex-none">Coming Soon</h3>
        </div>
      )
    }

    const Icon = () => {
      const ok = code && selectedType === code

      if (!ok) {
        return ''
      }

      return (
        <i
          className="flex-none fa fa-check"
          style={gradientStyle}
        />
      )
    }

    const onClickContainer = allowedCargoTypes[code] ? handleClick : ''

    return (
      <div
        onClick={onClickContainer}
        className={trim(`
          ${styles.card_link}
          layout-column flex-none 
          ${buttonStyle}
        `)}
      >
        {inActive()}

        <div
          style={imgStyles}
          className={`${styles.card_img} flex-85`}
        />

        <div
          className={trim(`
            ${styles.card_action} 
            flex-15 
            layout-row
            layout-align-space-between-center
          `)}
        >
          <div className={trim(`
            flex-none
            layout-row
            layout-align-center-center
          `)}
          >
            <p className="flex-none">{text} </p>
          </div>

          <div className={trim(`
            flex-none 
            layout-row 
            layout-align-center-center
          `)}
          >
            {Icon()}
          </div>
        </div>
      </div>
    )
  }
}

CardLink.propTypes = {
  code: PropTypes.string,
  handleClick: PropTypes.func,
  img: PropTypes.string.isRequired,
  path: PropTypes.string.isRequired,
  selectedType: PropTypes.string,
  text: PropTypes.string.isRequired,
  theme: PropTypes.theme,
  options: PropTypes.shape({
    contained: PropTypes.bool
  }).isRequired,
  allowedCargoTypes: PropTypes.objectOf(PropTypes.bool)
}

CardLink.defaultProps = {
  allowedCargoTypes: {},
  code: '',
  handleClick: null,
  selectedType: '',
  theme: null
}

export default CardLink
