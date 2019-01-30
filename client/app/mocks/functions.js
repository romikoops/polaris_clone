import { set, cloneDeep } from 'lodash'

/**
 * Checks if variable is an non-empty object
 *
 * True for `{a:1}`
 * False for `null, {}, [], [1,2,3]`
 */
const isObject = (x) => {
  const ok =
    x !== null && !Array.isArray(x) && typeof x === 'object'
  if (!ok) {
    return false
  }

  return Object.keys(x).length > 0
}
/* eslint-disable */
/**
 * Used in unit test to modify specific properties
 * with minimal lines of code
 *
 * You can specify `path` to be empty string
 * if the change affects more than one of object's branches
 */
export const change = (origin, pathRaw, rules) => {
  const willReturn = cloneDeep(origin)

  if (!isObject(rules)) {
    set(willReturn, pathRaw, rules)

    return willReturn
  }
  const path = pathRaw === '' ? '' : `${pathRaw}.`

  for (const ruleKey of Object.keys(rules)) {
    const rule = rules[ruleKey]
    if (!isObject(rule)) {
      set(willReturn, `${path}${ruleKey}`, rule)
      continue
    }

    Object.keys(rule)
      .filter(subruleKey => !isObject(rule[subruleKey]))
      .map(subruleKey => {
        const subrule = rule[subruleKey]
        set(willReturn, `${path}${ruleKey}.${subruleKey}`, subrule)
      })

    Object.keys(rule)
      .filter(subruleKey => isObject(rule[subruleKey]))
      .map(subruleKey => {
        const subrule = rule[subruleKey]
        Object.keys(subrule).map(deepKey => {
          const deep = rule[subruleKey][deepKey]
          set(
            willReturn,
            `${path}${ruleKey}.${subruleKey}.${deepKey}`,
            deep
          )
        })
      })
  }

  return willReturn
}
/* eslint-enable */
export const turnFalsy = (origin, path) => change(origin, path, null)
export const identity = x => x
