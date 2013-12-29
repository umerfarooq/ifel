$(document).ready(function(){
    
    $('#cancel_overdue_notice').click(function(){
        $.post('/projects/hide_overdue_notice', {}, function(){
            hideOverdueNoticeBar();
        },'json');
    });

    $('#select_all_sections').click(function(){
        if($('#select_all_sections').attr('checked')){
            $('.roadMapTitle').find(':checkbox').attr('checked', this.checked);
            $('#actions_menu').slideDown(1000);
        }else{
            $('.roadMapTitle').find(':checkbox').attr('checked', false);
            $('#actions_menu').slideUp(1000);
        }
    });

    $(".sectionBox").click(function(){
        if($(this).attr('checked')){
            $('#actions_menu').slideDown(1000);
            if($('.roadMapTitle').find("input:checked").length==$('.roadMapTitle').find(':checkbox').length){
                $('#select_all_sections').attr('checked', true);
            }
        }else{
            if($('.roadMapTitle').find("input:checked").length == 0){
                $('#actions_menu').slideUp(1000);
            }
            $('#select_all_sections').attr('checked', false);
        }
    });

    $("#print_option").change(function(){
        if($(this).val()!='none'){
            $("#print_roadmap_form").submit();
        }
    });

    $('.additionalSections').click(function(){
        $(this).hide('blind', 1000);
        $('.roadMapTitle').show('blind', 1000);
    });

    $("#add_todo").click(function(){
        $('#sentConfirmPanel').fadeOut('slow');
        if ($("#addTodoPanel").is(':hidden'))
            $("#addTodoPanel").fadeIn('slow', function(){
                activateDefaultText();
            });
        else{
            $("#addTodoPanel").fadeOut('slow');
        }
        return false;
    });


    $('#addTodoPanel').click(function(e) {
        e.stopPropagation();
    });
    $(document).click(function() {
        $('#sentConfirmPanel').fadeOut('slow');
    });

    $(function (){
        $('#todo_due_date').datepicker({
            onSelect : function(){
                $("#addTodoPanel").show();
                $("#todo_due_date").next().hide();
                $("#todo_due_date").show();
                $("#todo_due_date").focus();
            }
        });
    });

    $('#closeTodoPopup').click(function() {
        resetAllFields();
        $('#addTodoPanel').fadeOut('slow');
    });
    $("form#add_todo_form").submit(function() {
        var title = $('#todo_title').attr('value');
        var deadline = $('#todo_due_date').attr('value');
        //var completion_status = $('#todo_is_completed').attr('value');
        var token = $("input[name=authenticity_token]").attr("value");
        if(jQuery.trim(title).length > 0 && jQuery.trim(deadline).length > 0 ){
            $.ajax({
                type: "POST",
                url: "/projects/add_todo",
                data: {
                    "todo[title]":title,
                    "todo[due_date]":deadline,
                    "authenticity_token":token
                },
                success: function(data){
                    if(data.success){
                        resetAllFields();
                        $('#addTodoPanel').hide();
                        $('#sentConfirmPanel').show();
                    }else{
                        $('#notice').text("Request can't be send, due to system problem");
                    }
                },
                dataType:'json'
            });
        } else {
            $('#notice').text("Please complete all fields");
        }
        return false;
    });

    $('.sectionDeadline').datepicker();
   
});

function Default_section(){

    $('.additionalSections').hide('blind', 1000);
    $('.roadMapTitle').show('blind', 1000);
}

function activateDefaultText(){
    $('#todo_title').hide();
    $('#todo_title').next().show();
    $('#todo_due_date').hide();
    $('#todo_due_date').next().show();
}
function resetAllFields(){
    $('#todo_title').val('');
    $('#todo_due_date').val('');
    $('#notice').text("");
}

function showOverdueNoticeBar(){
    $('.notificationMsg').delay(800).show("blind",{},1000);
}
function hideOverdueNoticeBar(){
    $('.notificationMsg').hide("blind",{},1000);
}
function toggleSectionPanel(section_number){
    if($("#action_items_panel_"+section_number).is(':hidden')){
        $("#action_items_panel_"+section_number).slideDown(1000, function(){
            $("#slide_arrow_"+section_number).attr('src','/images/theme/up-arrow.png');
        });
    }else{
        $("#action_items_panel_"+section_number).slideUp(1000,function(){
            $("#slide_arrow_"+section_number).attr('src','/images/theme/down-arrow.png');
        });
    }
}

function openSectionPanel(section_number){
   
    $("#action_items_panel_"+section_number).delay(800).slideDown(1000, function(){
        $("#slide_arrow_"+section_number).attr('src', '/images/theme/up-arrow.png');
    });
}
function showUpcomingTodos(){
    var moreAnchor = $(".moreTodos a");
    if(moreAnchor.attr('title') == 'view more'){
        $(".upcomingTodos").slideDown(1000, function(){
            moreAnchor.html("View Less").attr("title", "view less");
        });
    }else{
        $(".upcomingTodos").slideUp(1000, function(){
            moreAnchor.html("View More").attr("title", "view more");
        });
    }
}
function showActionItems(){
    var moreAnchor = $(".moreItems a");
    if(moreAnchor.attr('title') == 'view more'){
        $(".recentItems").slideDown(1000, function(){
            moreAnchor.html("View Less").attr("title", "view less");
        });
    }else{
        $(".recentItems").slideUp(1000, function(){
            moreAnchor.html("View More").attr("title", "view more");
        });
    }
}

function editSectionDeadline(section_id){    
    if($('#edit_deadline_link_'+section_id).attr('title') == 'Edit Deadline'){
        $("#deadline_text_"+section_id).removeClass('dispInline').addClass('dispNone');
        $("#deadline_date_"+section_id).removeClass('dispNone').addClass('dispInline');
        $('#edit_deadline_link_'+section_id).attr('title','Update Deadline');
        $('#deadline_icon_'+section_id).attr('src', '/images/qstn-cmpitator-icn.png')
    }else{
        $.post('/sections/'+section_id+'/update_deadline',
        {
            deadline : $("#deadline_date_field_"+section_id).val(),
            '_method' : 'put'
        }, function(data){
            $("#deadline_text_"+section_id).removeClass('dispNone').addClass('dispInline');
            $("#deadline_date_"+section_id).removeClass('dispInline').addClass('dispNone');
            $('#edit_deadline_link_'+section_id).attr('title','Edit Deadline');
            $('#deadline_container_'+section_id).html(data);
            $("#deadline_date_field_"+section_id).datepicker();
        },
        'html');
    }
}
function open_section_item(path, item_id){
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
    var answer = $('#user_answer').val();
    $.get(path, {'current_item_id' : item_id, 'item_user_answer': answer},function(data){
        $.unblockUI();
        $('#roadmap_container').html(data)
        //$(".roadMapInnerContent").scrollTop(2000);
        $('html, body').animate({
            scrollTop: $(".roadMapInnerContent").scrollTop()
        }, 2000);
    },
    'html');
}
function mark_item_inprogress(url){
    $.post(url, {
        '_method' : 'put',
        'is_complete':false
    }, function(data){
        if(data.updated){
            $('#item_status_icon').attr('src','/images/inprogress.png');    
            $('#action_item_status_panel').html(data.html);    
        }
    }, 'json');
}
function mark_item_complete(url){
    $.post(url, {
        '_method' : 'put',
        'is_complete':true
    }, function(data){
        if(data.updated){
            $('#item_status_icon').attr('src','/images/complete.png');
            $('#action_item_status_panel').html(data.html);   
//            if(data.show_popup){
//                $.blockUI({
//                    message: $('<p style="color: #000000; font-weight: bold;">Congratulations on finishing Step 1: Business Concept Statement.</p><p style="color: #000000;" ><a href="http://nyustern.qualtrics.com/SE/?SID=SV_8cQ2HwsTzl3hSQI" target="_blank">Click here</a> to setup a meeting with a Berkley Center Advisor.</p>'),
//                    css: {
//                        border: 'none',
//                        padding: '7px',
//                        backgroundColor: '#b6fe93',
//                        '-webkit-border-radius': '10px',
//                        '-moz-border-radius': '10px',
//                        opacity: 5,
//                        color: '#b6fe93',
//                        textAlign: 'center',
//                        cursor: 'wait'
//                    },
//                    centerX: true,
//                    centerY: true
//                });
//                $('.blockOverlay').attr('title','Click to close message box').click($.unblockUI);
//            }
        }
        
    }, 'json');
}
function mark_item_not_applicable(url){
    $.post(url, {
        '_method' : 'put',
        'is_applicable':false
    }, function(data){
        if(data.updated){
            $('#item_status_icon').attr('src','/images/notapplicable.png');
            $('#action_item_status_panel').html(data.html);
            if(data.show_popup){
                $.blockUI({
                    message: $('<p style="color: #000000; font-weight: bold;">Congratulations on finishing Step 1: Business Concept Statement.</p><p style="color: #000000;" ><a href="http://nyustern.qualtrics.com/SE/?SID=SV_8cQ2HwsTzl3hSQI" target="_blank">Click here</a> to setup a meeting with a Berkley Center Advisor.</p>'),
                    css: {
                        border: 'none',
                        padding: '7px',
                        backgroundColor: '#b6fe93',
                        '-webkit-border-radius': '10px',
                        '-moz-border-radius': '10px',
                        opacity: 5,
                        color: '#76cdff',
                        textAlign: 'center',
                        cursor: 'wait'
                    },
                    centerX: true,
                    centerY: true
                });
                $('.blockOverlay').attr('title','Click to close message box').click($.unblockUI);
            }
        }
        
    }, 'html');
}

function addUserAnswer(path){
    var answer = $('#user_answer').val();
    if(jQuery.trim(answer).length > 0){
        showProgressBar();
        $.post(path, {
            '_method':'put',
            'item_user_answer': answer
        }, function(data){
            hideProgressBar();
            if(data.success){
                $("#add_text_notice").removeClass('uploadError').addClass('uploadNotif').html("Your text has been saved");            
            }else{
                $("#add_text_notice").removeClass('uploadNotif').addClass('uploadError').html("Your text is not saved");
            }
        }, 'json');
    }else{
        $("#add_text_notice").removeClass('uploadNotif').addClass('uploadError').html("Please add some text to save");
    }
}

function showInfoPanel(panel_id){
    $("#"+panel_id).show();
}

function hideInfoPanel(panel_id){
    $("#"+panel_id).hide();
}

function showSectionVideo(section){
    $("#step_image_"+section).hide();
    $("#step_video_"+section).show();
}

function showAllSections(){
    $('.additionalSections').hide('blind', 1000);
    $('.roadMapTitle').show('blind', 1000);
}