'use strict';
import React, { Component } from 'react';
import PropsTypes from 'prop-types';
import { gradientTextGenerator } from '../../helpers';
export class MainTextHeading extends Component {
    constructor(props) {
        super(props);
        this.state = {};
    }
    render() {
        const { text, theme } = this.props;
        const headerStyle = theme && theme.colors ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary) : {color: 'black'};
        return(
            <div className="flex-100 layout-row layout-align-start-center">
                <h1>
                    <p className="flex-none clip" style={headerStyle}>{text}</p>
                </h1>
            </div>
        );
    }
}

MainTextHeading.PropsTypes = {
    text: PropsTypes.string,
    theme: PropsTypes.object
};
