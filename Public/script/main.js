(function(pool, $) {

    // can haz javascript?
    var body = $('body').addClass('has-js');
    
    // document load
    $(function() {

        // create header and close initially
        var header = new pool.Header($('#header'), $('#header a.toggle'));
        header.close();
        
        // team picker - super quick-and-dirty jQuery version...
        // ... will fix this later :)
        var teamPicker = $('#team-picker');
        if (teamPicker.length > 0) {
            
            // loop players
            $('label.player').each(function() {
                
                var player = $(this),
                    playerId = player.attr('data-player-id'),
                    input = player.find('input'),
                    twin = teamPicker.find('[data-player-id="' + playerId + '"]').not(player);
                
                // input change
                input.on('change', function(event) {
                    if (input.is(':checked')) {
                        player.addClass('recruited');
                        twin.trigger('disable');
                    } else {
                        player.removeClass('recruited');
                        twin.trigger('enable');
                    }
                    player.trigger('change');
                }).trigger('change');
                
                // disable/enable
                player.on('disable', function(event) {
                    input.attr('disabled', true);
                    player.addClass('disabled');
                });
                player.on('enable', function(event) {
                    input.removeAttr('disabled');
                    player.removeClass('disabled');
                });
                
            });
            
        }

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