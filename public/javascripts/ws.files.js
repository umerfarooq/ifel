$(document).ready(function() {
    makeNavigationPanelStatic();
    ajaxifyActionLinks();
    prepareUploader();
});

function toggleFilePanels(fileId){
    $("#click_me_"+fileId).toggleClass("activeArrow");
    $("#detail_file_panel_"+fileId).slideToggle('fast');
    $("#short_text_"+fileId).slideToggle('fast');
    $("#long_text_"+fileId).slideToggle('fast');
}

function slideFileEditablePanel(fileId){
    $("#click_me_edit_"+fileId).addClass("inactiveArrow");
    $("#click_me_"+fileId).toggleClass("activeArrow");
    $("#plain_document_panel_"+fileId).slideUp('fast', function(){
        $("#plain_panel_row_"+fileId).hide();
        $("#editable_document_panel_"+fileId).slideDown('slow');
        $("#detail_file_panel_"+fileId).show();
    });
}

function slideFilePlainPanel(fileId){
    $("#click_me_edit_"+fileId).addClass("inactiveArrow");
    $("#click_me_"+fileId).addClass("activeArrow");
    $("#editable_document_panel_"+fileId).slideUp('fast', function(){
        $("#plain_panel_row_"+fileId).show();
        $("#plain_document_panel_"+fileId).slideDown('slow');
    });
}
//function to mack side category navigation static when page is scrolled beyond a certain Y location.
function makeNavigationPanelStatic(){
    // Check whether browser is IE6
    var msie6 = $.browser == 'msie' && $.browser.version < 7;
    // Only run the following code if browser
    // is not IE6. On IE6, the box will always
    // scroll.
    if (!msie6) {
        // Set the 'top' variable. The following
        // code calculates the initial position of
        // the box.
        var top = $('#level3nav').offset().top;
        // Next, we use jQuery's scroll function
        // to monitor the page as we scroll through.
        $(window).scroll(function (event) {
            // In the following line, we set 'y' to
            // be the amount of pixels scrolled
            // from the top.
            var y = $(this).scrollTop();
            // Have you scrolled beyond the
            // box? If so, we need to set the box
            // to fixed.
            if (y >= top) {
                // Set the box to the 'fixed' class.
                $('#level3nav').addClass('fixed');
            } else {
                // Remove the 'fixed' class
                $('#level3nav').removeClass('fixed');
            }
        });
    }
}

function showHelptip(tipContainer){
    $('#'+tipContainer).fadeIn("fast");
}

function hideHelptip(tipContainer){
    $('#'+tipContainer).fadeOut("slow");
}

function ajaxifyActionLinks(){
    jQuery('a.delete').livequery('click', function() {
        if(confirm("Are you sure you want to delete this file?")){
            var link = jQuery(this);
            var doc_id = link.attr('document_id');
            showProgressBar();
            //setLoadingBar($("#action_error_msg_"+doc_id), "actionLoading");
            //setLoadingBar($("#action_error_editable_msg_"+doc_id), "actionLoading");
            $.post("/documents/"+doc_id, "_method=delete", function(data) {
                if (link.attr('ajaxtarget'))
                    jQuery(link.attr('ajaxtarget')).html(data);
                hideProgressBar();
            });
            return false;
        }
        
    }).attr("rel", "nofollow");
    jQuery('a.delete').removeAttr('onclick');
}

function prepareUploader(){
    $('.uploadFileBtn').each(function(a,b){
        var sectionId = $(b).attr("section_id");
        var type = 'section';
        var container = "upload_file_btn_"+sectionId;
        var func = "upload_document_to_section";
        var errorContainer = "upload_error_msg_"+sectionId;
        var method = "post";
        var token = "";
        initializeUploader(sectionId,type, container, func , errorContainer, method, token, "actionLoading dispInline");
    });

    $('.replace_document_plain').each(function(a,b){
        var documentId = $(b).attr("document_id");
        var type = 'document';
        var container = "replace_document_plain_"+documentId;
        var func = "replace_document";
        var errorContainer = "action_error_msg_"+documentId;
        var method = "put";
        var token = $("input[name=authenticity_token]").attr("value");
        initializeUploader(documentId,type, container, func , errorContainer, method, token, "actionLoading");
    });

    $('.replace_document_editable').each(function(a,b){
        var documentId = $(b).attr("document_id");
        var type = 'document';
        var container = "replace_document_editable_"+documentId;
        var func = "replace_document";
        var errorContainer = "action_error_editable_msg_"+documentId;
        var method = "put";
        var token = $("input[name=authenticity_token]").attr("value");
        initializeUploader(documentId,type, container, func , errorContainer, method, token, "actionLoading");
    });

//    $('.upload_document_plain').each(function(a,b){
//        var documentId = $(b).attr("document_id");
//        var container = "upload_document_plain_"+documentId;
//        var func = "replace_document";
//        var errorContainer = "action_error_msg_"+documentId;
//        var method = "put";
//        var token = $("input[name=authenticity_token]").attr("value");
//        initializeUploader(documentId, container, func , errorContainer, method, token, "actionLoading");
//    });

//    $('.upload_document_editable').each(function(a,b){
//        var documentId = $(b).attr("document_id");
//        var container = "upload_document_editable_"+documentId;
//        var func = "replace_document";
//        var errorContainer = "action_error_editable_msg_"+documentId;
//        var method = "put";
//        var token = $("input[name=authenticity_token]").attr("value");
//        initializeUploader(documentId, container, func , errorContainer, method, token, "actionLoading");
//    });
}

function initializeUploader(id, type, container, func, errorCont, method, token, loadingStyle){
    new AjaxUpload(container, {
        action: ["", "documents", id, func].join("/"),
        data : {
            '_method'               : method,
            "authenticity_token"    : token
        },
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'doc', 'xls', 'xlsx', 'pdf'],
        autoSubmit: false,             // Submit file after selection
        responseType: "json",         // Useful when you are using JSON data as a response, set to "json" in that case.
        onChange: function (f, e) {
            var ajaxUp = $(this);
            if (!(/^(jpg|png|jpeg|gif|doc|docx|xls|xlsx|pdf|ppt|csv|eps|flv|mov|mp4|wma|zip|rar|txt|rtf|wps|wpd|dat|pps|ppt|pptx|xml|mp3|bmp|tif|psd|mpp|vsd|vss|vst|vdx|vtx|vsx)$/i.test(e))){
                $("#"+errorCont).html("Invalid file type");
                return false;
            }else{
                if(type == 'section'){
                    $.post('/documents/is_file_exist',{
                        'file':f,
                        'id':id
                    },function(data){
                        if(data.file_exists){
                            //                        if(type == 'document' && id == parseInt(data.document_id)){
                            //                            ajaxUp.submit();
                            //                        }else
                            //                        {
                            if(confirm("A file with the same name already exists, do you want to replace it?")){
                                // Delete an existing file here
                                $.post("/documents/"+data.document_id, "_method=delete", function(){
                                    ajaxUp.submit();
                                });
                            }else{
                                return false;
                            }
                        //                        }

                        }else{ajaxUp.submit();}
                    }
                    ,'json');
            }else{ajaxUp.submit();}
            
        }
    }, // Fired after the file is selected
    onSubmit: function (f, e) {    // Fired before the file is uploaded
        showProgressBar();
        //setLoadingBar($("#"+errorCont), loadingStyle);
    },
    onComplete: function (file, response) {  // Fired when file upload is completed  // WARNING! DO NOT USE "FALSE" STRING AS A RESPONSE!
        if(response.success){
            $('#document_panel').load('/documents/list_documents',function(){
                hideProgressBar();
                slideFileEditablePanel(response.document_id);
            });
        } else {
            hideProgressBar();
            $("#"+errorCont).html(response.message);
        }
        this.enable();
    }
    });
}

function updateDocument(documentId){
    showProgressBar();
    //setLoadingBar($("#save_contents_loading_"+documentId));
    var url = '/documents/'+documentId+'/update_contents/';
    var documentName = $('#document_name_'+documentId).val();
    var description = $('#document_description_'+documentId).val();
    var statusOptionProg = $('#status_inprogress_'+documentId);
    var statusOptionComp = $('#status_complete_'+documentId);
    var state;
    if(statusOptionProg.is(':checked')){
        state = statusOptionProg.val();
    }else{
        state = statusOptionComp.val();
    }
    var tags = $('#tags_'+documentId).val();
    $.post(url,{
        'name':documentName,
        'description':description,
        'state':state,
        'tags':tags
    }, function(data){
        if(data.success){
            $('#document_panel').load('/documents/list_documents', function(){
                hideProgressBar();
                $("ul.resourcesLinkListing a").removeClass("current");
                toggleFilePanels(documentId);
            });
            
        }else{
            hideProgressBar();
            $("save_contents_loading_"+documentId).html('<b>'+data.message+'</b>');
        }
        
    }, 'json');
}

function loadSectionContents(sectionId){
    showProgressBar();
    //setLoadingBar("#main_loading_bar", "");
    $('#section_link_'+sectionId).parent().parent().find('a.current').removeClass('current');
    $('#section_link_'+sectionId).addClass("current");    
    $.get('/documents/'+sectionId,{},function(data){
        hideProgressBar();
        $('#document_panel').html(data);
        $('html, body').animate({scrollTop: $("#document_panel").scrollTop()}, 2000);
    },'html');
}

function searchDocuments(){
    showProgressBar();
    //setLoadingBar("#main_loading_bar", "");
    $("ul.resourcesLinkListing a").removeClass("current");
    $.get('documents/search', {
        'q':$('#search').val()
    }, function(data){
         hideProgressBar();
//        $(window).scrollTop($(window).scrollTop());
        $('#document_panel').html(data);
        //$('#level3nav').removeAttr('class');
        $('html, body').animate({scrollTop: $("#document_panel").scrollTop()}, 2000);
    },'html')
}

function loadAllDocuments(){
    showProgressBar();
    //setLoadingBar("#main_loading_bar", "");
    $('#section_link_view_all').parent().parent().find('a.current').removeClass('current');
    $('#section_link_view_all').addClass("current");
    $('#document_panel').load('/documents/list_documents',function(){
        hideProgressBar();
        $('html, body').animate({scrollTop: $("#document_panel").scrollTop()}, 2000);
    });
}
function setLoadingBar(container, style){
    $(container).html("<image src='/images/loding.gif' class='"+style+"' />");
}