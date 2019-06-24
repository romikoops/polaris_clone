import React, { PureComponent } from 'react'
import styles from './Checkbox.scss'
import { gradientTextGenerator } from '../../helpers'

class Checkbox extends PureComponent {
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
      disabled, theme, name, id, required
    } = this.props
    const { checked } = this.state
    const checkGradient = theme
      ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
      : { color: 'black' }
    const sizeStyles = this.props.size ? { height: this.props.size, width: this.props.size } : {}
    const border = {
      border: `1px solid #BDBDBD`
    }
    const size = this.props.size ? +this.props.size.replace('px', '') : 25
    const iconStyles = Object.assign({ fontSize: `${Math.max(Math.min(size * 0.8, 15), 12)}px` }, checkGradient)

    return (
      <div
        className={`${styles.checkbox} ${this.props.className} flex-none`}
        style={border}
        onClick={this.props.onClick}
      >
        <label>
          <input
            id={id}
            className={required ? 'required' : ''}
            type="checkbox"
            checked={checked}
            disabled={disabled}
            name={name}
            required={required}
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

Checkbox.defaultProps = {
  theme: null,
  checked: false,
  disabled: false,
  size: null,
  onChange: null,
  onClick: null,
  className: '',
  id: null
}

export default Checkbox
