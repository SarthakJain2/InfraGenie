var rg = resourceGroup().name
var index = lastIndexOf(rg, '-')
var nextIndex = (index > 0) ? int(substring(rg, index + 1)) : 1
output index string = padLeft(nextIndex, 3, '0')
