// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

jQuery.ajaxSetup({
    'beforeSend': function (xhr) {
        xhr.setRequestHeader("Accept", "text/javascript")
    },
    'error':function(x,e){
        if(x.status==0){
            alert('You are offline!!\n Please Check Your Network.');
        }else if(x.status==404){
            alert('Requested URL not found.');
        }else if(x.status==500){
            alert('Internel Server Error.');
        }else if(e=='parsererror'){
            alert('Error.\nParsing JSON Request failed.');
        }else if(e=='timeout'){
            alert('Request Time out.');
        }else {
            alert('Unknow Error.\n'+x.responseText);
        }
    }
});

jQuery.fn.exists = function() {
    return jQuery(this).length>0;
}

function getWYSIWYGEditorInstance(text_area_id){
    alert('dd');
    document.write("<script src='nicEdit.js' type='text/javascript'></script>");
    return new nicEditor({
        iconsPath : '/images/nicEditorIcons.gif',
        buttonList : ['fontSize', 'bold', 'italic', 'underline', 'strikeThrough', 'subscript', 'superscript', 'ol', 'ul', 'indent', 'outdent', 'link', 'unlink', 'removeformat']
        }).panelInstance(text_area_id);
}