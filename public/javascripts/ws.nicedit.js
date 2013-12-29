$(document).ready(function(){
    initializeHTMLEditorOnCommonQuestions();
});

function initializeHTMLEditorOnCommonQuestions(){
    description_editarea = new nicEditor({
        iconsPath : '/images/nicEditorIcons.gif',
        buttonList : ['fontSize', 'bold', 'italic', 'underline', 'strikeThrough', 'subscript', 'superscript', 'ol', 'ul', 'indent', 'outdent', 'link', 'unlink', 'removeformat']
        }).panelInstance('common_question_description');
}