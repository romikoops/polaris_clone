import { toSnakeQueryString } from "./objectTools"

export function tableQueryStringBuilder (page, filters, sorted, pageSize) {
  const queryObj = {
    pageSize
  }
  queryObj.page = Math.max(page, 1)

  if (filters) {
    filters.forEach((filter) => {
      queryObj[filter.id] = filter.value
    })
  }

  if (sorted) {
    sorted.forEach((filter) => {
      queryObj[`${filter.id}_desc`] = filter.desc
    })
  }

  return toSnakeQueryString(queryObj, true)
}

export default tableQueryStringBuilder
