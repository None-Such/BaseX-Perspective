// Method for formatting numbers, e.g. 1000 -> 1,000
var numberCommaDelimitedFormat = function (number) {
  return number.replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,")
}

Object.numberCommaDelimitedFormat = numberCommaDelimitedFormat;

// making the formatting method available for jquery dom elements
$.fn.commaDelimitedDigits = function () { 
  return this.each(function () { 
    $(this).text( numberCommaDelimitedFormat($(this).text()) ); 
  })
}