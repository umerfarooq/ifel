var quizCboxHeight;

////////////////////////////////////////////////////////////////////////////////
//  Top Login Div on All Public Pages
////////////////////////////////////////////////////////////////////////////////

function dummyLoginFocus () {
    document.getElementById('dummy_login').style.display = 'none';
    document.getElementById('dummy_login').blur();
    document.getElementById('user_session_login').value = "";
    document.getElementById('user_session_login').style.display = 'block';
    document.getElementById('user_session_login').focus();
}

function dummyPasswordFocus () {
    document.getElementById('dummy_password').style.display = 'none';
    document.getElementById('dummy_password').blur();
    document.getElementById('user_session_password').value = "";
    document.getElementById('user_session_password').style.display = 'block';
    document.getElementById('user_session_password').focus();
}

function userSessionLoginBlur() {
    //(document.getElementById('user_session_login').getAttribute('value').length == 0)
    //(document.login_form.user_session_login.value == null || document.login_form.user_session_login.value == "")
    if (document.getElementById('user_session_login').value == null ||
        document.getElementById('user_session_login').value == "") {
        document.getElementById('user_session_login').style.display = 'none';
        //document.getElementById('user_session_login').blur();
        document.getElementById('dummy_login').style.display = 'block';
    }
}

function userSessionPasswordBlur() {
    if (document.getElementById('user_session_password').value == null ||
        document.getElementById('user_session_password').value == "") {
        document.getElementById('user_session_password').style.display = 'none';
        //document.getElementById('user_session_password').blur();
        document.getElementById('dummy_password').style.display = 'block';
    }
}


////////////////////////////////////////////////////////////////////////////////
//  Public Home Page
////////////////////////////////////////////////////////////////////////////////

function ownerTextLinkClick () {
    $("#ownerTextMore").slideToggle('fast', function (){
        if($("a#ownerTextLink").text() == "<< Less")
            $("a#ownerTextLink").html("More >>");
        else $("a#ownerTextLink").html("<< Less");
    });
}


function quizFormSubmit () {
    //alert(quizCboxHeight);
    var radio_groups = {}
    $(":radio").each(function(){
        radio_groups[this.name] = true;
    })
    var allCkecked = true;
    var emailRegex = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i;
    for(var group in radio_groups){
        if(undefined === $("input[name='"+group+"']:checked").val()) {
            allCkecked = false;
            break;
        }
    }
    var errorFound = true;
    if(allCkecked == false)
        $("#quiz_error_box #error_text").html("Please answer all the questions before you submit.");
    else if($("#quiz_email").val().length == 0)
        $("#quiz_error_box #error_text").html("Please enter your email address before you submit.");
    else if(emailRegex.test($("#quiz_email").val()) == false)
        $("#quiz_error_box #error_text").html("Your email address appears to be invalid please re-enter.");
    else
        errorFound = false;
    if(errorFound) {
        $("#quiz_error_box").show();
        $.fn.colorbox.resize({
            innerHeight:getQuizColorboxHeight()
        });
    }
    else {
        $.post($(this).attr('action'), $(this).serialize(), function(response){
            $("#liteBx-wrapper").parent().html(response);
            $.fn.colorbox.resize();
        });
    }
}

function setQuizColorboxHeight () {
    quizCboxHeight = $("#cboxLoadedContent").height();
}

function getQuizColorboxHeight () {
    var errorBoxHeight = 39;  // 39px = 34px(imageHeight) + 5px(2*2px paddable space + 1px)
    if($("#quiz_error_box").css("display") == "none")
        return quizCboxHeight;
    else return quizCboxHeight + errorBoxHeight;
}

function closeAlertBoxQuiz () {
    $("#quiz_error_box").hide();
    $.fn.colorbox.resize({ innerHeight:getQuizColorboxHeight() });
    return false;
}



