import { mount } from 'enzyme'
import React from 'react'
import Checkbox from '../../Checkbox/Checkbox'
import WeekdayCheckboxes from './WeekdayCheckboxes'

let toggleWeekdays
let wrapper

describe('<WeekdayCheckboxes />', () => {
  beforeEach(() => {
    toggleWeekdays = jest.fn()
    wrapper = mount(<WeekdayCheckboxes toggleWeekdays={toggleWeekdays} weekdays={[1, 2, 3, 4, 5]} />)
  })

  it('renders without crashing', () => {
    expect(wrapper).toMatchSnapshot()
  })

  it('triggers the event on click', () => {
    wrapper.find(Checkbox).at(0).invoke('onChange')()

    expect(toggleWeekdays).toBeCalledWith(1)
  })
})
