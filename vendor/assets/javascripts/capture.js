var page = require('webpage').create();
var system = require('system');

var url = (system.args.length > 1) ? system.args[1] : 'http://theodi.org'
var destination = (system.args.length > 2) ? system.args[2] : 'screenshot.png';
var width = (system.args.length > 3) ? system.args[3] : 1170;
var height = (system.args.length > 4) ? system.args[4] : 480;
var delay = (system.args.length > 5) ? system.args[5] : 3000;

page.viewportSize = { width: width, height: height };

page.open(url, function () {
  setTimeout(function() {
    var title = page.evaluate(function() {
        return document.body.style.background = "#FFFFFF";
    });
    page.render(destination);
    phantom.exit();
  }, delay);
});