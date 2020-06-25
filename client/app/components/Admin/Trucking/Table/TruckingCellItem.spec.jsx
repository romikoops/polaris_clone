import React from 'react'
import { shallow } from 'enzyme'
import TruckingCellItem from './TruckingCellItem'

const defaultProps = {
  displayText: 'Maersk',
  handleClick: () => {}
}
describe('<TruckingCellItem />', () => {
  describe('Shallow rendering', () => {
    let wrapper
    beforeEach(() => {
      wrapper = shallow(<TruckingCellItem {...defaultProps} />)
    })

    it('should render without any errors', () => {
      expect(wrapper).toMatchSnapshot()
    })
  })
})
