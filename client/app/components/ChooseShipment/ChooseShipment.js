import React, { Component } from 'react';
import PropTypes from 'prop-types';
import styles from './ChooseShipment.scss';
import { FlashMessages } from '../FlashMessages/FlashMessages';
import defs from '../../styles/default_classes.scss';
export class ChooseShipment extends Component {
    componentDidMount() {
        window.scrollTo(0, 0);
    }
    render() {
        const { theme, messages, shipmentTypes, selectShipment } = this.props;
        const color = theme
            ? theme.colors.primary
            : 'black';
        const cards = [];

        shipmentTypes.forEach((shop, i) => {
            const display = shop.name;
            const imgClass = { backgroundImage: 'url(' + shop.img + ')' };
            const textColour = { color: color };
            cards.push(
                <div
                    key={i}
                    className={`${
                        styles.card_link
                    } layout-column flex-100 flex-gt-sm-30`}
                    onClick={() => selectShipment(shop.code)}
                >
                    <div
                        className={`${styles.card_img} flex-85`}
                        style={imgClass}
                    />
                    <div
                        className={`${
                            styles.card_action
                        } flex-15 layout-row layout-align-space-between-center`}
                    >
                        <div className="flex-none layout-row layout-align-center-center">
                            <p className="flex-none">{display} </p>
                        </div>
                        <div className="flex-none layout-row layout-align-center-center">
                            <i
                                className="flex-none fa fa-chevron-right"
                                style={textColour}
                            />
                        </div>
                    </div>
                </div>
            );
        });
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
                    {cards}
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
