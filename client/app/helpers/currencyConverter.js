export const converter = (amount, fromCurrency, rates) => {
    const rate = rates.filter(x => x.key === fromCurrency)[0];
    const convertedValue = amount * (1 / rate.rate);
    return convertedValue;
};
