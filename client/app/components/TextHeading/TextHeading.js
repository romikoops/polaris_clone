'use strict';
import React, { Component } from 'react';
import PropsTypes from 'prop-types';
import { gradientTextGenerator } from '../../helpers/gradient';

export class TextHeading extends Component {
    constructor(props) {
        super(props);
        this.state = {};
    }
    render() {
        const { text, theme, size, warning} = this.props;
        let returnVal;
        const styling = !warning ? gradientTextGenerator(theme.colors.primary, theme.colors.secondary)
            : {color: '#DE2A2A'};
        if(size) {
            switch(size) {
                case 1:
                    returnVal = (
                        <h1 className="flex-none clip" style={styling}>
                            {text}
                        </h1>
                    );
                    break;
                case 2:
                    returnVal = (
                        <h2 className="flex-none clip" style={styling}>
                            {text}
                        </h2>
                    );
                    break;
                case 3:
                    returnVal = (
                        <h3 className="flex-none clip" style={styling}>
                            {text}
                        </h3>
                    );
                    break;
                case 4:
                    returnVal = (
                        <h4 className="flex-none clip" style={styling}>
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

TextHeading.PropsTypes = {
    text: PropsTypes.string,
    theme: PropsTypes.object
};
