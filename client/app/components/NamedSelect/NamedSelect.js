import React, { Component } from 'react';
// import PropTypes from 'prop-types';
import Select from 'react-select';
import 'react-select/dist/react-select.css';
import styled from 'styled-components';
export class NamedSelect extends Component {
    constructor(props) {
        super(props);
        this.state = {
            working: true
        };
        this.onChangeFunc = this.onChangeFunc.bind(this);
    }
    onChangeFunc(optionSelected) {
        const modifiedOptionSelected = Object.assign({}, optionSelected);
        modifiedOptionSelected.name = this.props.name;

        this.props.onChange(modifiedOptionSelected);
    }
    render() {
        const props = Object.assign({}, this.props);
        delete props.onChange;

        const StyledSelect = styled(Select)`
            .Select-control {
                background-color: #F9F9F9;
                box-shadow: 0 2px 3px 0 rgba(237,234,234,0.5);
                border: 1px solid #F2F2F2 !important;
            }
            .Select-menu-outer {
                box-shadow: 0 2px 3px 0 rgba(237,234,234,0.5);
                border: 1px solid #F2F2F2;
            }
            .Select-value {
                background-color: #F9F9F9;
                border: 1px solid #F2F2F2;
            }
            .Select-option {
                background-color: #F9F9F9;
            }
        `;
        return(
            <StyledSelect
                {...props}
                onChange={this.onChangeFunc}
            />
        );
    }
}
