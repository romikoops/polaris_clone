import React, {Component} from 'react';
import PropTypes from 'prop-types';
import './ChooseShipment.scss';
export class ChooseShipment extends Component {
    render() {
        const cards = [];
        const color = this.props.theme ? this.props.theme.colors.primary : 'black';
        console.log(this.props);
        this.props.shipmentTypes.forEach((shop, i) => {
            let display = shop.name;
            let imgClass = { backgroundImage: 'url(' + shop.img + ')'};
            let textColour = { color: color };
            cards.push(
                <div key={i} className="card_link card layout-column flex-100 flex-gt-sm-30" onClick={() => this.props.selectShipment(shop.code)} >
                  <div className="card_img card flex-85" style={imgClass}>
                  </div>
                  <div className="card_action card flex-15 layout-row layout-align-space-between-center">
                    <div className="flex-none layout-row layout-align-center-center" >
                      <p className="flex-none">{display} </p>
                    </div>
                    <div className="flex-none layout-row layout-align-center-center">
                      <i className="flex-none fa fa-chevron-right" style={textColour} ></i>
                    </div>
                  </div>
                </div>
            );
        });
        return (
          <div className="card_link_row layout-row flex-100">
            { cards }
          </div>
        );
    }
}

ChooseShipment.propTypes = {
    theme: PropTypes.object,
    shipmentTypes: PropTypes.array,
    selectShipment: PropTypes.func
};

