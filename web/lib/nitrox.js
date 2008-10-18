
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
    if (arguments.length == 1 && typeof arguments[0] == 'function') {
        Nitrox.log("Scheduling function for onready");
        jQuery(document).one('nitroxready', arguments[0]);
    }
};


Nitrox.prototype = {
    };

Nitrox.Runtime = {
    enabled: true,
    port: 58214,
    appid: '',
    token: 'none',
    debug: true,
    iframe: null,

    start: function() {
        // any startup functions here
    },

    baseURL: function() {
        return "http://127.0.0.1:" + this.port;
    },

    appURL: function() {
        return "http://127.0.0.1:" + this.port + "/_app/" + _nitrox_info.appid;
    },

    rpcURL: function() {
        var url = this.appURL() + "/rpc";
        return url;
    },
    
    finishedLoading: function() {
        Nitrox.log("finishedLoading() called");
        jQuery(document).trigger('nitroxready');
    },
    
    pageReady: function() {
        var body = document.getElementsByTagName('body')[0];
        var div = document.createElement('div');
        div.style="display:none;";
        if (body) {
            this.iframe = document.createElement('iframe');
            this.iframe.id = '__nitrox_rpc_iframe';
            body.appendChild(div);
            div.appendChild(this.iframe);
            // this.iframe.src = '#';
            this.iframe.name = '__nitrox_rpc_iframe';
            this.iframe.style.border="0px";
            this.iframe.style.width="0px";
            this.iframe.style.height="0px";
            this.iframe.style.position="absolute";
            this.iframe.style.top="-500px";
            this.iframe.style.left="-500px";
        }
    },

    version: '0.1'
};

if (this.console && console.log) { 
    Nitrox.consolelog = console.log;
}

Nitrox.log = function(msg, skipremote) {
    if (!Nitrox.Runtime.debug) {
        return;
    }

    setTimeout(function() {
               jQuery('#debuglog').html( msgencode(msg) + "<br/>--<br/>" + jQuery('#debuglog').html() );
               }, 1);

    if (Nitrox.Runtime.enabled && false) {
        setTimeout(function() { 
                window.location.href="nitroxlog://somehost/path?" + escape(msg);                
            },
           20);
    } else if (Nitrox.Runtime.enabled && window.nadirect.log  && ! window.nadirect.isSimulated) {
        window.nadirect.log(msg);
    } else if (Nitrox.Runtime.enabled && !skipremote) {
        // TODO: this will be super-slow if sync, and out-of-order if 
        // async; need to create an outbound ajax queue
        jQuery.ajax({url: "http://127.0.0.1:" + Nitrox.Runtime.port + "/log", 
                    data: msg, async: false, type: 'post'});
        
    } else if (Nitrox.consolelog) {
        Nitrox.consolelog(msg);
    }
};

console.log = Nitrox.log;

if (! window.nadirect) { window.nadirect = {}; }
if (! window.nadirect.log) {
    window.nadirect.log = Nitrox.log;
    window.nadirect.isSimulated = true;
}


// general bridge functions

Nitrox.Bridge = {
    idcounter: 0,
    
    'call': function(fun, args, async, ajaxOpts) {
            var id = "id" + this.idcounter++;
            if (!async) async = false;
            // window.nadirect.log('NBc: starting bridgecall for id ' + id);
            var port = Nitrox.Runtime.port;
            // clone args
            if (! ajaxOpts) { ajaxOpts = {}; }
            args = jQuery.extend(true, args, {'__id': id, '__token': Nitrox.Runtime.token});
            var fullstring = Nitrox.Runtime.rpcURL() + "/" + fun;
            var req;
            try {
                var ajaxObject = {url: fullstring, data: args, async: async, type: 'get'};
                ajaxObject = jQuery.extend(ajaxObject, ajaxOpts);
                window.nadirect.log("NBc: ajax object: " + Nitrox.Lang.toJSON(ajaxObject));
                req = jQuery.ajax(ajaxObject);
                window.nadirect.log("NBc: ajax returned without exception");
                if (req.readyState == 4) {
                    //window.nadirect.log("NBc: ajax status is " + req.status);                    
                }
            } catch (e) {
                window.nadirect.log("NBc: caught error in Nitrox.Bridge.call: " + e);
                req = {error: e, status:401, responseText: "Error: " + e};
            }
            var res = null;
            if (async) {
                window.nadirect.log("NBc: returning from async " + fun + " , id=" + id);
                return null;
            }
            if (! req) {
                window.nadirect.log("NBc: No request object returned");
                req = {error: "unknown", status:500, responseText:"No req object returned"};
            }
            if (req && req.status == 200 && req.readyState == 4) {
                res = jQuery.evalJSON(req.responseText);
                window.nadirect.log('NBc: response text for ajax is: ' + res);
            } else {
                window.nadirect.log('NBc: not ready: state = ' + (req ? req.readyState : "no req"));
            }
            return res;
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
    
    delegate: function(loc) {
        Nitrox.log("default location delegate received location: " + Nitrox.Lang.toJSON(loc));
    },
    
    version: '0.1'
};

// accelerometer

Nitrox.Accelerometer = {
    updateCount: 0,
    
    currentAcceleration: null,
    
    start: function(async) {
        Nitrox.Bridge.call('Accelerometer/c/start', {}, async);
    },

    stop: function(async) {
        Nitrox.Bridge.call('Accelerometer/c/stop', {}, async);
    },
    
    getAcceleration: function() {
        var accel;
        var cached = "";
        if (this.currentAcceleration) {
            accel = this.currentAcceleration;
            cached = 'CACHED ';
        } else {
            accel = Nitrox.Bridge.call('Accelerometer/c/getAcceleration', {}, false);
        }
        Nitrox.log(cached + "acceleration is " + accel);
        return accel;
    },

    updateFrequency: function(frequency, async) {
        Nitrox.Bridge.call('Accelerometer/c/updateFrequency', {frequency: frequency}, async);
    },

    delegate: function(accel) {
        this.updateCount++;
        this.currentAcceleration = accel;
        Nitrox.log("default acceleration delegate received accel: " + Nitrox.Lang.toJSON(accel));
    },

    version: '0.1'
};

// device information

Nitrox.Device = {
    start: function(async) {
        Nitrox.Bridge.call('Device/c/startMonitoringOrientation', {}, async);
    },

    stop: function(async) {
        Nitrox.Bridge.call('Device/c/stopMonitoringOrientation', {}, async);
    },

    getDeviceAttribute: function(attrname) {
        return Nitrox.Bridge.call('Device/c/' + attrname, {}, false);
    },

    model: function() {
        return Nitrox.Device.getDeviceAttribute('model');
    },

    orientation: function() {
        return Nitrox.Device.getDeviceAttribute('orientation');
    },

    orientationDelegate: function(newOrientation, oldOrientation, type) {
        Nitrox.log("default orientation delegate: changed orientation from " + oldOrientation + 
                   " to " + newOrientation + " event type = " + type);
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
    loaded: [],
    
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
    
    require: function(jsfile, async) {
        if (jQuery.inArray(jsfile, this.loaded) != -1) {
            return true;
        }
        
        var res = Nitrox.Lang.loadJS(jsfile, async);
        if (res) {
            this.loaded.push(jsfile);
        }
        return res;
    },
    
    fromJSON: function(str) {
        if (!jQuery.toJSON) {
            Nitrox.Lang.require("lib/jquery/jquery.json.js");
        }
        return jQuery.secureEvalJSON(str);
    },
    
    toJSON: function(obj) {
        if (! jQuery.toJSON) {
            Nitrox.Lang.require("lib/jquery/jquery.json.js");
        }
        return jQuery.toJSON(obj);
    },
    
    version: '0.1'
};

/*
 * proxy functions...might be useful if UIWebView stops supporting
 * cross-domain XHR.  When did this happen?  (RDS, 2008-10-07)
 *
 */


Nitrox.Proxy = {
    savedXHR: null,
    
    globalXHR: XMLHttpRequest,
 
    // see http://developer.apple.com/internet/webcontent/xmlhttpreq.html
    //   http://ajaxpatterns.org/Ajax_Stub

    transparentAjaxEnabled: function() {
        return (XMLHttpRequest.prototype.n_originalSend ? true : false);
    },

    enableTransparentAjax: function() {
        if (XMLHttpRequest.prototype.n_originalSend) {
            return;
        }
        XMLHttpRequest.prototype.n_originalSend = XMLHttpRequest.prototype.send;
        XMLHttpRequest.prototype.send = this._proxyXHRsend;
        XMLHttpRequest.prototype.n_originalOpen = XMLHttpRequest.prototype.open;
        XMLHttpRequest.prototype.open = this._proxyXHRopen;

    },

    disableTransparentAjax: function() {
        if (! XMLHttpRequest.prototype.n_originalSend) {
            return;
        }
        XMLHttpRequest.prototype.send = XMLHttpRequest.prototype.n_originalSend;
        XMLHttpRequest.prototype.n_originalSend = null;
        XMLHttpRequest.prototype.open = XMLHttpRequest.prototype.n_originalOpen;
        XMLHttpRequest.prototype.n_originalOpen = null;
    },
    
    _proxyXHRsend: function() {
        window.nadirect.log("sending XHR request");
        var ret = this.n_originalSend.apply(this, arguments);
        window.nadirect.log("done with send");
        return ret;
    },

    /*
     *  open("method", "URL"[, asyncFlag[, "userName"[, "password"]]])
     */
    _proxyXHRopen: function() {
        window.nadirect.log("opening XHR request for " + arguments[1]);
        var args = arguments;
        var url = args[1];
        if (!url.match(new RegExp("^http(s?)://(127\.0\.0\.1|localhost)[:/]")))
        {
            var baseURL = Nitrox.Runtime.appURL();
            url = url.replace(new RegExp("^(http(s?))://"), baseURL + "/proxy/ajax/$1/");
            window.nadirect.log("new url is " + url);
        }
        args[1] = url;
        var ret = this.n_originalOpen.apply(this, args);
        window.nadirect.log("done with open");
        return ret;
    },

    ajax: function(ajaxObject) {
        Nitrox.log("proxy.ajax not yet supported");
        return "Not yet supported";
    },
    
    retrieve: function(url, callback, method) {
        if (!method) {
            method = "get";
        }

        var data = { url: url };
        url = Nitrox.Runtime.appURL() + "/proxy/retrieve";
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

Nitrox.Application = {
    delegate: null,

    _delegate: function(funname, arg) {
        if (this.delegate && this.delegate[funname]) {
            Nitrox.log("invoking method " + fun + " on Nitrox.App delegate with arg " + arg);
            this.delegate[funname](arg);
        } else {
            Nitrox.log("cannot find method " + fun + " for Nitrox.App delegate with arg " + arg);
        }
    },
    
    exit: function() {
        Nitrox.Bridge.call('Application/c/exit', {}, true);
    },

    iconBadgeNumber: function() {
        return Nitrox.Bridge.call('Application/c/applicationIconBadgeNumber', {}, true);
    },

    setIconBadgeNumber: function(number) {
        Nitrox.Bridge.call('Application/c/setApplicationIconBadgeNumber', {value: number}, true);
    },
    
    vibrate: function(async) {
        Nitrox.Bridge.call('Vibrate/c/vibrate', {}, async ? true : false);
    },
    
    openApplication: function(url) {
        Nitrox.log('in openApp, opening ' + url);
        Nitrox.Bridge.call('Application/c/openApplication', {url: url}, true);
        Nitrox.log('in openApp, DONE opening ' + url);
    },
    
    back: function() {
        Nitrox.Bridge.call('Application/c/back', {}, false);
    },

    forward: function() {
        Nitrox.Bridge.call('Application/c/forward', {}, false);
    },
    
    appConfiguration: function() {
        return Nitrox.Bridge.call('Application/c/appConfiguration', {}, false);
    },

    infoDictionary: function() {
        return Nitrox.Bridge.call('Application/c/infoDictionary', {}, false);
    },

    getInfoValue: function(name) {
        return Nitrox.Bridge.call('Application/c/getInfoValue', {name: name}, false);
    },


    bundleDirectory: function() {
        return Nitrox.Bridge.call('Application/c/bundleDirectory', {}, false);
    },

    documentsDirectory: function() {
        return Nitrox.Bridge.call('Application/c/documentsDirectory', {}, false);
    },

    tmpDirectory: function() {
        return Nitrox.Bridge.call('Application/c/tmpDirectory', {}, false);
    },

    getUserDefault: function(name) {
        return Nitrox.Bridge.call('Application/c/getUserDefault', {name: name}, false);
    },

    setUserDefault: function(name, value) {
        Nitrox.Bridge.call('Application/c/setUserDefault', {name: name, value: value}, false);
    },

    getUserDefaults: function(names) {
        return Nitrox.Bridge.call('Application/c/getUserDefaults', {names: names}, false);
    },

    setUserDefaults: function(defaults) {
        Nitrox.Bridge.call('Application/c/setUserDefaults', {defaults: defaults}, false);
    },

    version: '0.1'
};

Nitrox.Phone = {
    call: function(number) {
        Nitrox.Application.openURL('tel:' + number);
    },
    
    version: '0.1'
};



Nitrox.System = {
    delegate: null,

    _delegate: function(funname, arg) {
        if (this.delegate && this.delegate[funname]) {
            Nitrox.log("invoking method " + fun + " on Nitrox.App delegate with arg " + arg);
            this.delegate[funname](arg);
        } else {
            Nitrox.log("cannot find method " + fun + " for Nitrox.App delegate with arg " + arg);
        }
    },
    
    exit: function() {
        Nitrox.Bridge.call('System/c/exit', {}, true);
    },

    openURL: function(url) {
        Nitrox.Bridge.call('System/c/openURL', {url: url}, true);
    },
    
    vibrate: function(async) {
        Nitrox.Bridge.call('Vibrate/c/vibrate', {}, async ? true : false);
    },
    
    enableScriptDebugging: function() {
        Nitrox.Bridge.call('System/c/enableScriptDebugging', {}, false);
    },

    disableScriptDebugging: function() {
        Nitrox.Bridge.call('System/c/disableScriptDebugging', {}, true);
    },
    
    getEnv: function(name) {
        return Nitrox.Bridge.call('System/c/getEnv', {name: name}, false);
    },

    setEnv: function(name, value) {
        return Nitrox.Bridge.call('System/c/setEnv', {name: name, value: value}, false);
    },

    
    version: '0.1'
};

Nitrox.Handlers = function(owner) {
    this.listeners = [];
    this.owner = owner;
    return this;
};

Nitrox.Handlers.prototype = {
    listeners: [],
    
    owner: null,
    
    handle: function(name, args) {
        Nitrox.log("handling event " + name + " this = " + this);
        var larr = this.getListenersArray(name);
        var all = larr.concat(this.getListenersArray('*'));

        var owner = this.owner;
        jQuery.each(all, function(idx, elt) { elt.apply(owner, args); });
    },
    
    getListenersArray: function(name) {
        var larr = this.listeners[name];
        if (!larr) {
            larr = this.listeners[name] = [];
        }
        return larr;
    },
    
    _removeFromArray: function(array, object) {
        return jQuery.grep(array, function(elt, idx) { elt != object; });
    },
    
    addListener: function(name, listener) {
        Nitrox.log("adding listener to notification " + name + " this is " + this);

        var larr = this.getListenersArray(name);
        if (jQuery.inArray(listener, larr) != -1) {
            // already listening
            return false;
        }

        // record local listener
        larr.push(listener);

        return true;
    },
    
    removeListener: function(name, listener) {
        Nitrox.log("removing listener from notification " + name);
        
        var larr = this.getListenersArray(name);
        
        if (! listener) {
            larr = this.listeners[name] = [];
        } else if (jQuery.inArray(listener, larr) != -1) {
            larr = this._removeFromArray(larr, listener);
            this.listeners[name] = larr;
        } else {
            return false;
        }

        return true;
    },
};

Nitrox.Event = {
    listeners: {},
    
    delegate: null,

    _delegate: function(notification, info) {
        if (!this.delegate) {
            Nitrox.log("cannot find method " + notification + " for Nitrox.App delegate with arg " + info);
            return;
        }
    },

    _receiveNotification: function(name, userInfo) {
        Nitrox.log("received notification " + name);
        var larr = this._getListenersArray(name);
        
        jQuery.each(larr, function(idx, elt) { elt(name, userInfo); });
    },
    
    _getListenersArray: function(name) {
        var larr = this.listeners[name];
        if (!larr) {
            larr = this.listeners[name] = [];
        }
        return larr;
    },
    
    _removeFromArray: function(array, object) {
        return jQuery.grep(array, function(elt, idx) { elt != object; });
    },
    
    addNotificationListener: function(name, listener) {
        Nitrox.log("adding listener to notification " + name);

        var larr = this._getListenersArray(name);
        if (jQuery.inArray(listener, larr) != -1) {
            // already listening
            return false;
        }
        
        // first-time listener...
        // start up Objective-C listening if not already active
        if (larr.length == 0) {
            var args = {name: name};
            Nitrox.Bridge.call('Event/c/addNotificationListener', args, true);
        }

        // record local listener
        larr.push(listener);

        return true;
    },
    
    removeNotificationListener: function(name, listener) {
        Nitrox.log("removing listener from notification " + name);
        
        var larr = this._getListenersArray(name);
        
        if (! listener) {
            larr = this.listeners[name] = [];
        } else if (jQuery.inArray(listener, larr) != -1) {
            larr = this._removeFromArray(larr, listener);
            this.listeners[name] = larr;
        } else {
            return false;
        }
        
        if (larr.length == 0) {
            var args = {name: name};
            Nitrox.Bridge.call('Event/c/removeNotificationListener', args, true);
        }
        return true;
    },

    postNotification: function(name, userInfo) {
        Nitrox.log("posting notification " + name);
        if (! userInfo) {
            userInfo = {};
        }
        var args = {name: name, userInfo: Nitrox.Lang.toJSON(userInfo)};
        Nitrox.Bridge.call('Event/c/postNotification', args, true);
        return true;
    },
    
    version: '0.1'
};

// photo functions

Nitrox.Photo = {
    delegate: null,
    
    handlers: new Nitrox.Handlers(this),

    _delegate: function(funname, arg) {
        if (this.delegate && this.delegate[funname]) {
            Nitrox.log("invoking method " + fun + " on Nitrox.App delegate with arg " + arg);
            this.delegate[funname](arg);
        } else {
            Nitrox.log("cannot find method " + fun + " for Nitrox.App delegate with arg " + arg);
        }
    },
    
    showPicker: function() {
        var res = Nitrox.Bridge.call('Photo/c/showPicker', {}, true);
        Nitrox.log("NPsP: return from showpicker was " + res);
        return res;
    },

    takePhoto: function() {
        var res = Nitrox.Bridge.call('Photo/c/takePhoto', {}, true);
        Nitrox.log("NPsP: return from takePhoto was " + res);
        return res;
    },

    chooseFromLibrary: function() {
        var res = Nitrox.Bridge.call('Photo/c/chooseFromLibrary', {}, true);
        Nitrox.log("NPsP: return from chooseFromLibrary was " + res);
        return res;
    },
    
    _success: function(path, metadata) {
        var url = Nitrox.Runtime.appURL() + "/photoresults/" + path;
        Nitrox.log("NPsP: photo url is " + url + " metadata = " + Nitrox.Lang.toJSON(metadata));
        this.handlers.handle('photo_picked', [url, metadata]);
    },
    
    _cancel: function(result) {
        Nitrox.log("NPsP: result is CANCELED");
    },

    version: '0.1'
};

// file functions

Nitrox.File = function(path) {
    this._type = "Nitrox.File";
    this.path = path;
};

Nitrox.File.getcwd = function() {
    return Nitrox.Bridge.call("File/c/getcwd", {}, false);
}

Nitrox.File.chdir = function(path) {
    return Nitrox.Bridge.call("File/c/chdir", {path: path}, false);
}

Nitrox.File.prototype = {
    exists: function() {
        return this.access("f");
    },
    
    isFile: function() {
        var stat = this.stat();
        return (stat.st_mode & 0170000) == 0100000;
    },

    isDir: function() {
        var stat = this.stat();
        // Nitrox.log("st_mode = " + stat.st_mode + ", masked = " + (stat.st_mode & 0170000));
        return (stat.st_mode & 0170000) == 040000;
    },

    isSymlink: function() {
        var stat = this.stat();
        return (stat.st_mode & 0170000) == 0120000;
    },
    
    // mode is a string containing one or more of "f", "r", "w", and "x"
    // returns true / false
    access: function(mode) {
        return (Nitrox.Bridge.call("File/c/access", {path: this.path, mode: mode}, false) != -1);
    },



     // struct stat {
     //     dev_t    st_dev;    /* device inode resides on */
     //     ino_t    st_ino;    /* inode's number */
     //     mode_t   st_mode;   /* inode protection mode */
     //     nlink_t  st_nlink;  /* number or hard links to the file */
     //     uid_t    st_uid;    /* user-id of owner */
     //     gid_t    st_gid;    /* group-id of owner */
     //     dev_t    st_rdev;   /* device type, for special file inode */
     //     struct timespec st_atimespec;  /* time of last access */
     //     struct timespec st_mtimespec;  /* time of last data modification */
     //     struct timespec st_ctimespec;  /* time of last file status change */
     //     off_t    st_size;   /* file size, in bytes */
     //     quad_t   st_blocks; /* blocks allocated for file */
     //     u_long   st_blksize;/* optimal file sys I/O ops blocksize */
     //     u_long   st_flags;  /* user defined flags for file */
     //     u_long   st_gen;    /* file generation number */
     // };
     //
     // returns a json object with those field names except times are in fractional
     // unix format (e.g., seconds.partialseconds)
    stat: function() {
        return Nitrox.Bridge.call("File/c/stat", {path: this.path}, false);
    },

    chmod: function(mode) {
        return Nitrox.Bridge.call("File/c/chmod", {path: this.path, mode: mode}, false);
    },

    copy: function(path2) {
        return Nitrox.Bridge.call("File/c/copy", {path: this.path, path2: path2}, false);
    },

    link: function(path2) {
        return Nitrox.Bridge.call("File/c/link", {path: this.path, path2: path2}, false);
    },

    symlink: function(path2) {
        return Nitrox.Bridge.call("File/c/symlink", {path: this.path, path2: path2}, false);
    },
    
    unlink: function() {
        return Nitrox.Bridge.call("File/c/unlink", {path: this.path}, false);
    },

    // this is the recursive one
    deleteRecursively: function() {
        return Nitrox.Bridge.call("File/c/delete", {path: this.path}, false);
    },
    
    truncate: function(size) {
        return Nitrox.Bridge.call("File/c/truncate", {path: this.path, size: size}, false);
    },
    
    // if offset is null, read whole file
    // if size is null, read from offset to end of file
    read: function(offset, size) {
        return Nitrox.Bridge.call("File/c/read", {path: this.path, offset: offset, size: size}, false);
    },
    
    // mode can be "w" for truncate and write, "w+" for append
    // if offset is not null, "w" is the same as "seek to offset and write" w/out truncating
    write: function(data, mode, offset, async) {
        return Nitrox.Bridge.call("File/c/write", {path: this.path, data: data, mode: mode, offset: offset}, async);
    },
    
    mkdir: function(mode, recurse) {
        if (mode == undefined) { mode = 0755; }
        if (recurse == undefined) { recurse = true; }
        return Nitrox.Bridge.call("File/c/mkdir", {path: this.path, mode: mode, 'recursive': recurse}, false);
    },
    
    rmdir: function() {
        return Nitrox.Bridge.call("File/c/rmdir", {path: this.path}, false);
    },
    
    readdir: function() {
        return Nitrox.Bridge.call("File/c/readdir", {path: this.path}, false);
    },
    
    version: '0.1'
};

// final bootstrap

jQuery(function() {
    Nitrox.Runtime.pageReady();
    Nitrox.Lang.require("lib/jquery/jquery.json.js");
    Nitrox.log("Nitrox loaded");
});

