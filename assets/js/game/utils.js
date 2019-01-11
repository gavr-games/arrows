class Utils {
  decimalColorToHTMLcolor(number) {
    var intnumber = number - 0;
    var template = "#000000";
    var HTMLcolor = intnumber.toString(16);
    HTMLcolor = template.substring(0,7 - HTMLcolor.length) + HTMLcolor;
    return HTMLcolor;
  } 
}

const utils = new Utils()

export default utils