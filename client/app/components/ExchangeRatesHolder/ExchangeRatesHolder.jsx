import React from 'react'
import { flatten, isEmpty } from 'lodash'
import { withNamespaces } from 'react-i18next'

const ExchangeRatesHolder = (props) => {
  const { exchangeRates, t } = props
  const ExchangeRateItem = ({ from, to, value }) => {
    const identifier = `${from}-${to}`

    return (
      <p key={identifier} id={identifier}>{`1 ${from} = ${value} ${to}`}</p>
    )
  }

  const formatExchangeRateItem = (exchange) => {
    const exchangeObj = { ...exchange }
    const baseCurrency = exchange.base
    delete exchangeObj.base
    const exchanges = Object.entries(exchangeObj).map(([key, value]) => ({
      from: baseCurrency.toUpperCase(),
      to: key.toUpperCase(),
      value: Number(value).toPrecision(3)
    }))

    return exchanges
  }

  const buildExchangesRates = () => {
    const rates = exchangeRates.filter((rate) => !isEmpty(rate))
    if (!rates.length) return []
    const formattedRates = flatten(
      rates.map((rate) => formatExchangeRateItem(rate))
    )

    // lodash uniq does not dedupe correctly because of the nature of object
    return Array.from(
      new Set(formattedRates.map((rate) => JSON.stringify(rate)))
    )
  }

  const rates = buildExchangesRates()

  return (
    <>
      {!!rates.length && (
        <>
          <p>{t('exchangeRates')}</p>
          {buildExchangesRates().map((rateItem) => (
            <ExchangeRateItem
              key={`rateItem-${JSON.parse(rateItem).value}`}
              {...JSON.parse(rateItem)}
            />
          ))}
        </>
      )}
    </>
  )
}

export default withNamespaces('shipment')(ExchangeRatesHolder)
