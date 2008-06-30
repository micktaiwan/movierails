// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


function loading(id, bol) {
  if(bol)
    $(id).addClassName('loading');
  else
    $(id).removeClassName('loading');
  }

