import React, {Component} from 'react';
import PropTypes from 'prop-types';
import { CardLink } from '../CardLink/CardLink';
import './CardLinkRow.scss';
export class CardLinkRow extends Component {
    render() {
        const cards = [];
        this.props.cardArray.forEach(shop => {
            cards.push(<CardLink key={shop.name} text={shop.name} img={shop.img} path={shop.url} handleLink={this.handleLink} theme={this.props.theme} />);
        });
        return (
          <div className="card_link_row layout-row flex-100">
            { cards }
          </div>
        );
    }
}

CardLinkRow.propTypes = {
    theme: PropTypes.object,
    history: PropTypes.any,
    cardArray: PropTypes.array
};

