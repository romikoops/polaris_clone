import React, { Component } from 'react';
// import PropTypes from 'prop-types';
import {Async} from 'react-select';
// import fetch from 'isomorphic-fetch';
import 'react-select/dist/react-select.css';
import styled from 'styled-components';
// import { authHeader } from '../../helpers';
// import { BASE_URL } from '../../constants';
export class NamedAsync extends Component {
    constructor(props) {
        super(props);
        this.state = {
            working: true
        };
        this.onChangeFunc = this.onChangeFunc.bind(this);
    }
    onChangeFunc(optionsSelected) {
        const nameKey = this.props.name;
        this.props.onChange(nameKey, optionsSelected);
    }

    render() {
        const {value, classes, ref, name, autoload, multi, loadOptions} = this.props;
        console.log(value, multi, name, ref, autoload);
        const StyledSelect = styled(Async)`
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
               name={name}
               multi={multi}
               className={classes}
               value={''}
               autoload={autoload}
               loadOptions={loadOptions}
               onChange={this.onChangeFunc}
            />
        );
    }
}
