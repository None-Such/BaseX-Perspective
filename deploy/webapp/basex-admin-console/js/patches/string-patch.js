// Returns the width of a string given font object
// default font assumed = '10px sans-serif'
String.prototype.getWidth = function (font) {
  var f = font || '10px sans-serif',
      o = $('<div>' + this + '</div>')
            .css({'position': 'absolute', 'float': 'left', 'white-space': 'nowrap', 'visibility': 'hidden', 'font': f})
            .appendTo($('body')),
      w = o.width();
  o.remove();
  return w;
}