import React, { PureComponent } from 'react'
import PropTypes from '../../prop-types'
import styles from './Checkbox.scss'
import { gradientTextGenerator } from '../../helpers'

export class Checkbox extends PureComponent {
  constructor (props) {
    super(props)
    this.state = {
      checked: props.checked
    }
    this.handleChange = this.handleChange.bind(this)
  }

  componentWillUnmount () {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
    }
  }

  handleChange () {
    this.setState({
      checked: !this.state.checked
    })
    this.props.onChange(!this.state.checked)
  }
  render () {
    const { disabled, theme, name } = this.props
    const { checked } = this.state
    const checkGradient = theme
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: 'black' }
    const sizeStyles = this.props.size ? { height: this.props.size, width: this.props.size } : {}
    const border = {
      border: `1px solid ${theme && theme.colors ? theme.colors.secondary : 'black'}`
    }
    return (
      <div className={`${styles.checkbox} flex-none`} style={border} onClick={this.props.onClick}>
        <label>
          <input
            type="checkbox"
            checked={checked}
            disabled={disabled}
            name={name}
            onChange={this.handleChange}
          />
          <span style={sizeStyles}>
            <i className={`fa fa-check ${checked ? styles.show : ''}`} style={checkGradient} />
          </span>
        </label>
      </div>
    )
  }
}
Checkbox.propTypes = {
  checked: PropTypes.bool,
  disabled: PropTypes.bool,
  name: PropTypes.string.isRequired,
  theme: PropTypes.theme,
  size: PropTypes.string,
  onChange: PropTypes.func.isRequired,
  onClick: PropTypes.func.isRequired
}
Checkbox.defaultProps = {
  theme: null,
  checked: false,
  disabled: false,
  size: null
}

export default Checkbox
