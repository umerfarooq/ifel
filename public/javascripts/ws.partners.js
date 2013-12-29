$(document).ready(function(){
    $("#btnBecomePartner").click(function(){
        if ($("#becomePartPanel").is(':hidden'))
            $("#becomePartPanel").fadeIn('slow');
        else{
            $("#becomePartPanel").fadeOut('slow');
        }
        return false;
    });

    $('#becomePartPanel').click(function(e) {
        e.stopPropagation();
    });
    $(document).click(function() {
        resetAllFields();
        $('#becomePartPanel').fadeOut('slow');
        $('#sentConfirmPanel').fadeOut('slow');
    });

    $("form#partner_request_form").submit(function() {
        var company_name = $('#partner_request_company_name').attr('value');
        var contact_name = $('#partner_request_contact_name').attr('value');
        var phone_number = $('#partner_request_phone_number').attr('value');
        var email = $('#partner_request_email').attr('value');
        var token = $("input[name=authenticity_token]").attr("value");
        if(jQuery.trim(company_name).length > 0 && jQuery.trim(contact_name).length > 0 && jQuery.trim(phone_number).length > 0 && jQuery.trim(email).length > 0 ){
            var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
            if(emailReg.test(email)) {
                $.ajax({
                    type: "POST",
                    url: "/partners/become_partner_request",
                    data: {
                        "company_name":company_name,
                        "contact_name":contact_name,
                        "phone_number":phone_number,
                        "email":email,
                        "authenticity_token":token
                    },
                    success: function(data){
                        if(data.success){
                            resetAllFields();
                            $('#becomePartPanel').hide();
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

function resetAllFields(){
    $('#partner_request_company_name').val('');
    $('#partner_request_contact_name').val('');
    $('#partner_request_phone_number').val('');
    $('#partner_request_email').val('');
    $('#notice').text("");
}