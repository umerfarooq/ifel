$(document).ready(function (){
    var text_areas = $(".htmlEditor");
    for(i=0; i<text_areas.length; i++){
        text_area_id = text_areas[i].id;
        new nicEditor({
            iconsPath : '/images/nicEditorIcons.gif',
            buttonList : ['fontSize', 'bold', 'italic', 'underline', 'strikeThrough', 'subscript', 'superscript', 'ol', 'ul', 'indent', 'outdent', 'link', 'unlink', 'removeformat']
        }).panelInstance(text_area_id);
    }
    
    $(".defaultText").after(function (){
        var field = "<input type='text' ";
        field = field + "class='" + $(this).attr("class") + "' ";
        if($(this).attr("title"))
            field = field + "value='" + $(this).attr("title") + "' ";
        else
            field = field + "value='Enter Text' ";
        if($(this).attr("size"))
            field = field + "size='" + $(this).attr("size") + "' ";
        field = $(field + "/>").removeClass("defaultText").addClass("defaultTextActive");
        return field;
    });
    $(".defaultText").next().focus(function(){
        $(this).hide();
        $(this).prev().show();
        $(this).prev().focus();
        $(this).prev().val("");
    });
    $(".defaultText").blur(function(){
        if($(this).val() == "") {
            $(this).hide();
            $(this).next().show();
        } else {
            $(this).next().hide();
            $(this).show();
        }
    });
    $(".defaultText").blur();
});

//Use to Calculate the Characters limit for HTML based Text Areas
function limitChars(textid, limit, infodiv)
  {
    var text = $('#'+textid).html();
    var textlength = text.length;
    var limit = limit+4;
    if(textlength > limit)
    {
      $('#'+textid).html(text.substr(0,(limit)));
      return false;
    }
    else
    {
      $('#' + infodiv).html('You have <b>'+ (limit - textlength) +'</b> characters left.');
      return true;
    }
  }

  // Use to calculate the Character Limit for Simple Text Area Objects
  function limitCharsForSimpleTextArea(textid, limit, infodiv)
  {
   var text = $('#'+textid).val();
    var textlength = text.length;
    if(textlength > limit)
    {
      $('#'+textid).val(text.substr(0,(limit)));
      return false;
    }
    else
    {
      $('#' + infodiv).html('You have <b>'+ (limit - textlength) +'</b> characters left.');
      return true;
    }
  }

