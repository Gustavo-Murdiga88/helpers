const INDIVIDUAL_DOCUMENT_NUMBER_MASK = '###.###.###-##';
const BUSINESS_DOCUMENT_NUMBER_MASK = '##.###.###/####-##';
function maskDocument(value) {
  if (!value) return '';
  const cleanValue = String(value).replaceAll(/\.|\/|-/g, '');
  const mask =
    cleanValue.length === 11
      ? INDIVIDUAL_DOCUMENT_NUMBER_MASK
      : BUSINESS_DOCUMENT_NUMBER_MASK;
  let i = 0;
  return mask.replace(/#/g, (str) => {
    console.log(str,i);
    return cleanValue[i++]});
}

console.log(maskDocument('1111111111111'))
