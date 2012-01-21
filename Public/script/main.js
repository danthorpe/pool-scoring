(function(pool, $) {

    // create header and close initially
    var header = new pool.Header($('#header'), $('#header a.toggle'));
    header.close();

} (pool, jQuery));