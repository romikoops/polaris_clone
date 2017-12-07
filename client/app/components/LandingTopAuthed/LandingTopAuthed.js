import styles from './LandingTopAuthed.scss';
import React, { Component } from 'react';
import PropTypes            from 'prop-types';
import { CardLinkRow }      from '../CardLinkRow/CardLinkRow';
import Header               from '../Header/Header';
import defaults from '../../styles/default_classes.scss';
export class LandingTopAuthed extends Component {
    constructor(props) {
        super(props);
        this.state = {
            shops: [
                {
                    name: 'Book a shipment',
                    url: '/booking',
                    img: 'https://assets.itsmycargo.com/assets/cityimages/performance_sm.jpg'
                },
                {
                    name: 'My Shipments',
                    url: '/shipments',
                    img: 'https://assets.itsmycargo.com/assets/cityimages/shipping-containers_sm.jpg'
                }
            ]
        };
    }
    render() {
        const {user, theme} = this.props;
        const handleClick = () => this.setState({ redirect: true });
        return (
            <div className={styles.landing_top_authed + ' layout-wrap layout-row flex-100 layout-align-center'}>
                <Header user={user} theme={theme} />
                <div className={'layout-row flex-none layout-wrap ' + defaults.content_width}>
                    <div className="flex-100 layout-wrap layout-row">
                        <p className={styles.header_text} >What would you like to do?</p>
                        <CardLinkRow theme={theme} cardArray={this.state.shops} handleClick={handleClick} />
                    </div>
                </div>
            </div>
        );
    }
}

LandingTopAuthed.propTypes = {
    theme: PropTypes.object,
    user: PropTypes.object
};
