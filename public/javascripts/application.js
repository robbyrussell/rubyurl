// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//
// copied from: http://www.tek-tips.com/viewthread.cfm?qid=1465395&page=5
// TODO: reference original author...
//
function copy(rubyurl) {
    var flashcopier = 'flashcopier';
    if(!document.getElementById(flashcopier)) {
      var divholder = document.createElement('div');
      divholder.id = flashcopier;
      document.body.appendChild(divholder);
    }
    document.getElementById(flashcopier).innerHTML = '';
    var divinfo = '<embed src="/_clipboard.swf" FlashVars="clipboard='+encodeURIComponent(rubyurl)+'" width="0" height="0" type="application/x-shockwave-flash"></embed>';
    document.getElementById(flashcopier).innerHTML = divinfo;
		$('x_copy_button').hide();
		$('x_copied').show();
		
}

Event.observe(window, 'load', function() {
  // Watch for user's click on "Auto Copy" checkbox
  if ($('auto_copy'))
    Event.observe('auto_copy', 'change', function(event) { document.cookie = 'auto_copy='+($F('auto_copy') ? 1 : 0); });

  // Perform auto-copy if prudent
  if ((link = $$('#url.arrow a')).length && document.cookie.match(/auto_copy=1/))
    copy(link[0].href);
});