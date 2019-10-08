import React, { Component } from 'react'
import Select from 'react-select'
import 'react-select/dist/react-select.css'
import styled from 'styled-components'

const StyledSelect = styled(Select)`
  .Select-control {
    background: ${props => (props.showErrors ? props.errorStyles.background : '#F9F9F9')};
    box-shadow: 0 2px 3px 0 rgba(237,234,234,0.5);
    border: 1px solid #F2F2F2 !important;
  }
  .Select-placeholder {
    background: ${props => (props.showErrors ? props.errorStyles.background : 'unset')};
    ${props => (props.showErrors ? `color: ${props.errorStyles.color};` : '')}
  }
  .Select-menu-outer {
    box-shadow: 0 2px 3px 0 rgba(237,234,234,0.5);
    border: 1px solid #F2F2F2;
  }
  .Select-value {
    border: 1px solid #F2F2F2;
  }
  .Select-option {
    background: #F9F9F9;
  }
`

export class StandardSelect extends Component {
  constructor (props) {
    super(props)
    this.onChangeFunc = this.onChangeFunc.bind(this)
    this.errorStyles = {
      background: 'rgba(232, 114, 88, 0.3)',
      borderColor: 'rgba(232, 114, 88, 0.01)',
      color: 'rgba(211, 104, 80, 1)'
    }
  }

  onChangeFunc (optionSelected) {
    this.props.onChange(optionSelected)
  }

  render () {
    const props = Object.assign({}, this.props)
    delete props.onChange

    return (
      <StyledSelect
        {...props}
        onChange={this.onChangeFunc}
        errorStyles={this.errorStyles}
      />
    )
  }
}

export default StandardSelect
