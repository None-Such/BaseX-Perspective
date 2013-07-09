// check if element has horizontal scrollbar
$.fn.HasHorizontalScrollBar = function() {
  //note: clientHeight= height of holder
  //scrollHeight= we have content till this height
  var _elm = $(this)[0];
  var _hasScrollBar = false; 
  if ((_elm.clientWidth < _elm.scrollWidth)) {
      _hasScrollBar = true;
  }
  return _hasScrollBar;
}