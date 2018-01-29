'use strict';
import React, { Component } from 'react';
import PropsTypes from 'prop-types';
import Gradient from '../../helpers/gradient';

export class MainHeading extends Component {
    constructor(props) {
        super(props);
        this.state = {};
    }
    render() {
        const { text } = this.props;
        return(
            <p>
                <h1 styles={Gradient}>{text}</h1>
            </p>
        );
    }
}

MainHeading.PropsTypes = {
    text: PropsTypes.string
};
