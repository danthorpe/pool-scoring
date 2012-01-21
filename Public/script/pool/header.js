(function() {

    // check namespace - kinda nasty but temporary
    window.pool = window.pool || {};

    // header object
    Header = (function() {
        
        var
        
        // constants
        CLOSED_CLASS = 'closed',
        OPENED_TOGGLE_TEXT = '&#x25B2;',
        CLOSED_TOGGLE_TEXT = '&#x25BC;',
        
        // constructor
        Header = function(headerElement, toggleElement) {
            
            // create/store elements
            this.elements = {
                header: headerElement,
                toggle: toggleElement
            };
            
            // bind event handlers
            bindToggleClick.call(this);
            
        },
        
        // (private) bind toggle click event
        bindToggleClick = function() {
            var header = this;
            this.elements.toggle.on('click', function(event) {
                if (header.isOpen() === true) {
                    header.close();
                } else {
                    header.open();
                }
                event.preventDefault();
            });
        },
        
        // (private) set the open state
        setOpenState = function(isOpen) {
            if (isOpen === true) {
                this.elements.header.removeClass(CLOSED_CLASS);
                this.elements.toggle.html(OPENED_TOGGLE_TEXT);
            } else {
                this.elements.header.addClass(CLOSED_CLASS);
                this.elements.toggle.html(CLOSED_TOGGLE_TEXT);
            }
        },
        
        // shortcut to the object prototype
        proto = Header.prototype;
        
        // (public) open/close methods
        proto.isOpen = function() {
            return !this.elements.header.hasClass(CLOSED_CLASS);
        };
        proto.open = function() {
            setOpenState.call(this, true);
        };
        proto.close = function() {
            setOpenState.call(this, false);
        };
        
        // return the constructor
        return Header;
        
    } ());
    
    // exports
    window.pool.Header = Header;

} ());