$(document).ready(function() {
    //setBlurrableTextInField();
});
function setBlurrableTextInField(){
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
}

function showProgressBar(){
    $.blockUI({
        message: $('<img src="/images/loading.gif" class="dispInline vertAlign" />'),
        css: {
            border: 'none',
            padding: '5px',
            backgroundColor: '#b6fe93',
            '-webkit-border-radius': '10px',
            '-moz-border-radius': '10px',
            opacity: .5,
            //color: '#1B75BB',
            color: '#b6fe93',
            textAlign: 'center',
            cursor: 'wait'
        },
        centerX: true,
        centerY: true
    });
}

function hideProgressBar(){
    $.unblockUI();
}