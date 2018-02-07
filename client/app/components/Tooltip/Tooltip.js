import React, { Component } from 'react';
import ReactTooltip from 'react-tooltip';
import { tooltips } from '../../constants';
import { v4 } from 'node-uuid';
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
        const id = v4();
        return(
            <div className="flex-none layout-row layout-align-center-center">
                <p className={`flex-none ${clipClass} fa ${icon}`} style={textStyle} data-tip={tipText} data-for={id} />
                <div className="flex-30">
                    <ReactTooltip id={id} className="flex-20"/>
                </div>
            </div>
        );
    }
}
