import React, { Component } from 'react';
import PropTypes from 'prop-types';
import {AdminRouteTile} from './';
import styles from './Admin.scss';
import {v4} from 'node-uuid';
import FileUploader from '../../components/FileUploader/FileUploader';
export class AdminRoutesIndex extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    render() {
        const {theme, hubs, routes, viewRoute} = this.props;
        if (!routes) {
            return '';
        }

        const routesArr = routes.map((rt) => <AdminRouteTile key={v4()} hubs={hubs} route={rt} theme={theme} handleClick={viewRoute}/>);

        const hubUrl = '/admin/routes/process_csv';
        // const textStyle = {
        //     background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        // };
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}>
                    <p className="flex-none">Upload Routes Sheet</p>
                    <FileUploader theme={theme} url={hubUrl} type="xlsx" text="Hub .xlsx"/>
                </div>
                <div className="layout-row flex-100 layout-wrap layout-align-start-center">
                    {routesArr}
                </div>
            </div>
        );
    }
}
AdminRoutesIndex.propTypes = {
    theme: PropTypes.object,
    hubs: PropTypes.array,
    routes: PropTypes.array,
    viewClient: PropTypes.func
};
