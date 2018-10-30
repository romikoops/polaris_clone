import React, { Component } from 'react'
import { Async } from 'react-select'
import styled from 'styled-components'
import '../../styles/select-css-custom.scss'
import PropTypes from '../../prop-types'

export class NamedAsync extends Component {
  constructor (props) {
    super(props)
    this.onChangeFunc = this.onChangeFunc.bind(this)
  }
  onChangeFunc (optionsSelected) {
    const nameKey = this.props.name
    this.props.onChange(nameKey, optionsSelected)
  }

  render () {
    const {
      value, classes, ref, name, autoload, multi, loadOptions
    } = this.props
    const StyledSelect = styled(Async)`
      .Select-control {
        background-color: #f9f9f9;
        /*background-color: #000;*/
        box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
        border: 1px solid #f2f2f2 !important;
      }
      .Select-menu-outer {
        box-shadow: 0 2px 3px 0 rgba(237, 234, 234, 0.5);
        border: 1px solid #f2f2f2;
        /*background-color: #000;*/
        z-index: 25 !important;
      }
      .Select-value {
        background-color: #f9f9f9;
        border: 1px solid #f2f2f2;
      }
      .Select-option {
        background-color: #f9f9f9;
        z-index: 40;
      }
    `

    return (
      <StyledSelect
        name={name}
        multi={multi}
        className={classes}
        value={value}
        ref={ref}
        autoload={autoload}
        loadOptions={loadOptions}
        onChange={this.onChangeFunc}
      />
    )
  }
}

NamedAsync.propTypes = {
  name: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
  classes: PropTypes.string.isRequired,
  ref: PropTypes.string.isRequired,
  autoload: PropTypes.bool.isRequired,
  multi: PropTypes.bool.isRequired,
  loadOptions: Async.propTypes.loadOptions.isRequired
}

NamedAsync.defaultProps = {}

export default NamedAsync
