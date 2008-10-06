
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


Nitrox.prototype = {
    };

Nitrox.Runtime = {
    enabled: false,
    port: 0,
    token: 'none',
    debug: true,

    start: function() {
        // any startup functions here
    },

    baseURL: function() {
        return "http://127.0.0.1:" + this.port;
    },

    rpcURL: function() {
        var url = this.baseURL() + "/rpc";
        return url;
    },

    version: '0.1'
};

if (this.console && console.log) { 
    Nitrox.consolelog = console.log;
}

Nitrox.log = function(msg) {
    if (!Nitrox.Runtime.debug) {
        return;
    }

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
        jQuery.ajax({url: "http://127.0.0.1:" + Nitrox.Runtime.port + "/log", 
                    data: msg, async: false, type: 'post'});
    } else if (Nitrox.consolelog) {
        console.log(msg);
    }
};

console.log = Nitrox.log;


// general bridge functions

Nitrox.Bridge = {
    'call': function(fun, args, async) {
            var id = "id" + i++;
            if (!async) async = false;
            Nitrox.log('starting bridgecall for id ' + id);
            var port = Nitrox.Runtime.port;
            // clone args
            args = jQuery.extend(true, args, {'id': id, 'token': Nitrox.Runtime.token});
            var fullstring = Nitrox.Runtime.rpcURL() + "/" + fun;
            var req;
            try {
                req = jQuery.ajax({url: fullstring, data: args, async: async, type: 'get'});
            } catch (e) {
                req = {error: e, status:401, responseText: "Error: " + e};
            }
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
    loadJS: function(file, async) {
        if (!async) { async = false; }
        var url = Nitrox.Runtime.baseURL() + '/' + file;
        var res = jQuery.ajax({url: url, async: async, type: 'get'});
        if (res && res.status == 200) {
            eval(res.responseText);
            return true;
        } else {
            Nitrox.log("loadJS of " + file + " failed");
            return false;
        }
    },
    
    version: '0.1'
};

// proxy functions

Nitrox.Proxy = {
    ajax: function(ajaxObject) {
        Nitrox.log("proxy.ajax not yet supported");
        return "Not yet supported";
    },
    
    retrieve: function(url, callback, method) {
        Nitrox.log("proxy.retrieve not yet supported");
        if (!method) {
            method = "get";
        }

        var data = { url: url };
        url = Nitrox.Runtime.baseURL() + "/proxy/retrieve";
        var ajax = jQuery.ajax({url: url, data: data, async: (callback ? true : false), type: method});
        var res = false;

        if (callback) {
            return ajax;
        }
        
        if (ajax && ajax.status == 200) {
            return ajax.responseText;
        } else {
            return null;
        } 
    },
    
    version: '0.1'
};

// benchmark

Nitrox.Benchmark = {
    run: function(fun, count) {
        if (!count) { count = 1; };
        var actualCount = 0;
        var bDate = new Date();
        while (count-- > 0) {
            fun();
            actualCount++;
        }
        var eDate = new Date();
        return ((eDate.getTime() - bDate.getTime()) / actualCount);
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

// jQuery(function() {
//        Nitrox.log("Nitrox loaded");
// });

