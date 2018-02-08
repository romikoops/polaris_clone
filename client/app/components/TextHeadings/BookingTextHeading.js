'use strict';
import React, { Component } from 'react';
import PropsTypes from 'prop-types';
import { gradientTextGenerator } from '../../helpers/gradient';

export class BookingTextHeading extends Component {
    constructor(props) {
        super(props);
        this.state = {};
    }
    render() {
        const { text, theme, size } = this.props;
        let returnVal;
        if(size) {
            switch(size) {
                case 1:
                    returnVal = (
                        <h4 className="flex-none clip" style={gradientTextGenerator(theme.colors.primary, theme.colors.secondary)}>
                            {text}
                        </h4>
                    );
                    break;
                case 2:
                    returnVal = (
                        <h2 className="flex-none clip" style={gradientTextGenerator(theme.colors.primary, theme.colors.secondary)}>
                            {text}
                        </h2>
                    );
                    break;
                case 3:
                    returnVal = (
                        <h3 className="flex-none clip" style={gradientTextGenerator(theme.colors.primary, theme.colors.secondary)}>
                            {text}
                        </h3>
                    );
                    break;
                case 4:
                    returnVal = (
                        <h4 className="flex-none clip" style={gradientTextGenerator(theme.colors.primary, theme.colors.secondary)}>
                            {text}
                        </h4>
                    );
                    break;
                default: break;
            }
        }
        return(
            <div className="flex-100 layout-row layout-align-start">
                {returnVal}
            </div>
        );
    }
}

BookingTextHeading.PropsTypes = {
    text: PropsTypes.string,
    theme: PropsTypes.object
};
