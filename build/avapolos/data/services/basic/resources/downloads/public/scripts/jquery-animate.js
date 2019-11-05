$(function() {

    $(".categorias").each(function(j) {    
        var positions = {
            '0': 0,
            '1': 172,
            '2': 344,
            '3': 516,
            '4': 688
        }

        var $categorias = $(this);
        var elems = $categorias.children().length;
        var $slider = $('#opcao');

        var hiddenRight = $(window).width() - $categorias.offset().left;
        $categorias.children('li').css('left', hiddenRight + 'px');

        $categorias.children().each(function(i) {
            var $elem = $(this);
            $elem.animate({
                'left': positions[i] + 'px',
                'opacity': 1
            }, 800, function() {
                if (elems > 5) enableNavRight();
            });
        });
    });    

});