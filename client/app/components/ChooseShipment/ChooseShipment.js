import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './ChooseShipment.scss';
import { FlashMessages } from '../FlashMessages/FlashMessages';
import defs from '../../styles/default_classes.scss';
import { CardLinkRow } from '../CardLinkRow/CardLinkRow';
import { LOAD_TYPES } from '../../constants';

export class ChooseShipment extends Component {
    constructor(props) {
        super(props);
        const cards = LOAD_TYPES.map((loadType) => (
            {
                name: loadType.name,
                img: loadType.img,
                options: { contained: true },
                handleClick: () => this.props.selectLoadType(loadType.code)
            }
        ));
        this.state = { cards: cards};
    }
    render() {
        const { theme, messages } = this.props;
        const flash = messages && messages.length > 0 ? <FlashMessages messages={messages} /> : '';
        return (
            <div
                className={`${
                    styles.card_link_row
                } layout-row flex-100 layout-align-center`}
            >
                {flash}
                <div className={`flex-none ${defs.content_width} layout-row layout-align-start-center layout-wrap`}>
                    <div
                        className={` ${
                            styles.header
                        } flex-100 layout-row layout-align-start-center`}
                    >
                        <p className="flex-none"> Choose your shipment type</p>
                    </div>
                    <CardLinkRow theme={theme} cardArray={this.state.cards} />
                </div>
            </div>
        );
    }
}

ChooseShipment.propTypes = {
    theme: PropTypes.object,
    shipmentTypes: PropTypes.array,
    selectShipment: PropTypes.func,
    messages: PropTypes.array
};
