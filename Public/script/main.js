(function(pool, $) {

    // can haz javascript?
    $('body').addClass('has-js');
    
    // document load
    $(function() {

        // create header and close initially
        var header = new pool.Header($('#header'), $('#header a.toggle'));
        header.close();

    });

} (pool, jQuery));