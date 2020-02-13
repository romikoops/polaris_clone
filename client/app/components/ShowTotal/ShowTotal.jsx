import React from 'react'
import { numberSpacing } from '../../helpers'

function ShowTotal (props) {
  const { total } = props

  return (
    <span>
      {numberSpacing(total && total.value, 2)}
      &nbsp;
      {total && total.currency}
    </span>
  )
}

export default ShowTotal
