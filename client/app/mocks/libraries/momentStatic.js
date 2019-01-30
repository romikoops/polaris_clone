import moment from 'moment'

require('moment-timezone')

const constantDate = new Date('June 13, 2017 04:41:20 GMT+1:00')

// eslint-disable-next-line
Date = class extends Date {
  constructor () {
    super()

    return constantDate
  }
}

moment.tz.setDefault('Europe/Amsterdam')
