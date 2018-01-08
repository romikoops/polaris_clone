import React, { Component } from 'react';
import PropTypes from 'prop-types';
// import {AdminRouteTile} from './';
import styles from './Admin.scss';
// import {v4} from 'node-uuid';
import FileUploader from '../../components/FileUploader/FileUploader';
import { AdminSearchableRoutes } from './AdminSearchables';
export class AdminRoutesIndex extends Component {
    constructor(props) {
        super(props);
        this.state = {
        };
    }
    componentDidMount() {
        const { routes, loading, adminDispatch } = this.props;
        if (!routes && !loading) {
            adminDispatch.getRoutes(false);
        }
    }
    render() {
        const {theme, viewRoute, hubs, routes, adminDispatch} = this.props;
        if (!routes) {
            return '';
        }

        // const routesArr = routes.map((rt) => <AdminRouteTile key={v4()} hubs={hubs} route={rt} theme={theme} handleClick={viewRoute}/>);

        const hubUrl = '/admin/routes/process_csv';
        // const textStyle = {
        //     background: theme && theme.colors ? '-webkit-linear-gradient(left, ' + theme.colors.primary + ',' + theme.colors.secondary + ')' : 'black'
        // };
        return(
            <div className="flex-100 layout-row layout-wrap layout-align-start-start">
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.sec_upload}`}>
                    <p className="flex-none">Upload Routes Sheet</p>
                    <FileUploader theme={theme} url={hubUrl} type="xlsx" text="Routes .xlsx"/>
                </div>
                <AdminSearchableRoutes routes={routes} theme={theme} hubs={hubs} adminDispatch={adminDispatch} sideScroll={false} handleClick={viewRoute}/>
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
