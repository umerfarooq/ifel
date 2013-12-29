var prev_project_percentage = 0;
var project_opened = null;
var section_opened = null;
var item_opened = null;
var docDirty = null;

var globalObject = null;


////////////////////////////////////////////////////////////////////////////////
//  Launch Pad, PROJECT SHOW
////////////////////////////////////////////////////////////////////////////////

function lpSetDateInput(sectionId) {
    //    $(":date").dateinput({
    $("#section_due_date_"+sectionId).dateinput({
        format: 'mmmm dd, yyyy',    // the format displayed for the user
        selectors: true,            // whether month/year dropdowns are shown
        offset: [10, 20],           // tweak the position of the calendar
        speed: 'fast',              // calendar reveal speed
        firstDay: 1                 // which day starts a week. 0 = sunday, 1 = monday etc..
    });
//    $(":date").dateinput({format: 'mmmm dd, yyyy', selectors: true, offset: [10, 20], speed: 'fast', firstDay: 1});
}

function lpToggleDateForm(link) {
    //alert($(this).parents());
    //if($("#edit_section_date_link").text() == "CANCEL"){
    if($(link).text() == "CANCEL"){
        //$("#span_section_due_date").hide();
        $(link).siblings(".ss_date_form").hide();
        $(link).siblings("#errorExplanation").hide();
        $(link).siblings("#errorExplanation").text(" ");
        $(link).text("EDIT");
    }
    else {
        $(link).siblings(".ss_date_form").show();
        $(link).siblings("#errorExplanation").show();
        $(link).text("CANCEL");
    }
}

function lpPostDueDateForm(form) {
    //    var pddp = "/sections/:id/update_due_date"
    $.post($(form).attr('action'), $(form).serialize(), function (response){
        //{
        //  _method: "put",
        //  authenticity_token: encodeURIComponent(AUTH_TOKEN),
        //  section_due_date_value: $(".date").data("dateinput").getValue().toString(),
        //  section_due_date_displayed: $(".date").val()
        //} , function (response){
        if(response.success){
            var rsid = response.section_id;
            //$(form).parent().siblings("#errorExplanation").text(" ");
            $("#ss_section_"+rsid+" #errorExplanation").text(" ");
            $("#ss_section_"+rsid+" .ss_date_form").hide();
            $("#ss_section_"+rsid+" .ss_date_link").text("EDIT");
            //$("#span_updated_section_date").text(response.month+" "+dd.getDate()+", "+dd.getFullYear());
            $("#ss_section_"+rsid+" .ss_date_text").text(response.due_date_ss);
            //$("#ss_section_"+rsid+" #section_due_date").data("dateinput").setValue(new Date(response.due_date_ps));
            $("#section_due_date_"+rsid).data("dateinput").setValue(new Date(response.due_date_ps));
            //$("#due_date_text_span_"+section_opened).text("Deadline: "+("00"+(dd.getMonth()+1)).substr(("00"+(dd.getMonth()+1)).length-2)+
            //  "/"+("00"+dd.getDate()).substr(("00"+dd.getDate()).length-2)+"/"+dd.getFullYear());
            $("#psdt_deadline_"+rsid).text("Deadline: "+response.due_date_ps);
        } else {
            $(".dedline #errorExplanation").text("Cannot Update Due Date");
        }
    });
}

// # TODO [11/13/10 1:36 AM] => OPTIMIZE_POST_CALL_FOR_EACH_OPEN_SECTION
function lpOpenSection(sid) {
    //section_opened = this.id.substring(16);
    //section_opened = this.id.split("_")[3];
    section_opened = sid;
    $(".ad1").hide();
    $("#starting_block_ad_"+sid).show();
    //sospp = "/projects/:id/set_opened_section"
    $.post(["", "projects", project_opened, "set_opened_section"].join("/"), {
        "section_id":sid
    });
    //$.get(this.href, function (response) {
    //  $("#div_section_overview").html(response);
    //$("#section_due_date").dateinput({
    //$("#edit_section_date_link").click(function (event) {
    //$("#section_submit").click(function (event) {
    //alert("a#item_link_"+item_displayed);
    //});
    $(".section").hide();
    $("#ss_section_"+sid).show();
    $("#calroot").remove();
    lpSetDateInput(sid);
    $("a.prcntgCurrent").addClass("prcntgLnk");
    $("a.prcntgCurrent").removeClass("prcntgCurrent");
    $("a#section_dt_link_"+sid).removeClass("prcntgLnk");
    $("a#section_pb_link_"+sid).removeClass("prcntgLnk");
    $("a#section_dt_link_"+sid).addClass("prcntgCurrent");
    $("a#section_pb_link_"+sid).addClass("prcntgCurrent");
}

function lpSetProgressbarView() {
    $("#sections_date_view_span").hide();
    $("#sections_progressbar_view_span").show();
}

function lpSetDuedateView() {
    $("#sections_progressbar_view_span").hide();
    $("#sections_date_view_span").show();
}

function lpSetProjectProgressBar(project_percentage) {
    if (project_percentage == 100 && prev_project_percentage < 100 && prev_project_percentage !=0){
        $.fn.colorbox({
            href:"/projects/congratulation", //  # TODO [11/3/10 2:22 AM] => CHECK_IT
            overlayClose: 'true'
        });
    }
    prev_project_percentage = project_percentage;
    $("#tracPrcntgDiv").css("width", project_percentage+"%");
    $("#tracPrcntgDiv #tracValueSpan").text(project_percentage + " %");
    $("#tracPrcntgDiv #tracValueSpan").removeClass();
    if(project_percentage == 0) {
        $("#tracPrcntgDiv #tracValueSpan").addClass("preTracValue");
    } else if(project_percentage < 10) {
        $("#tracPrcntgDiv #tracValueSpan").addClass("minTracValue");
    } else {
        $("#tracPrcntgDiv #tracValueSpan").addClass("tracValue");
    }
}

function lpSetSectionProgressBar(sid, item_count, item_completed_count) {
    var section_percentage = Math.round((item_completed_count/item_count)*100);
    var prcntgBarClass = "pcont";
    var prcntgBarTextClass = "pcontTxt";
    if(section_percentage < 10) {
        prcntgBarClass = "pcont";
        prcntgBarTextClass = "min1PcontTxt";
    } else if(section_percentage < 14) {
        prcntgBarClass = "pcont";
        prcntgBarTextClass = "min2PcontTxt";
    } else if(section_percentage < 100) {
        prcntgBarClass = "pcont";
        prcntgBarTextClass = "pcontTxt";
    } else {
        prcntgBarClass = "pComplete";
        prcntgBarTextClass = "pcontTxt";
    }
    //$("#percentage_bar_span_"+sid).removeClass();
    $("#psb_bar_"+sid).removeClass();
    $("#psb_bar_"+sid).addClass(prcntgBarClass);
    $("#psb_bar_"+sid).css("width",section_percentage+"%");
    //document.getElementById("percentage_bar_span_"+sid).style.width = section_percentage+"%";
    //$("#percentage_bar_text_span_"+sid).text(section_percentage+"%");
    $("#psbt_percent_"+sid).text(section_percentage+"%");
    $("#psbt_percent_"+sid).removeClass();
    $("#psbt_percent_"+sid).addClass(prcntgBarTextClass);
    //$("#percentage_item_count_text_span_"+sid).html("<strong>"+item_completed_count+"</strong> out of <strong>"+item_count+"</strong> items completed");
    $("#psbt_counts_"+sid).html("<strong>"+item_completed_count+"</strong> out of <strong>"+item_count+"</strong> items completed");
}

function lpSetSectionItemsStatus(section) {
    if(section["ended?"]){
        $("a#introduction_link_" + section.id).siblings("img").attr("src", "/images/icons/good.jpg");
        $("a#introduction_link_" + section.id).siblings("img").attr("alt", "COMPLETE");
    } else {
        $("a#introduction_link_" + section.id).siblings("img").attr("src", "/images/icons/cancel.jpg");
        $("a#introduction_link_" + section.id).siblings("img").attr("alt", "INCOMPLETE");
    }
    for(var i=0; i<section.items.length; i++) {
        if(section.items[i]["ended?"]){
            $("a#item_link_" + section.items[i].id).siblings("img").attr("src", "/images/icons/good.jpg");
            $("a#item_link_" + section.items[i].id).siblings("img").attr("alt", "COMPLETE");
        } else if(section.items[i]["edited?"]) {
            $("a#item_link_" + section.items[i].id).siblings("img").attr("src", "/images/icons/pending.jpg");
            $("a#item_link_" + section.items[i].id).siblings("img").attr("alt", "EDITED");
        } else {
            $("a#item_link_" + section.items[i].id).siblings("img").attr("src", "/images/icons/cancel.jpg");
            $("a#item_link_" + section.items[i].id).siblings("img").attr("alt", "INCOMPLETE");
        }
    }
}


function lpReady() {
    //    alert("Hi");
    //    lpSetDateInput();
    lpOpenSection(section_opened);
    lpSetDuedateView();
    $(".ss_date_link").click(function (event){
        lpToggleDateForm(this);
        event.preventDefault();
    });
//    $(".edit_section").submit(function (event){
    $(".ss_date_form form").submit(function (event){
        lpPostDueDateForm(this);
        event.preventDefault();
    });
    $("a.prcntgLnk").click(function (event) {
        lpOpenSection(this.id.split("_")[3]);
        event.preventDefault();
    });
    $("a.prcntgCurrent").click(function (event) {
        lpOpenSection(this.id.split("_")[3]);
        event.preventDefault();
    });
    $("a#show_due_dates_link").click(function (event) {
        lpSetDuedateView();
        event.preventDefault();
    });
    $("a#show_progress_link").click(function (event) {
        lpSetProgressbarView();
        event.preventDefault();
    });
}


function parseISO8601(dateStringInRange) {
    var isoExp = /^\s*(\d{4})-(\d\d)-(\d\d)\s*$/,
    date = new Date(NaN), month,
    parts = isoExp.exec(dateStringInRange);

    if(parts) {
        month = +parts[2];
        date.setFullYear(parts[1], month - 1, parts[3]);
        if(month != date.getMonth() + 1) {
            date.setTime(NaN);
        }
    }
    return date;
}

function lpColorBoxCallback() {
    if($("#item_user_answer").exists() && docDirty) {
        if(confirm("Do you want to save your answer?"))
            itemSaveAnswer(item_opened);
    }
    lpOpenSection(section_opened);
    //    $("a#section_dt_link_"+section_opened).click();
    //var psp = "/projects/:id/summary"
    //    $.get(project_summary_path, function (response) {
    //    var psp = ["", "projects", project_opened, "summary"].join("/");
    $.get(["", "projects", project_opened, "summary"].join("/"), function (response) {
        //        globalObject = response;
        if(response.success) {
            //alert(response.project.project.business_name);
            lpSetProjectProgressBar(response.project.project.percent);
            for(var i=0; i<response.project.project.sections.length; i++){
                var section = response.project.project.sections[i];
                lpSetSectionProgressBar(section.id, section.item_count, section.items_completed_count);
                lpSetSectionItemsStatus(section);
            }
        //response.project.project.sections.forEach(function (section){
        //  lpSetSectionProgressBar(section.id, section.item_count, section.items_completed_count);
        //});
        }
    //else alert("response.success => " + response.success)
    });
}

function lpMoveNextPrevious(next_previous_path) {
    $.get(next_previous_path, function (response){
        $("#liteBx-Cntainer").parent().html(response);
        $(".scrollingDiv").jScrollPane({
            showArrows:true
        });
        $.fn.colorbox.resize();
    });
    return false;
}


////////////////////////////////////////////////////////////////////////////////
//  CHECKLIST ITEM
////////////////////////////////////////////////////////////////////////////////


function itemIsComplete(item_id) {
    var is_comlete_val = ($("#item_is_complete:checkbox").is(':checked')) ? $("#item_is_complete:checkbox").val() : $("input[type=hidden][name=item[is_complete]]:first").val();
    //var mark_complete_item_path = "/items/:id/mark_complete";
    $.ajax({
        type: "POST", // PUT NOT SUPPORTED BY ALL BROWSERS SO POST WITH "_method" => "put"
        url: ["", "items", item_id, "mark_complete"].join("/"),
        data: {
            item_is_complete: is_comlete_val,
            _method: "put",
            authenticity_token: encodeURIComponent(AUTH_TOKEN)
        },
        dataType: "json",
        success: function (response) {
            $("#item_is_complete:checkbox").attr('checked', response.item_is_complete);
            $("#item_is_not_applicable:checkbox").attr('checked', response.item_is_not_applicable);
        }
    });
}

function itemIsNotApplicable(item_id) {
    var is_not_applicable_val = ($("#item_is_not_applicable:checkbox").is(':checked')) ? $("#item_is_not_applicable:checkbox").val() : $("input[type=hidden][name=item[is_not_applicable]]:first").val();
    //var mark_not_applicable_item_path = "/items/:id/mark_not_applicable";
    $.post(["", "items", item_id, "mark_not_applicable"].join("/"), {
        item_is_not_applicable: is_not_applicable_val,
        _method: "put",
        authenticity_token: encodeURIComponent(AUTH_TOKEN)
    }, function (response){
        $("#item_is_complete:checkbox").attr('checked', response.item_is_complete);
        $("#item_is_not_applicable:checkbox").attr('checked', response.item_is_not_applicable);
    },
    "json");
}

function itemSaveAnswer(item_id) {
    //var update_answer_item_path = ["", "items", item_opened, "update_answer"].join("/")       // PUT /items/:id/update_answer
    $.post(["", "items", item_id, "update_answer"].join("/"), {
        item_user_answer: $("#item_user_answer").val(),
        _method: "put",
        authenticity_token: encodeURIComponent(AUTH_TOKEN)
    }, function (response){
        //$("#item_user_answer").val(response.item_user_answer);
    },
    "json");
}

function itemSetAjaxUpload(item_id) {
    //    var add_file_item_path = "/items/:id/add_file";
    new AjaxUpload('upload_file_link', {
        //action: "<%= add_file_item_path(@item) %>",
        action: ["", "items", item_id, "add_file"].join("/"),
        data : {
            '_method'               : "post",
            'authenticity_token'    : $("input[name=authenticity_token]").attr("value")
        },
        autoSubmit: true,             // Submit file after selection
        responseType: "json",         // Useful when you are using JSON data as a response, set to "json" in that case.
        //        hoverClass: 'ajaxUploadHover',
        onChange: function (f, e) { }, // Fired after the file is selected
        onSubmit: function (f, e) {    // Fired before the file is uploaded
            this.disable();
        },
        onComplete: function (file, response) {  // Fired when file upload is completed  // WARNING! DO NOT USE "FALSE" STRING AS A RESPONSE!
            if(response.success){
                var doc = response.document.document;
                $("#fileNameSpan").html("<a title='"+doc.data_file_name+"' target='_blank' href='/documents/"+doc.id+"/download'>"+doc.data_file_name+"</a>");
            } else {
                $("#fileNameSpan").html("<b>"+response.message+"</b>");
            //$("#fileNameSpan").html("<b>"+response.errors[0][0]+" "+response.errors[0][1]+"</b>");
            }
            this.enable();
        }
    });
}

function itemTooltip() {
    var is_hidden = ($(this).parent().nextAll(".right_tooltip:first").css("display") == "none");
    $(".right_tooltip").hide();
    $(".right_sub_link").text("show summary");
    if(is_hidden){
        $(this).parent().nextAll(".right_tooltip:first").show();
        $(this).text("hide summary");
    }
    $(".scrollingDiv").jScrollPane({
        showArrows:true
    });
    return false;
}


function itemReady(item_id, previousPath, nextPath) {
    //$(".scrollingDiv").jScrollPane({showArrows:true}); // MOVED TO COLOR_BOX_CALLBACK ON_COMPLETE DUE TO 0 HEIGHT
    itemSetAjaxUpload(item_id);
    $("#item_is_complete").change(function () {
        itemIsComplete(item_id);
    });
    $("#item_is_not_applicable").change(function () {
        itemIsNotApplicable(item_id);
    });
    $("#item_user_answer").change(function () {
        docDirty = true;
    });
    $("#previous_item_link").click(function () {
        if(docDirty){
            itemSaveAnswer(item_id);
        }
        return lpMoveNextPrevious(previousPath);
    });
    $("#next_item_link").click(function  () {
        if(docDirty){
            itemSaveAnswer(item_id);
        }
        return lpMoveNextPrevious(nextPath);
    });
    $(".right_sub_link").click(function () {
        return itemTooltip();
    });
    $(".right_link_div").hover(function () {
        $(this).children(".right_sub_link").show();
    }, function () {
        $(this).children(".right_sub_link").hide();
    });
}


function sectionDoNotShowIntro(section_id) {
    var do_not_show_intro_val = ($("#section_do_not_show_intro:checkbox").is(':checked')) ? $("#section_do_not_show_intro:checkbox").val() : $("input[type=hidden][name=section[do_not_show_intro]]:first").val();
    //var mark_show_intro_section_path = "/sections/:id/mark_show_intro(.:format)"
    $.post(["", "sections", section_id, "mark_show_intro"].join("/"), {
        _method: "put",
        authenticity_token: encodeURIComponent(AUTH_TOKEN),
        section_do_not_show_intro: do_not_show_intro_val
    }, function(response){
        $("#section_do_not_show_intro:checkbox").attr('checked', response.section_do_not_show_intro);
    //$("#section_do_not_show_intro").attr('checked', (response === 'true'));
    });
}

function sectionReady(section_id, previousPath, nextPath) {
    $("#previous_item_link").click(function (){
        return lpMoveNextPrevious(previousPath);
    });
    $("#next_item_link").click(function (){
        return lpMoveNextPrevious(nextPath);
    });
    $("#section_do_not_show_intro").change(function (){
        sectionDoNotShowIntro(section_id);
    //$.post($(this.form).attr('action'), $(this.form).serialize(), function(response){
    });
}



////////////////////////////////////////////////////////////////////////////////
//  MY FILES
////////////////////////////////////////////////////////////////////////////////

// # TODO [11/9/10 6:00 PM] => REFACTOR_UPLOAD_FILE_SECURITY_AND_COSMETICS
function fileReady() {
    var nau = new AjaxUpload('upload_file_link', {
        //action: $("form.edit_item").attr("action"),
        //action: "<%= documents_path %>",
        action: "/documents",
        name: 'document[data]',
        data: {
            '_method'                     : "post",
            //document: {
            //  'documentable_id'           : "",
            //  'description'               : "ABC"
            //},
            'document[documentable_id]'    : "",
            'document[description]'        : "",
            //'ajax_upload'               : "ajax_upload",
            'authenticity_token'          : $("input[name=authenticity_token]").attr("value")
        },
        // Submit file after selection
        autoSubmit: false,
        // Useful when you are using JSON data as a response, set to "json" in that case.
        responseType: "json",
        // Fired after the file is selected
        onload: function (file, extension) {
            $.fn.colorbox.resize();
        },
        // Fired after the file is selected
        onChange: function (file, extension) {
            //alert("onChange");
            //this.disable();
            $("#selected_file_label").html(file+"&nbsp;&nbsp;&nbsp;");
            $("#upload_file_link").html("(replace)");
            $.fn.colorbox.resize();
        },
        // Fired before the file is uploaded
        onSubmit: function (file, extension) {
            //alert("onSubmit");
            //alert(this._settings.data._method);
            //this._settings.data.document_documentable_id = $("#document_documentable_id").val();
            //this._settings.data.document_description = $("#document_description").val();
            this._settings.data["document[documentable_id]"] = $("#document_documentable_id").val();
            this._settings.data["document[description]"] = $("#document_description").val();
        },
        // Fired when file upload is completed
        // WARNING! DO NOT USE "FALSE" STRING AS A RESPONSE!
        onComplete: function (file, response) {
            //globalObject = response;
            //alert("onComplete");
            //alert(response.success);
            //var response_json = jQuery.parseJSON(response);
            //alert(response_json.status);
            //if(response_json.status == "not-saved"){
            if(response.success){
                //$.fn.colorbox.close();
                if(window.location == response.redirect_url)
                    window.location.reload(true);
                else
                    window.location(response.redirect_url);
            } else {
                $("#errorExplanation ul").empty();
                $("#errorExplanation").show();
                $("#selected_file_label").html("");
                $("#upload_file_link").html("Select File");
                //response_json.errors.forEach(function (value){
                //for(var i=0 ; i<response_json.errors.length ; i++){
                //  var value = response_json.errors[i];
                for(var i=0 ; i<response.errors.length ; i++){
                    var value = response.errors[i];
                    if(value[0] == "documentable_id")
                        value[0] = "Document Category";
                    if(value[0] == "data_content_type") {
                        value[0] = "Document";
                        value[1] = "must be of office type";
                    }
                    $('<li></li>').appendTo('#errorExplanation ul').html(value[0]+" "+value[1]);
                }//);
                $.fn.colorbox.resize();
            }
            //$('<li></li>').appendTo('#errorExplanation ul').html(response_json.errors[0][0]+" "+response_json.errors[0][1]);
            //$(".upldDocDv").parent().html(response);
            this.enable();
        }
    });
    $("#new_document").submit(function (event){
        event.preventDefault();
        //alert("new_document_submit");
        return fileSafeUpload(nau);
    });
}

function fileSafeUpload(au){
    //nau.complete();
    //alert("Submit_form");
    //alert(nau._settings.data.authenticity_token);
    //alert(nau.authenticity_token);
    $("#errorExplanation ul").empty();
    var do_submit = true;
    if($("#document_documentable_id").val().length == 0){
        $('<li id="cne"></li>').appendTo('#errorExplanation ul').html("Document Category must be selected");
        do_submit = false;
    }
    //    if((nau._input == null) || (nau._input.value.length == 0)){
    if((au._input == null) || (au._input.value.length == 0)){
        $('<li id="dne"></li>').appendTo('#errorExplanation ul').html("Document must be selected");
        do_submit = false;
    }
    if(do_submit){
        //        nau.submit();
        au.submit();
    } else {
        $("#errorExplanation").show();
        $.fn.colorbox.resize();
    }
    //if(nau._input && nau._input.value.length > 0) {
    //  doc_no_error = true;
    //  //$("#errorExplanation ul").empty();
    //  nau.submit();
    //} else if(doc_no_error) {
    //  $("#selected_file_label").html("");
    //  $("#upload_file_link").html("Select File");
    //  $("#errorExplanation ul").empty();
    //  $("#errorExplanation").show();
    //  $('<li id="dne"></li>').appendTo('#errorExplanation ul').html("Document must be selected");
    //  $.fn.colorbox.resize();
    //  doc_no_error = false;
    //}
    return false;
}



////////////////////////////////////////////////////////////////////////////////
//  COMMUNITY
////////////////////////////////////////////////////////////////////////////////

function msgShowResponseForm(isPrivate, responseHeading){
    $("#response_heading").html(responseHeading);
    $("#comment_is_private").val(isPrivate);
    $("#comment_body").val("");
    $("#error_messages_td").text("");
    //$("#respond_buttons_tr").hide();
    //$("#respond_message_div").show();
    //$("#respond_buttons_span").hide("fast", function (){
    //  $("#respond_message_div").show("fast", function (){});
    //});
    $("#respond_buttons_span").hide();
    $("#respond_message_div").show();
    //$("#reply_privately_message_div").show();
    //$("#respond_message_div").slideToggle("medium", function (){
    //  if ($("#respond_button").attr("value") === "Discard")
    //    $("#respond_button").attr("value", "Respond");
    //  else $("#respond_button").attr("value", "Discard");
    //});
    return false;
}

function msgCancelReply(){
    //$("#respond_message_div").hide();
    //$("#respond_buttons_tr").show();
    //$("#respond_message_div").hide("fast", function (){
    //  $("#respond_buttons_span").show("fast", function (){});
    //});
    $("#respond_message_div").hide();
    $("#respond_buttons_span").show();

    //$("#respond_message_div").slideToggle("medium", function (){
    //  if ($("#respond_button").attr("value") === "Discard")
    //    $("#respond_button").attr("value", "Respond");
    //  else $("#respond_button").attr("value", "Discard");
    //});
    return false;
}

function msgValidateComment(){
    var data = $('#new_comment').find('.nicEdit-main').text();
    if($.trim(data) == "") {
        $("#error_messages_td").text("Response can't be blank");
        return false;
    } else {  
        return true;
    }
}

function msgCommentsReady(userScreenName){
    $("#respond_button").click(function (event){
        event.preventDefault();
        return msgShowResponseForm(false, "Your answer will be viewable to all WickedStart users");
    });

    $("#reply_privately_link").click(function (event){
        event.preventDefault();
        return msgShowResponseForm(true, "Your answer will only be viewable to " + userScreenName);
    });

    $("#cancel_reply_link").click(function (event){
        event.preventDefault();
        return msgCancelReply();
    });

    $("#new_comment").submit(function (){
        return msgValidateComment();
    });
}



////////////////////////////////////////////////////////////////////////////////
//  GLOBAL FUNCTIONS
////////////////////////////////////////////////////////////////////////////////

function setError(error) {
    return false;
}


