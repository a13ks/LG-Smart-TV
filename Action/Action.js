var Action = function() {};

Action.prototype = {
    
run: function(arguments) {
    arguments.completionFunction({ "currentUrl" : document.URL });
},
    
finalize: function(arguments) {
    var message = arguments["statusMessage"];
    
    if (message) {
        alert(message);
    }
}
    
};

var ExtensionPreprocessingJS = new Action;
