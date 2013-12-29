function showSubFeature(feature_id)
{
    href = '/features/' + feature_id;
    $.ajax({
        type: "GET", // PUT NOT SUPPORTED BY ALL BROWSERS SO POST WITH "_method" => "put"
        url: href,
        cache: false,
        success: function(rst) {
            ro = rst;
            $("#divSubFeature").html(rst);
        }
    });
    return true;
}