$(document).ready(function(){
    var openPanel = false;
    var container_name;
    
    $('.opener').click(function(){        
        if($(this).attr('id') != 'task_dock_arrow'){
            $(this).parent('.dockbarHeader').children('.current').removeClass('current');
            $(this).addClass('current');
        }
        container_name = $('.dockbarHeader a.current').attr('container');
        var html = $('#'+container_name).html();
        if(jQuery.trim(html)<=0){
            showProgressBar();
            $.get('/items/'+$('#item_id').val()+'/get_resources', {
                'type':container_name
            }, function(data){
                hideProgressBar();
                $('#'+container_name).html(data);
                openSlider(container_name);
            }, 'html');
        }else{
            openSlider(container_name);
        }

        if(container_name == 'question'){
            if($('.token-input-list-facebook').length <= 0){
                $.get('/topics/list', {}, function(data){
                    $("#tags").tokenInput(data.topics,{
                        theme: "facebook",
                        preventDuplicates: true
                    });
                }, 'json');
            }
        }
    });
    $('.sectionDeadline').datepicker();

    item_id_value = $('#item_id').val();
    new AjaxUpload('upload_file_btn', {
        action: ["", "items", item_id_value, "add_file"].join("/"),
        data : {
            '_method'               : "post"
        },
        autoSubmit: false,             // Submit file after selection
        responseType: "json",         // Useful when you are using JSON data as a response, set to "json" in that case.
        onChange: function (f, e) {
            var ajaxUp = $(this);
            if (!(/^(jpg|png|jpeg|gif|doc|docx|xls|xlsx|pdf|ppt|csv|eps|flv|mov|mp4|wma|zip|rar|txt|rtf|wps|wpd|dat|pps|ppt|pptx|xml|mp3|bmp|tif|psd|mpp|vsd|vss|vst|vdx|vtx|vsx)$/i.test(e))){
                $("#upload_file_error").removeClass('uploadNotif').addClass('uploadError').html("Invalid File Type");
                return false;
            }else{
                $.get('/items/'+item_id_value+'/is_file_exist',{
                    'file':f
                },function(data){
                    if(data.file_exists){
                        if(confirm("A file with the same name already exists, do you want to replace it?")){
                            // Delete an existing file here
                            $.post("/documents/"+data.document_id, "_method=delete", function(){
                                ajaxUp.submit();
                            });
                        }else{
                            return false;
                        }
                    }else{
                        ajaxUp.submit();
                    }
                }
                ,'json');
            }
        }, // Fired after the file is selected
        onSubmit: function (f, e) {    // Fired before the file is uploaded
            $("#upload_file_error").html("<image src='/images/loding.gif' class='itemFileUpload' />");
        },
        onComplete: function (file, response) {  // Fired when file upload is completed  // WARNING! DO NOT USE "FALSE" STRING AS A RESPONSE!
            if(response.success){
                var path = response.path;
                $("#upload_file_error").removeClass('uploadError').addClass('uploadNotif').html(response.message);
            } else {
                $("#upload_file_error").html(response.message);
            }
            this.enable();
        }
    });

//dockBounce();

});

function showResourceDockPanel(){
    $('.dockbarHeader').children('.current').removeClass('current');
    $('div.dockbarHeader a[container="resources"]').addClass('current');
    
    var html = $('#resources').html();
    if(jQuery.trim(html)<=0){
        showProgressBar();
        $.get('/items/'+$('#item_id').val()+'/get_resources', {
            'type': 'resources'
        }, function(data){
            hideProgressBar();
            $('#resources').html(data);
            openSlider('resources');
        }, 'html');
    }else{
        openSlider('resources');
    }
}

function dockBounce(){
    $('.dockbar').effect('bounce', {
        direction:'down',
        distance:10
    }, 300);
}

function openSlider(container_name){
    if($('.dockbarSlider').is(":visible")){
        if($('.dockbarSlider:visible').attr('id') != container_name){
            $('.dockbarSlider:visible').hide();
            $('#'+container_name).show();
            return true;
        }
    }
    $('#'+container_name).slideToggle('slow', function(){
        $('#task_dock_arrow').toggleClass("taskDocDownArrow");
    });
}

function showPanel(id, type){
    $('.filesList li').children('a.current').removeClass('current');
    $('#'+type+'_opener_'+id).addClass('current');
    $('.filesColRight:visible').hide();
    $('#'+type+'_panel_'+id).show();
}

function addNote(){
    var note_text = $('#note').val();
    if(jQuery.trim(note_text).length > 0){
        var url = 'items/'+$('#item_id').val()+'/add_note';
        $.post(url, {
            'description' : note_text
        }, function(data){
            $('#notes').html(data);
            $('#note_notification').removeClass('uploadError').addClass('uploadNotif').html("Note has been added to your Item");
        },'html');
    }else{
        $('#note_notification').removeClass('uploadNotif').addClass('uploadError').html("Some text is mandatory to add a Note");
    }
}

function closeDockHelp(){
    $('.dockBarHelp').hide();
    $.post('/projects/close_dock_help', {
        '_method':'put'
    }, function(){
        
        },'json');
}

function showShareByEmailPanel(){
    if($('#share_check').is(':checked')){
        $('#share_by_email_panel').show('blind', 1000);
    }else{
        $('#share_by_email_panel').hide('blind', 1000);
    }    
}

function postQuestion(url){
    var body = $('#message_body').val();
    if(jQuery.trim(body).length > 0){
        var template_id = $('#section_template_id').val();
        var tags = $('#tags').val();
        //    var is_private = $('#private_flag').is(':checked');
        var token = $("input[name=authenticity_token]").attr("value");
        showProgressBar();
        $.post(url,
        {
            'message[topics]':tags,
            'message[body]':body,
            'message[section_template_id]':template_id,
            //'message[is_private]':is_private,
            'authenticity_token':token
        }, function(data){
            hideProgressBar();
            if(data.question_posted){
                $('#post_quest_notif').removeClass('uploadError').addClass('uploadNotif').html("Question has been posted to the Community");
                $('#message_body').val("");
                $('#tags').tokenInput('clear');
                $('#section_template_id').val(data.default_section_id);
                
            }else{
                $('#post_quest_notif').removeClass('uploadNotif').addClass('uploadError').html("Question is not posted to the Community");
            }
        }, 'json');
    }else{
        $('#post_quest_notif').removeClass('uploadNotif').addClass('uploadError').html("Please add some text to Post the Question");
    }
}