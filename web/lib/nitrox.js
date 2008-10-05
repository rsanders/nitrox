
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


Nitrox = function() {
    };

if (this.console && console.log) { 
    Nitrox.consolelog = console.log;
}

Nitrox.log = function(msg) {
    // alert(msg);
    setTimeout(function() {
               jQuery('#debuglog').html( msgencode(msg) + "<br/>--<br/>" + jQuery('#debuglog').html() );
               }, 10);
    if (Nitrox.Runtime.enabled && false) {
        setTimeout(function() { 
                window.location.href="nitroxlog://somehost/path?" + escape(msg);                
            },
           20);
    }
    // TODO: this will be super-slow if sync, and out-of-order if async; need to create a queue
    if (Nitrox.Runtime.enabled) {
        jQuery.ajax({url: "http://localhost:" + Nitrox.Runtime.port + "/log", 
                    data: msg, async: false, type: 'post'});
    } else if (Nitrox.consolelog) {
        console.log(msg);
    }
};

console.log = Nitrox.log;

Nitrox.prototype = {
    };

Nitrox.Runtime = {
    enabled: false,
    port: 0,
    token: 'none',

    baseURL: function() {
        return "http://localhost:" + this.port;
    },

    rpcURL: function() {
        var url = this.baseURL() + "/rpc";
        return url;
    },

    version: '0.1'
};

// general bridge functions

Nitrox.Bridge = {
    'call': function(fun, args, async) {
            //Nitrox.log("step 1");
            // Nitrox.log('FOO2 starting bridge call for ' + fun);
            var id = "id" + i++;
            if (!async) async = false;
            // Nitrox.log("step 2, id="+id);
            Nitrox.log('FOO starting bridgecall for id ' + id);
            var port = Nitrox.Runtime.port;
            // clone args
            // Nitrox.log("step 3");
            args = jQuery.extend(true, args, {'id': id, 'token': Nitrox.Runtime.token});
            var fullstring = Nitrox.Runtime.rpcURL() + "/" + fun;
            // Nitrox.log("Step 4, url=" + fullstring);
            var req;
            try {
                req = jQuery.ajax({url: fullstring, data: args, async: async, type: 'get'});
            } catch (e) {
                req = {error: e, status:401, responseText: "Error: " + e};
            }
            // Nitrox.log("step 5");
            if (async) {
                Nitrox.log("returning from async " + fun + " , id=" + id);
                return;
            }
            if (req == null) {
                Nitrox.log("No request object returned");
                req = {error: "unknown", status:500, responseText:"No req object returned"};
            }
            if (req && req.status == 200) {
                var res = req.responseText; 
                Nitrox.log('response text for ajax is: ' + res);
            } else {
                Nitrox.log('error code: ' + req.status);
            }
            Nitrox.log('returning from id=' + id);
            return req.responseText;
        },

    'version': '0.1'
};

// location functions

Nitrox.Location = {
    start: function(async) {
        Nitrox.Bridge.call('Location/c/start', {}, async);
    },

    stop: function(async) {
        Nitrox.Bridge.call('Location/c/stop', {}, async);
    },
    
    getLocation: function() {
        var location = Nitrox.Bridge.call('Location/c/getLocation', {}, false);
        Nitrox.log("location is " + location);
        return location;
    },
    
    version: '0.1'
};

// accelerometer

Nitrox.Accelerometer = {
    start: function(async) {
        Nitrox.Bridge.call('Accelerometer/c/start', {}, async);
    },

    stop: function(async) {
        Nitrox.Bridge.call('Accelerometer/c/stop', {}, async);
    },
    
    getAcceleration: function() {
        var accel = Nitrox.Bridge.call('Accelerometer/c/getAcceleration', {}, false);
        Nitrox.log("acceleration is " + accel);
        return accel;
    },
    
    version: '0.1'
};

// device information

Nitrox.Device = {
    getDeviceAttribute: function(attrname) {
        return Nitrox.Bridge.call('Device/c/' + attrname, {}, false);
    },

    model: function() {
        return Nitrox.Device.getDeviceAttribute('model');
    },

    orientation: function() {
        return Nitrox.Device.getDeviceAttribute('orientation');
    },
    
    version: '0.1'
};

// vibration functions

Nitrox.Vibrate = {
    vibrate: function() {
        Nitrox.Bridge.call('Vibrate/c/vibrate', {}, true);
    },
    
    version: '0.1'
};

// lang / runtime functions

Nitrox.Lang = {
    loadJS: function(file) {
        Nitrox.log("lang.loadJS not yet supported");
        return "Not yet supported";
    },
    
    version: '0.1'
};

// proxy functions

Nitrox.Proxy = {
    ajax: function(ajaxObject) {
        Nitrox.log("proxy.ajax not yet supported");
        return "Not yet supported";
    },
    
    retrieve: function(url, callback) {
        Nitrox.log("proxy.retrieve not yet supported");
        return "Not yet supported";
    },
    
    version: '0.1'
};


// file functions

Nitrox.File = function(path) {
    Nitrox.log("File constructed at path " + path);
};

Nitrox.File.prototype = {
};

// final bootstrap

jQuery(function() {
       Nitrox.log("Nitrox loaded");
});

