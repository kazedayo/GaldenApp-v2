
var colorCodeStartRegex = new RegExp("\\[#([a-fA-F0-9]{6})\\]", "gi");
var colorCodeEndRegex = new RegExp("\\[\\/#[a-fA-F0-9]{6}\\]", "gi");

var parseBBcodeColor = function (bbcode) {
    var afterStart = bbcode.replace(colorCodeStartRegex,
                                    function (match, colorCode, text, offset) {
                                    return '[color=' + colorCode + ']';
                                    }
                                    );
    
    var afterEnd = afterStart.replace(colorCodeEndRegex,
                                      function (match, colorCode, text, offset) {
                                      return '[/color]';
                                      }
                                      );
    return afterEnd;
};

function convertBBCodeToHTML(source) {
    source = parseBBcodeColor(source)
    var htmlResult = XBBCODE.process({text: source,removeMisalignedTags: true,addInLineBreaks: true});
    
    //consoleLog(htmlResult.html);
    
    handleConvertedBBCode(htmlResult.html);
}
