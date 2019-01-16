
import React, { Component } from 'react'
import PropTypes from 'prop-types'
import styles from './TextHeading.scss'

class TextHeading extends Component {
  constructor (props) {
    super(props)
    this.state = {}
  }
  render () {
    const {
      text, size, color, Comp
    } = this.props
    let returnVal
    const styling = color ? {
      color: { color }
    }
      : { color: 'black' }
    if (size) {
      switch (size) {
        case 1:
          returnVal = (

            <h1 className={`${styles.text_style} flex`} style={styling}>
              {text}{' '}{Comp}
            </h1>
          )
          break
        case 2:
          returnVal = (
            <h2 className={`${styles.text_style} flex`} style={styling}>
              {text}{' '}{Comp}
            </h2>
          )
          break
        case 3:
          returnVal = (
            <h3 className={`${styles.text_style} flex`} style={styling}>
              {text}{' '}{Comp}
            </h3>
          )
          break
        case 4:
          returnVal = (
            <h4 className={`${styles.text_style} flex`} style={styling}>
              {text}{' '}{Comp}
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
  size: PropTypes.number.isRequired,
  color: PropTypes.string,
  Comp: PropTypes.func
}
TextHeading.defaultProps = {
  color: '',
  Comp: undefined
}
export default TextHeading
