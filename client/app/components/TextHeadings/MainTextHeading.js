'use strict';
import React, { Component } from 'react';
import PropsTypes from 'prop-types';
import { gradientGenerator } from '../../helpers/gradient';

export class MainTextHeading extends Component {
    constructor(props) {
        super(props);
        this.state = {};
    }
    render() {
        const { text, theme } = this.props;
        return(
            <div className="flex-100 layout-row layout-align-start-center">
                <h1>
                    <p className="flex-none clip" style={gradientGenerator(theme.colors.primary, theme.colors.secondary)}>{text}</p>
                </h1>
            </div>
        );
    }
}

MainTextHeading.PropsTypes = {
    text: PropsTypes.string,
    theme: PropsTypes.object
};
