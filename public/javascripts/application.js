// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


function loading(id, bol) {
  if(bol)
    $(id).addClassName('loading');
  else
    $(id).removeClassName('loading');
  }

function include_mine() {
  include = $('include_mine').checked*1;
  ajax_feedback();
  new Ajax.Updater("mcontent","/movie/include_mine/?i="+include,{asynchronous:true, evalScripts:true});
  }
  
function select_page(p) {
  //alert(p);
  $('page_last').removeClassName('selected')
  $('page_best').removeClassName('selected')
  $('page_most_watched').removeClassName('selected')
  $('page_sugg').removeClassName('selected')
  $('page_'+p).addClassName('selected')
  
  ajax_feedback();  
  }

function ajax_feedback() {  
  $('mcontent').update('Chargement...')
  }
  
