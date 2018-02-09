'use strict';
import React, { Component } from 'react';
import PropsTypes from 'prop-types';
import { gradientGenerator } from '../../helpers/gradient';

export class SubTextHeading extends Component {
    constructor(props) {
        super(props);
        this.state = {};
    }
    render() {
        const { text, theme } = this.props;
        return(
            <div className="flex-100 layout-row layout-align-start-center">
                <h2>
                    <p className="flex-none clip" style={gradientGenerator(theme.colors.primary, theme.colors.secondary)}>{text}</p>
                </h2>
            </div>
        );
    }
}

SubTextHeading.PropsTypes = {
    text: PropsTypes.string,
    theme: PropsTypes.object
};
