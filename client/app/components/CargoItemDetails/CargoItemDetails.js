import React, { Component } from 'react';
import styles from './CargoItemDetails.scss';
import PropTypes from 'prop-types';
import { HsCodeViewer } from '../HsCodes/HsCodeViewer';

export class CargoItemDetails extends Component {
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
        const { index, item, hsCodes, theme } = this.props;
        const viewer = this.state.viewer;
        const textStyle = {
            background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        };

        return (
            <div className={`${styles.info} layout-row flex-100 layout-wrap layout-align-center`}>
                <div className="flex-100">
                    <h4>Unit {index + 1}</h4>
                </div>
                <hr/>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p>Gross Weight</p>
                    <p>{item.payload_in_kg} kg</p>
                </div>
                <hr className="flex-100"/>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p>Length</p>
                    <p>{item.dimension_y} cm</p>
                </div>
                <hr className="flex-100"/>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p>Width</p>
                    <p>{item.dimension_x} cm</p>
                </div>
                <hr className="flex-100"/>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p>Height</p>
                    <p>{item.dimension_z} cm</p>
                </div>
                <hr className="flex-100"/>
                <div className="flex-100 layout-row layout-align-space-between">
                    <p>Volume</p>
                    <p>{(item.dimension_y * item.dimension_x * item.dimension_y) / 1000000} m<sup>3</sup></p>
                </div>
                <hr className="flex-100"/>
                <div className="flex-100 layout-row layout-wrap" onClick={this.viewHsCodes}>
                    <i className="fa fa-eye clip flex-none" style={textStyle} />
                    <p className="offset-5 flex-none">View Hs Codes</p>
                </div>
                { viewer ? <HsCodeViewer item={item} hsCodes={hsCodes} theme={theme} close={this.viewHsCodes}/> : ''}
            </div>
        );
    }
}
CargoItemDetails.propTypes = {
    item: PropTypes.object,
    index: PropTypes.number
};
