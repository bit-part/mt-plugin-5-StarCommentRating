$(function(){
    $('span.star-btn span.btn')
        .on('mouseenter', function(){
            $(this).css('cursor','pointer');
        })
        .on('mouseleave', function(){
            $(this).css('cursor','default');
        });

    $('span.star-btn').each(function(){
        var span = $(this);
        var rating = $(this).next('input').val();
        if (rating) {
            span.css('background-position', (-16 * (5 - rating)) + 'px 0');
        }
    });

    $('span.star-btn span.btn').each(function(){

        var span = $(this).parent('span');
        var input = span.next('input');
        var num = $(this).attr('title');
        $(this).on('mouseenter', function(){
            span.css('background-position', (-16 * (5 - num)) + 'px 0');
        }).on('mouseleave', function(){
            var rating = input.val();
            if (rating) {
                span.css('background-position', (-16 * (5 - rating)) + 'px 0');
            } else {
                span.css('background-position', 'right top');
            }
        });
        $(this).on('click', function(e){
            e.preventDefault();
            if (input.val() == num) {
                input.val('');
                span.css('background-position', '-80px 0');
            } else {
                input.val(num);
                span.css('background-position', (-16 * (5 - num)) + 'px 0');
            }
        });
    });
});
