$(function() {

    var navR, navL = false;
    var first = 1;
    var positions = {
        '0': 0,
        '1': 194,
        '2': 388,
        '3': 582,
        '4': 776
    }
    var $categories = $('#categories');
    var elems = $categories.children().length;
    var $slider = $('#opcao');
    /**
     * let's position all the categories on the right side of the window
     */
    var hiddenRight = $(window).width() - $categories.offset().left;
    $categories.children('li').css('left', hiddenRight + 'px');
    /**
     * move the first 5 categories to the viewport
     */
    $categories.children('li:lt(5)').each(function(i) {
        var $elem = $(this);
        $elem.animate({
            'left': positions[i] + 'px',
            'opacity': 1
        }, 800, function() {
            if (elems > 5) enableNavRight();
        });
    });

});