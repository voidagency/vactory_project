$(document).ready(function () {
    /* copy demo sources to clipboard */
    function copyTextToClipboard(text) {
        var textArea = document.createElement("textarea");
        textArea.value = text;
        document.body.appendChild(textArea);
        textArea.select();
        document.execCommand('copy');
        document.body.removeChild(textArea);
        return false;
    }


    $('.copyable').each(function(){
        var $this = $(this),
            content = $this.get(0).outerHTML,
            title = "Click to copy source";
    
            $this.addClass("copyable");
            $this.tooltip({
                title: title,
                placement: 'top',
                trigger: 'hover'
            });

        $this.click(function(e){
            e.stopPropagation();
            e.preventDefault();
            $this.tooltip('dispose');
            $this.tooltip({
                title: "Copied!",
                fallbackPlacement:"clockwise",
                placement: 'top',
                trigger: 'hover'
            });
            $this.tooltip('show');
            copyTextToClipboard(content);
        }).mouseleave(function(){
            $this.tooltip('dispose');
            $this.tooltip({title:title, placement: 'right', trigger: 'hover'});
        });
    });
});