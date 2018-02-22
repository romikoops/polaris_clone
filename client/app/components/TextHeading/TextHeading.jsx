
import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { gradientTextGenerator } from '../../helpers/gradient'
import styles from './TextHeading.scss'

export class TextHeading extends Component {
  constructor (props) {
    super(props)
    this.state = {}
  }
  render () {
    const {
      text, theme, size, color
    } = this.props
    let returnVal
    const styling = !color && theme
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color }
    const generalStyle = `${styles.text_style} flex-none ${!color ? 'clip' : ''}`
    if (size) {
      switch (size) {
        case 1:
          returnVal = (

            <h1 className={generalStyle} style={styling}>
              {text}
            </h1>
          )
          break
        case 2:
          returnVal = (
            <h2 className={generalStyle} style={styling}>
              {text}
            </h2>
          )
          break
        case 3:
          returnVal = (
            <h3 className={generalStyle} style={styling}>
              {text}
            </h3>
          )
          break
        case 4:
          returnVal = (
            <h4 className={generalStyle} style={styling}>
              {text}
            </h4>
          )
          break
        default: break
      }
    }
    return (
      <div className="flex-100 layout-row layout-align-start">
        {returnVal}
      </div>
    )
  }
}

TextHeading.propTypes = {
  text: PropTypes.string.isRequired,
  theme: PropTypes.theme,
  size: PropTypes.number.isRequired,
  color: PropTypes.string
}
TextHeading.defaultProps = {
  theme: {},
  color: ''
}
export default TextHeading
