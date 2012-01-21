(function(pool, $) {

    // can haz javascript?
    var body = $('body').addClass('has-js');
    
    // document load
    $(function() {

        // create header and close initially
        var header = new pool.Header($('#header'), $('#header a.toggle'));
        header.close();

        // nasty nasty fix for ios web-apps added to the home screen - links
        // always open in a new safari window.
        if (navigator.standalone !== undefined && navigator.standalone === true) {
            body.on('click', 'a', function(event) {
                var href = $(this).attr('href');
                if (href[0] !== '#') {
                    window.location = $(this).attr('href');
                    event.preventDefault();
                }
            });
        }

    });

} (pool, jQuery));