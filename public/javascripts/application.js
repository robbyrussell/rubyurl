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