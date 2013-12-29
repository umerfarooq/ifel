$(document).ready(function(){
    //    makeNavigationPanelStatic();
    loadAllResourcesTags();
    $("#btnSubmitResource").click(function(){
        if ($("#submitResourcePanel").is(':hidden')){
            $("#submitResourcePanel").fadeIn('slow', function(){
                activateDefaultText();
            });
        }else{
            $("#submitResourcePanel").fadeOut('slow');
        }
        return false;
    });

    $('#submitResourcePanel').click(function(e) {
        e.stopPropagation();
    });

    $(document).click(function() {
        resetAllFields();
        $('#submitResourcePanel').fadeOut('slow');
        $('#sentConfirmPanel').fadeOut('slow');
    });

    $("form#submit_resource_form").submit(function() {
        var company_name = $('#resource_company_name').attr('value');
        var contact_name = $('#resource_contact_name').attr('value');
        var email = $('#resource_email').attr('value');
        var token = $("input[name=authenticity_token]").attr("value");
        if(jQuery.trim(company_name).length > 0 && jQuery.trim(contact_name).length > 0 && jQuery.trim(email).length > 0 ){
            var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
            if(emailReg.test(email)) {
                $.ajax({
                    type: "POST",
                    url: "/resources/submit_resource",
                    data: {
                        "company_name":company_name,
                        "contact_name":contact_name,
                        "email":email,
                        "authenticity_token":token
                    },
                    success: function(data){
                        if(data.success){
                            resetAllFields();
                            $('#submitResourcePanel').hide();
                            $('#sentConfirmPanel').show();
                        }else{
                            $('#notice').text("Request can't be send, due to system problem");
                        }
                    },
                    dataType:'json'
                });
            }else{
                $('#notice').text("Please enter a valid email address");
            }
        } else {
            $('#notice').text("Please complete all fields");
        }
        return false;
    });
});

function loadAllResourcesTags(){
    $('div #topTenTags').html('<img src="/images/ajax-loader.gif" style="margin-right: 65px; margin-top: 100px;"></img>');
    $('#topTenTags').load('/resources/load_all_tags');
}

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
function activateDefaultText(){
    $('#resource_company_name').hide();
    $('#resource_company_name').next().show();
    $('#resource_contact_name').hide();
    $('#resource_contact_name').next().show();
    $('#resource_email').hide();
    $('#resource_email').next().show();
}
function resetAllFields(){
    $('#resource_company_name').val('');
    $('#resource_contact_name').val('');
    $('#resource_email').val('');
    $('#notice').text("");
}
function likes_content(resourceId){
    $.ajax({
        url: "/resources/"+resourceId+'/thumbs_up',
        type: "POST",
        data: $(this).val(),
        success: function(data){
            $('#likings_panel_with_arrows_'+resourceId).html(data);
        }
    });

}
function dislikes_content(resourceId){
    $.ajax({
        url: "/resources/"+resourceId+'/thumbs_down',
        type: "POST",
        success: function(data){
            $('#likings_panel_with_arrows_'+resourceId).html(data);
        }
    });
}
function loadTags(tagId){
    showProgressBar();
    $('#list li').click(function(){
        $(this).parent().find('li.text_color').removeClass('text_color');
        $(this).addClass('text_color');
    });
    $('#resource_section_content_panel').load('/resources/load_tag_content/'+tagId,function(){
        hideProgressBar();
    });
}
function save_click_track(resourceId,userId){
    $.ajax({
        type: 'GET',
        url: '/resources/click/'+resourceId+'/'+userId,
        success: function(data){
        //alert('added');
        },
        failure: function(data) {
        //alert('failed');
        }
    });
    return false;
//$('#comment_panel_'+resourceId).load('/resources/'+resourceId+'/add_comments/');
}
    
function loadCommentsContent(resourceId){
    $('#comment_panel_'+resourceId).load('/resources/'+resourceId+'/show_comments/', function(){
        $('#comment_panel_'+resourceId).show();
    });
}
function save_comments(resourceId){
    commentBody = $("#body_"+resourceId).val();
    if (commentBody =='')
    {
        alert("Comments cannot be empty");
    }
    else
    {
        $.ajax({
            type: 'POST',
            url: '/resources/'+resourceId+'/add_comments/',
            data: "comment_body=" + commentBody,
            success: function(data){
                $('#comment_panel_'+resourceId).text(data).html(data);
            },
            failure: function(data) {
                alert("Could not post comment at this time.");
            }
        });
    }
//return false;
//$('#comment_panel_'+resourceId).load('/resources/'+resourceId+'/add_comments/');
}

function view_all_tags(){
    $(".li_all_tags").removeClass('dispNone').addClass('dispBlock');
    //
    $("#view_more_tags").hide();
}

function load_all_resources(category_id){
    showProgressBar();
    resources_count = $('#resources_list_'+category_id+' > div.postItem').size();
    $.get('/resources/load_more_resources', {
        'category_id' : category_id, 
        'resources_count' : resources_count
    }, function(data){
        hideProgressBar();
        $('#temp_resources_block').html(data);
        temp_resources_count = $('#temp_resources_block > div.postItem').size();
        if(temp_resources_count != (resources_count+5)){
            $('h3#view_more_'+category_id).html("");
        }
        $('div #resources_list_'+category_id).html(data);
        
    }, 'html');
    
    
}
