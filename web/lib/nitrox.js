
alert("nitrox starting");
if (! this.console) {
    this.console = {};
}

function msgencode(string) {
   	return string.replace('&','&amp;')
   	             .replace('<','&lt;')
   	             .replace('>','&gt;')
   	             .replace('\'','&apos;')
   	             .replace('"','&quot;');
};

console.log = function(msg) {
    alert(msg);
    jQuery('#debuglog').html( msgencode(msg) + "<br/>--<br/>" + jQuery('#debuglog').html() );
    if (Nitrox.Runtime.enabled) {
        setTimeout(function() { window.location.href="nitroxlog://somehost/path?" + escape(msg); },
               1);
    }
};

Nitrox = function() {
        console.log("Nitrox constructed");
    };

Nitrox.log = function(msg) {
    alert(msg);
    setTimeout(function() {
               jQuery('#debuglog').html( msgencode(msg) + "<br/>--<br/>" + jQuery('#debuglog').html() );
               }, 10);
    if (Nitrox.Runtime.enabled && false) {
        setTimeout(function() { 
                window.location.href="nitroxlog://somehost/path?" + escape(msg); 
                // jQuery('#debuglog').html( msgencode("Logged2 " + msg) + "<br/>--<br/>" + jQuery('#debuglog').html() );                
            },
           20);
    }
    // TODO: this will be super-slow; need to create a queue
    jQuery.ajax({url: "http://localhost:" + Nitrox.Runtime.port + "/log", 
                data: msg, async: false, type: 'post'});
    // jQuery("document").triggerHandler("nitrox.log", msg);
};

console.log = Nitrox.log;

Nitrox.prototype = {
    };

Nitrox.Runtime = {
    enabled: false,
    port: 0,
    token: 'none',
    version: '0.1'
};

Nitrox.Bridge = {
    'call': function(fun, args, async) {
            Nitrox.log("step 1");
            Nitrox.log('FOO2 starting bridge call for ' + fun);
            var id = "id" + i++;
            if (!async) async = false;
            Nitrox.log("step 2, id="+id);
            Nitrox.log('FOO starting bridgecall for id ' + id);
            var port = Nitrox.Runtime.port;
            // clone args
            Nitrox.log("step 3");
            args = jQuery.extend(true, args, {'id': id, 'token': Nitrox.Runtime.token});
            var fullstring = "http://localhost:" + port + "/rpc/" + fun;
            Nitrox.log("Step 4, url=" + fullstring);
            var req;
            try {
                req = jQuery.ajax({url: fullstring, data: args, async: async, type: 'get'});
            } catch (e) {
                req = {error: e, status:401, responseText: "Error: " + e};
            }
            Nitrox.log("step 5");
            if (!req) {
                Nitrox.log("No request object returned");
                req = {error: "unknown", status:500, responseText:"No req object returned"};
            }
            if (req.status == 200) {
                var res = req.responseText; 
                Nitrox.log('response text for ajax is: ' + res);
            } else {
                Nitrox.log('error code: ' + req.status);
            }
            Nitrox.log('returning from id=' + id);
            return id;
        },

    'version': '0.1'
};

Nitrox.Location = {
    start: function(async) {
        Nitrox.Bridge.call('Location/c/start', {}, async);
    },

    stop: function(async) {
        Nitrox.Bridge.call('Location/c/stop', {}, async);
    },
    
    getLocation: function() {
        var location = Nitrox.Bridge.call('Location/c/getLocation', {}, true);
        Nitrox.log("location is " + location);
        return location;
    },
    
    version: '0.1'
};

Nitrox.Accelerometer = {
    start: function(async) {
        Nitrox.Bridge.call('Accelerometer/c/start', {}, async);
    },

    stop: function(async) {
        Nitrox.Bridge.call('Accelerometer/c/stop', {}, async);
    },
    
    getAcceleration: function() {
        var location = Nitrox.Bridge.call('Accelerometer/c/getAcceleration', {}, true);
        Nitrox.log("acceleration is " + location);
        return location;
    },
    
    version: '0.1'
};



Nitrox.Vibrate = {
    vibrate: function() {
        Nitrox.Bridge.call('Vibrate/c/vibrate', {}, true);
    },
    
    version: '0.1'
};

Nitrox.File = function(path) {
    Nitrox.log("File constructed at path " + path);
};

Nitrox.File.prototype = {
};



jQuery(function() {
       alert("Nitrox loaded");
       // console.log("Nitrox loaded");
});

