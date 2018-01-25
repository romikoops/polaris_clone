import React, { Component } from 'react';
import ReactTooltip from 'react-tooltip';
import { tooltips } from '../../constants';
export class Tooltip extends Component {
    constructor(props) {
        super(props);
    }
    render() {
        const {
            text,
            icon,
            theme,
            color
        } = this.props;
        const textStyle = color ? {color: color} : {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        const tipText = tooltips[text];
        const clipClass = color ? '' : 'clip';
        return(
            <div className="flex-none layout-row layout-align-center-center tooltip">
                <i className={`flex-none ${clipClass} fa ${icon}`} style={textStyle} data-tip={tipText}></i>
                <ReactTooltip />
            </div>
        );
    }
}
