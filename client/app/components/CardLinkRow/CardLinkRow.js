import React, {Component} from 'react';
import PropTypes from 'prop-types';
import { CardLink } from '../CardLink/CardLink';
import styles from './CardLinkRow.scss';
export class CardLinkRow extends Component {
    render() {
        const cards = this.props.cardArray.map(card => (
                <CardLink
                    key={card.name}
                    text={card.name}
                    img={card.img}
                    path={card.url}
                    handleClick={card.handleClick ? card.handleClick : this.props.handleClick}
                    theme={this.props.theme}
                    options={card.options}
                />
            )
        );
        return (
            <div className={`${styles.card_link_row} layout-row flex-100`}>
                { cards }
            </div>
        );
    }
}

CardLinkRow.propTypes = {
    theme: PropTypes.object,
    history: PropTypes.any,
    cardArray: PropTypes.array,
    handleClick: PropTypes.func
};

