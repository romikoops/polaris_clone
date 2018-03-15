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
  }
  componentWillReceiveProps (nextProps) {
    this.setState({ checked: nextProps.checked })
  }

  componentWillUnmount () {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
    }
  }

  handleChange (e) {
    this.props.onChange(!this.state.checked, e)
  }
  render () {
    const {
      disabled, theme, name
    } = this.props
    const { checked } = this.state
    const checkGradient = theme
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: 'black' }
    const sizeStyles = this.props.size ? { height: this.props.size, width: this.props.size } : {}
    const border = {
      border: `1px solid ${theme && theme.colors ? theme.colors.secondary : 'black'}`
    }
    const size = this.props.size ? +this.props.size.replace('px', '') : 25
    const iconStyles = Object.assign({ fontSize: `${Math.max(Math.min(size * 0.8, 15), 12)}px` }, checkGradient)

    return (
      <div className={`${styles.checkbox} flex-none`} style={border} onClick={this.props.onClick}>
        <label>
          <input
            type="checkbox"
            checked={checked}
            disabled={disabled}
            name={name}
            onChange={e => this.handleChange(e)}
          />
          <span style={sizeStyles}>
            <i className={`fa fa-check ${checked ? styles.show : ''}`} style={iconStyles} />
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
  onChange: PropTypes.func,
  onClick: PropTypes.func
}
Checkbox.defaultProps = {
  theme: null,
  checked: false,
  disabled: false,
  size: null,
  onChange: null,
  onClick: null
}

export default Checkbox
