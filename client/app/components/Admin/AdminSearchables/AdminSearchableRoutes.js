import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from '../Admin.scss';
import { AdminRouteTile } from '../';
import {v4} from 'node-uuid';
import Fuse from 'fuse.js';
export class AdminSearchableRoutes extends Component {
    constructor(props) {
        super(props);
        this.state = {
            routes: props.routes
        };
        this.handleSearchChange = this.handleSearchChange.bind(this);
        this.handleClick = this.handleClick.bind(this);
        this.seeAll = this.seeAll.bind(this);
    }
    seeAll() {
        const {seeAll, adminDispatch} = this.props;
        if (seeAll) {
            seeAll();
        } else {
            adminDispatch.goTo('/clients');
        }
    }
    handleClick(route) {
        const {handleClick, adminDispatch} = this.props;
        if (handleClick) {
            handleClick(route);
        } else {
            adminDispatch.getRoute(route.id, true);
        }
    }
    handleSearchChange(event) {
        if (event.target.value === '') {
            this.setState({
                routes: this.props.routes
            });
            return;
        }
        const search = (keys) => {
            const options = {
                shouldSort: true,
                tokenize: true,
                threshold: 0.2,
                location: 0,
                distance: 50,
                maxPatternLength: 32,
                minMatchCharLength: 5,
                keys: keys
            };
            const fuse = new Fuse(this.props.routes, options);
            console.log(fuse);
            return fuse.search(event.target.value);
        };

        const filteredRoutesOrigin = search('origin_nexus');
        const filteredRoutesDestination = search('destination_nexus');

        let TopRoutes = filteredRoutesDestination.filter(route => (
            filteredRoutesOrigin.includes(route)
        ));

        if(TopRoutes.length === 0) {
            TopRoutes = filteredRoutesDestination.concat(filteredRoutesOrigin);
        }
        this.setState({
            routes: TopRoutes
        });
    }
    render() {
        const { hubs, theme, seeAll } = this.props;
        const { routes } = this.state;
        let routesArr;
        if (routes) {
            routesArr = routes.map((rt) => {
                return  <AdminRouteTile key={v4()} hubs={hubs} route={rt} theme={theme} handleClick={this.handleClick}/>;
            });
        } else if (this.props.routes) {
            routesArr = routes.map((rt) => {
                return  <AdminRouteTile key={v4()} hubs={hubs} route={rt} theme={theme} handleClick={this.handleClick}/>;
            });
        }
        const viewType = this.props.sideScroll ?
            (<div className={`layout-row flex-100 layout-align-start-center ${styles.slider_container}`}>
                <div className={`layout-row flex-none layout-align-start-center ${styles.slider_inner}`}>
                    {routesArr}
                </div>
            </div>) :
            (<div className="layout-row flex-100 layout-align-start-center ">
                <div className="layout-row flex-none layout-align-start-center layout-wrap">
                    {routesArr}
                </div>
            </div>);
        return(
            <div className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.searchable}`}>
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.searchable_header}`}>
                    <div className="flex-none layput-row layout-align-start-center">
                        <p className="flex-none sub_header_text"> Routes</p>
                    </div>
                    <div className={`${styles.input_box} flex-none layput-row layout-align-start-center`}>
                        <input
                            type="text"
                            name="search"
                            placeholder="Search route"
                            onChange={this.handleSearchChange}
                        />
                    </div>
                </div>
                {viewType}
                { seeAll !== false ?
                    <div className="flex-100 layout-row layout-align-end-center">
                        <div className="flex-none layout-row layout-align-center-center" onClick={this.seeAll}>
                            <p className="flex-none">See all</p>
                        </div>
                    </div> :
                    ''
                }
            </div>
        );
    }
}
AdminSearchableRoutes.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object
};
