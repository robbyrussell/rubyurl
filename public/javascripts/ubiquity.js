CmdUtils.CreateCommand({
  name: "rubyurl",
  takes: {websiteUrl: noun_arb_text},
  
  homepage: "http://rubyurl.com",
  author: {name: "Alex Malinovich", homepage: "http://the-love-shack.net/"},
  license: "GPL",
  
  preview: function(previewBlock, websiteUrlText) {
    var previewTemplate = "Provides a RubyURL for <br/>" +       
                          "<b>${websiteUrl}</b><br /><br />";
    var previewData = {
      websiteUrl: websiteUrlText.text,
    };
      
    var previewHTML = CmdUtils.renderTemplate(previewTemplate,
                                                    previewData);
           
    previewBlock.innerHTML = previewHTML;
  },
  
  execute: function(websiteUrlText) {
    if(websiteUrlText.text.length < 1) {
      displayMessage("You must specify a URL to shorten!");
      return;
    }
    
    var updateUrl = "http://rubyurl.com/api/links.json";

    var updateParams = {
      website_url: websiteUrlText.text
    };   

    jQuery.ajax({
      type: "POST",
      url: updateUrl,
      data: updateParams,
      dataType: "json",
      error: function(errorData) {
        displayMessage("Error - nothing done! <br/>" + errorData);
      },
      success: function(successData) {
        CmdUtils.setSelection(successData.link.permalink);
      }
    });
  }
});
