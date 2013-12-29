$(document).ready(function(){
    makeContentEditable();
    $("#btnHaveQuestion").click(function(){
        $('#sentConfirmPanel').fadeOut('slow');
        if ($("#haveQuestPanel").is(':hidden'))
            $("#haveQuestPanel").fadeIn('slow', function(){
                activateDefaultText();
            });
        else{
            $("#haveQuestPanel").fadeOut('slow');
        }
        return false;
    });
    

    $('#haveQuestPanel').click(function(e) {
        e.stopPropagation();
    });
    $(document).click(function() {
        resetAllFields();
        $('#haveQuestPanel').fadeOut('slow');
        $('#sentConfirmPanel').fadeOut('slow');
    });

    $("form#have_question_form").submit(function() {
        var name = $('#question_name').attr('value');
        var email = $('#question_email').attr('value');
        var question = $('#question_statement').attr('value');
        var token = $("input[name=authenticity_token]").attr("value");
        if(jQuery.trim(name).length > 0 && jQuery.trim(question).length > 0 && jQuery.trim(email).length > 0 ){
            var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
            if(emailReg.test(email)) {
                $.ajax({
                    type: "POST",
                    url: "/common_questions/have_a_question",
                    data: {
                        "name":name,
                        "question":question,
                        "email":email,
                        "authenticity_token":token
                    },
                    success: function(data){
                        if(data.success){
                            resetAllFields();
                            $('#haveQuestPanel').hide();
                            $('#sentConfirmPanel').show();
                        }else{
                            $('#notice').text("Request can't be send, due to system problem");
                        }
                    },
                    dataType:'json'
                });

            }else {
                $('#notice').text("Please enter a valid email address");
            }
        } else {
            $('#notice').text("Please complete all fields");
        }
        return false;
    });
});
function makeContentEditable(){
    $("a#message_edit_link").click(function (event){
        if($("a#message_edit_link").text() == "EDIT") {
            $("a#message_edit_link").text("CANCEL");
            $("div#message_show").hide();
            $("div#message_edit").show();
        } else {
            $("a#message_edit_link").text("EDIT");
            $("div#message_show").show();
            $("div#message_edit").hide();
        }
        event.preventDefault();
    });
}
function activateDefaultText(){
    $('#question_name').hide();
    $('#question_name').next().show();
    $('#question_statement').hide();
    $('#question_statement').next().show();
    $('#question_email').hide();
    $('#question_email').next().show();
}
function resetAllFields(){
    $('#question_name').val('');
    $('#question_statement').val('');
    $('#question_email').val('');
    $('#notice').text("");
}
function toggleSlide(panelId, noOfPanels){
    $("#panel_"+panelId).slideDown(1000);
    slideUpVisiblePanel(panelId, noOfPanels);
    $(this).toggleClass("active");
    return false;
}
function slideUpVisiblePanel(currentPanelId, noOfPanels){
    for(i=0; i<noOfPanels; i++){
        if(i != currentPanelId){
            if($("#panel_"+i).is(':visible')){
                $("#panel_"+i).slideUp(1000, function(){
                    $('#commonQuestionTop').load('/common_questions/refresh_all_sliders/'+currentPanelId);
                });
            }
        }
    }
}
function closeAllOtherPanels(currentPanelId, noOfPanels, closeAllSliders){
    for(i=0; i<noOfPanels; i++){
        if(closeAllSliders == 'true'){
            $("#panel_"+i).hide();
        }else{
            if(i != currentPanelId){
                $("#panel_"+i).hide();
            }
        }
    }
}
function slideAnswers(question_id, index, totalSliders){
    $("#ans_slider_"+question_id+'_'+index).show();
    if($("#nmbr_slide_"+question_id+'_'+index).hasClass('off')){
        $("#nmbr_slide_"+question_id+'_'+index).removeClass('off').addClass('selected');
    }
    closeAllOtherAnswerSliders(question_id, index, totalSliders);
    return false;
}
function closeAllOtherAnswerSliders(question_id, index, totalSliders){
    for(i=0; i<totalSliders; i++){
        if(i != index){
            $("#ans_slider_"+question_id+'_'+i).hide();
            if($("#nmbr_slide_"+question_id+'_'+i).hasClass('selected')){
                $("#nmbr_slide_"+question_id+'_'+i).removeClass('selected').addClass('off');
            }
        }
    }
}
function getQuestions(panel_no, question_id){
    $.get('/common_questions/'+question_id+'/detail', function(data) {
        $('#panel_'+panel_no).html(data);
    });
}

