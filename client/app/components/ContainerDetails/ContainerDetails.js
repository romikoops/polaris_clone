import React, { Component } from 'react';
import { CONTAINER_DESCRIPTIONS } from '../../constants';
import styles from './ContainerDetails.scss';
import PropTypes from 'prop-types';
import { HsCodeViewer } from '../HsCodes/HsCodeViewer';

export class ContainerDetails extends Component {
    constructor(props) {
        super(props);
        this.state =  {
            viewer: false
        };
        this.viewHsCodes = this.viewHsCodes.bind(this);
    }
    viewHsCodes()  {
        this.setState({
            viewer: !this.state.viewer
        });
        console.log(this.state.viewer);
    }
    render() {
        const cDesc = CONTAINER_DESCRIPTIONS;
        const { index, item, hsCodes, theme, viewHSCodes } = this.props;
        const viewer = this.state.viewer;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };
        return (
            <div className={` ${styles.info} layout-row flex-100 layout-wrap layout-align-center`}>
                <div className="flex-100 layout-row">
                    <h4>Unit {index + 1 }</h4>
                </div>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p>Gross Weight</p>
                    <p>{item.payload_in_kg} kg</p>
                </div>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p>Container Class</p>
                    <p>{cDesc[item.size_class]} </p>
                </div>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p>No. of Containers</p>
                    <p>{item.quantity} </p>
                </div>
                <hr className="flex-100"/>
                {viewHSCodes ?
                    <div className="flex-100 layout-row layout-wrap" onClick={this.viewHsCodes}>
                        <i className="fa fa-eye clip flex-none" style={textStyle} />
                        <p className="offset-5 flex-none">View Hs Codes</p>
                    </div> :
                    ''}
                { viewer ? <HsCodeViewer item={item} hsCodes={hsCodes} theme={theme} close={this.viewHsCodes}/> : ''}
            </div>
        );
    }
}
ContainerDetails.propTypes = {
    item: PropTypes.object,
    index: PropTypes.number
};
