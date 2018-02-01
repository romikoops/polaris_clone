import React, { Component } from 'react';

export class TooltipHelper extends Component {
    constructor(props) {
        super(props);
    }
    render() {
        const { text } = this.props;
        return(
            <div className="flex-20 layout-align-start-center" >{text}</div>
        );
    }
}
