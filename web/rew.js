(function() {
  var head = document.getElementsByTagName('head')[0];
  var script = document.createElement('script');
  script.setAttribute('type', 'text/javascript');
  script.setAttribute('src', 'http://ajax.googleapis.com/ajax/libs/jquery/1.2.6/jquery.min.js');
  head.appendChild(script);
})();

alert("rew loaded");
setTimeout(function(){ jQuery('#outbox').text("Loaded REW"); }, 500);

