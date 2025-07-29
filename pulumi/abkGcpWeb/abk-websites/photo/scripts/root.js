//-------------------------------------------------------------------
// general variables
//-------------------------------------------------------------------
var title_str = top.document.title;

//-------------------------------------------------------------------
// start java scripts
//-------------------------------------------------------------------
function start_js(scripts)
{
  if (scripts & 0x01)
  {
    scroll_title();
  }
}


//-------------------------------------------------------------------
// scroll title
//-------------------------------------------------------------------
function scroll_title()
{
 title_str = title_str.substring(1, title_str.length) + title_str.substring(0, 1);
 document.title = title_str;
 setTimeout("scroll_title()", 300);
}

