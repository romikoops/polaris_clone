import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from '../Admin.scss';
import { AdminClientTile } from '../';
import {v4} from 'node-uuid';
import Fuse from 'fuse.js';
import { MainTextHeading } from '../../TextHeadings/MainTextHeading';
export class AdminSearchableClients extends Component {
    constructor(props) {
        super(props);
        this.state = {
            clients: props.clients
        };
        this.handleSearchChange = this.handleSearchChange.bind(this);
        this.handleClick = this.handleClick.bind(this);
        this.seeAll = this.seeAll.bind(this);
    }
    handleClick(client) {
        const {handleClick, adminDispatch} = this.props;
        if (handleClick) {
            handleClick(client);
        } else {
            adminDispatch.getClient(client.id, true);
        }
    }
    seeAll() {
        const {seeAll, adminDispatch} = this.props;
        if (seeAll) {
            seeAll();
        } else {
            adminDispatch.goTo('/clients');
        }
    }
    handleSearchChange(event) {
        if (event.target.value === '') {
            this.setState({
                clients: this.props.clients
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
            const fuse = new Fuse(this.props.clients, options);
            console.log(fuse);
            return fuse.search(event.target.value);
        };
        const filteredClients = search(['first_name', 'last_name', 'company_name', 'phone', 'email']);

        this.setState({
            clients: filteredClients
        });
    }
    render() {
        const { theme, title, seeAll} = this.props;
        const { clients } = this.state;
        let clientsArr;
        if (clients) {
            clientsArr = clients.map((client) => {
                return  <AdminClientTile key={v4()} client={client} theme={theme}  handleClick={this.handleClick} />;
            });
        }
        const viewType = this.props.sideScroll ?
            (<div className={`layout-row flex-100 layout-align-start-center ${styles.slider_container}`}>
                <div className={`layout-row flex-none layout-align-start-center ${styles.slider_inner}`}>
                    {clientsArr}
                </div>
            </div>) :
            (<div className="layout-row flex-100 layout-align-start-center ">
                <div className="layout-row flex-none layout-align-start-center layout-wrap">
                    {clientsArr}
                </div>
            </div>);
        return(
            <div className={`layout-row flex-100 layout-wrap layout-align-start-center ${styles.searchable}`}>
                <div className={`flex-100 layout-row layout-align-space-between-center ${styles.searchable_header}`}>
                    <div className="flex-50 layoput-row layout-align-start-center">
                        <MainTextHeading theme={theme} text={title ? title : 'Clients'} />
                    </div>
                    <div className={`${styles.input_box} flex-50 laypout-row layout-align-start`}>
                        <input
                            type="text"
                            name="search"
                            placeholder="Search clients"
                            onChange={this.handleSearchChange}
                        />
                    </div>
                </div>
                <div className="flex-100 layout-row layout-align-center layout-align-space-between">
                    {viewType}
                </div>
                { seeAll !== false ? (<div className="flex-100 layout-row layout-align-end-center">
                    <div className="flex-none layout-row layout-align-center-center" onClick={this.seeAll}>
                        <p className="flex-none">See all</p>
                    </div>
                </div>) : ''}
            </div>
        );
    }
}
AdminSearchableClients.propTypes = {
    tenant: PropTypes.object,
    theme: PropTypes.object,
    user: PropTypes.object,
    loggedIn: PropTypes.bool,
    dispatch: PropTypes.func,
    history: PropTypes.object,
    match: PropTypes.object
};
