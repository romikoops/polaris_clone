import React, {Component} from 'react';
import PropTypes from 'prop-types';
import { Checkbox } from '../Checkbox/Checkbox';

export class ShipmentCargoItems extends Component {
    constructor(props) {
        super(props);
        this.state = {
            newCargoItem: {
                    weight: 0,
                    dimension_x: 0,
                    dimension_y: 0,
                    dimension_z: 0,
                    dangerousGoods: false
            }
        };
        this.handleCargoChange = this.handleCargoChange.bind(this);
        this.addNewCargo = this.addNewCargo.bind(this);
        this.toggleDangerousGoods = this.toggleDangerousGoods.bind(this);
    }
    handleCargoChange(event) {
        const {name, value} = event.target;
        this.setState({ newCargoItem: { ...this.state.newCargoItem, [name]: value } });
    }

    addNewCargo() {
        const newCont = this.state.newCargoItem;
        this.props.addCargoItem(newCont);
        this.setState({
            newCargoItem: {

                    weight: 0,
                    dimension_x: 0,
                    dimension_y: 0,
                    dimension_z: 0,
                    dangerousGoods: false
            }
        });
    }
    toggleDangerousGoods() {
        this.setState({ newCargoItem: { ...this.state.newCargoItem, dangerousGoods: !this.state.newCargoItem.dangerousGoods } });
    }
    render() {
        const cargosAdded = [];
        if (this.props.cargoItems) {
            this.props.cargoItems.forEach((cont, i) => {
                const tmpCont = (
            <div key={i} className="flex-100 layout-row">
              <div className="flex-20 layout-row layout-align-center-center">
                {cont.weight} kg
              </div>
              <div className="flex-20 layout-row layout-align-center-center">
                {cont.dimension_y} cm
              </div>
              <div className="flex-20 layout-row layout-align-center-center">
                {cont.dimension_x} cm
              </div>
              <div className="flex-20 layout-row layout-align-center-center">
                {cont.dimension_z} cm
              </div>
            </div>
            );
                cargosAdded.push(tmpCont);
            });
        }
        return (
        <div className="layout-row flex-100 layout-wrap layout-align-center-center" >
            <div className="layout-row flex-75 layout-wrap layout-align-center-center" >
              <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                  <p className="flex-100"> Gross Weight </p>
                  <input name="weight" value={this.state.newCargoItem.weight} type="number" onChange={this.handleCargoChange}/>
                </div>
                <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                  <p className="flex-100"> Length </p>
                  <input name="dimension_y" value={this.state.newCargoItem.dimension_y} type="number" onChange={this.handleCargoChange}/>
                </div>
                <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                  <p className="flex-100"> Width </p>
                  <input name="dimension_x" value={this.state.newCargoItem.dimension_x} type="number" onChange={this.handleCargoChange}/>
                </div>
                <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                  <p className="flex-100"> Height </p>
                  <input name="dimension_z" value={this.state.newCargoItem.dimension_z} type="number" onChange={this.handleCargoChange}/>
                </div>
                <div className="layout-row flex-20 layout-wrap layout-align-start-center" >
                  <p className="flex-100"> Dangerous Goods </p>
                  <Checkbox onChange={this.toggleDangerousGoods} checked={this.state.newCargoItem.dangerousGoods} />
                </div>
              </div>
              <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                <div className="layout-row flex-none layout-align-start-center" onClick={this.addNewCargo}>
                  <i className="flex-none fa fa-plus-square-o" />
                  <p className="flex-none flex-offset-5"> Add unit </p>
                </div>
              </div>
              <div className="layout-row flex-100 layout-wrap layout-align-start-center" >
                <div className="layout-row flex-100 layout-wrap" >
                  { cargosAdded }
                </div>
              </div>
            </div>
          </div>
        );
    }
}

ShipmentCargoItems.PropTypes = {
    theme: PropTypes.object,
    cargoItems: PropTypes.array,
    addCargoItem: PropTypes.func
};
