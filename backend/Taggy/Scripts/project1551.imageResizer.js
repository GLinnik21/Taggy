(function(prj1551) {
    prj1551.imageResizer = prj1551.imageResizer || {};

    prj1551.imageResizer.resize = resizeLocal;
    prj1551.imageResizer.upload = uploadLocal;
    prj1551.imageResizer.asyncLoad = asyncLoadLocal;

    /*************************************
    Start public methods implementations.
    *************************************/

    function resizeLocal(options) {
        var settings = extend({
            file: '',
            maxSize: 512,
            maxWidth: 100,
            maxHeight: 100,
            quality: 100,
            complete: function() {
            }
        }, options);

        (function() {
            var reader = new FileReader();
            reader.onloadend = function(e) {
                var dataUrl = e.target.result;
                var byteString = atob(dataUrl.split(',')[1]);
                var binaryFile = new BinaryFile(byteString, 0, byteString.length);
                var exif = EXIF.readFromBinaryFile(binaryFile);
                var iframe = (function() {
                    var iframeId = "tmpFrame";
                    var tmpIframe = document.createElement("iframe");
                    tmpIframe.setAttribute("id", iframeId);
                    tmpIframe.setAttribute("name", iframeId);
                    tmpIframe.setAttribute("width", "0");
                    tmpIframe.setAttribute("height", "0");
                    tmpIframe.setAttribute("border", "0");
                    tmpIframe.setAttribute("style", "width: 0; height: 0; border: none;");

                    document.body.appendChild(tmpIframe);
                    window.frames[iframeId].name = iframeId;

                    return tmpIframe;
                })();

                var image = new Image();
                image.onload = function() {
                    var result = processImage(image, exif['Orientation']);
                    validateCallback(settings.complete).call(this, { image: image, canvas: result.canvas, data: result.data, blob: result.blob });
                    document.body.removeChild(iframe); /* IE10 issue workaround. */
                };

                image.src = dataUrl.replace('data:base64', 'data:image/jpeg;base64'); /* Android issue workaround. */
                iframe.appendChild(image); /* IE10 issue workaround. */
            };

            reader.readAsDataURL(settings.file);
        })();

        function processImage(image, orientation) {
            var resizeResult = resize(image, orientation);
            var blob = dataUriToBlob(resizeResult.data);
            if (settings.maxSize && settings.maxSize < blob.size / 1024) {
                settings.maxWidth *= 0.75;
                settings.maxHeight *= 0.75;
                return processImage(image, orientation);
            }

            return { data: resizeResult.data, canvas: resizeResult.canvas, blob: blob };
        }

        function resize(image, orientation) {
            var size = (orientation >= 5 && orientation <= 8) ? getNewSize(image.height, image.width) : getNewSize(image.width, image.height);
            var currentWidth = image.width;
            var currentHeight = image.height;
            var requiredWidth = size.width;
            var requiredHeight = size.height;
            var canvas = document.createElement("canvas");
            var context = canvas.getContext("2d");
            context.save();

            transformCoordinate(canvas, requiredWidth, requiredHeight, orientation);

            if (detectSubsampling(image)) {
                currentWidth /= 2;
                currentHeight /= 2;
            }

            var dimension = 1024;
            var tmpCanvas = document.createElement('canvas');
            tmpCanvas.width = tmpCanvas.height = dimension;
            var tmpContext = tmpCanvas.getContext('2d');
            var vertSquashRatio = detectVerticalSquash(image, currentWidth, currentHeight);

            var sy = 0;
            while (sy < currentHeight) {
                var sh = sy + dimension > currentHeight ? currentHeight - sy : dimension;
                var sx = 0;
                while (sx < currentWidth) {
                    var sw = sx + dimension > currentWidth ? currentWidth - sx : dimension;
                    tmpContext.clearRect(0, 0, dimension, dimension);
                    tmpContext.drawImage(image, -sx, -sy);
                    var dx = Math.floor(sx * requiredWidth / currentWidth);
                    var dw = Math.ceil(sw * requiredWidth / currentWidth);
                    var dy = Math.floor(sy * requiredHeight / currentHeight / vertSquashRatio);
                    var dh = Math.ceil(sh * requiredHeight / currentHeight / vertSquashRatio);
                    context.drawImage(tmpCanvas, 0, 0, sw, sh, dx, dy, dw, dh);
                    sx += dimension;
                }

                sy += dimension;
            }

            context.restore();
            tmpCanvas = tmpContext = null;

            var newCanvas = document.createElement('canvas');
            newCanvas.width = requiredWidth;
            newCanvas.height = requiredHeight;

            var newContext = newCanvas.getContext('2d');
            newContext.drawImage(canvas, 0, 0, requiredWidth, requiredHeight);
            var data = newCanvas.toDataURL("image/jpeg", (settings.quality * .01));

            return { data: data, canvas: newCanvas };
        }

        function getNewSize(width, height) {
            if ((settings.maxWidth && width > settings.maxWidth) || (settings.maxHeight && height > settings.maxHeight)) {
                var ratio = width / height;
                if ((ratio >= 1 || settings.maxHeight == 0) && settings.maxWidth && !settings.crop) {
                    width = settings.maxWidth;
                    height = (settings.maxWidth / ratio) >> 0;
                } else if (settings.crop && ratio <= (settings.maxWidth / settings.maxHeight)) {
                    width = settings.maxWidth;
                    height = (settings.maxWidth / ratio) >> 0;
                } else {
                    width = (settings.maxHeight * ratio) >> 0;
                    height = settings.maxHeight;
                }
            }

            return { width: width, height: height };
        }

        function detectSubsampling(image) {
            var width = image.width;
            var height = image.height;
            if (width * height > 1024 * 1024) {
                var canvas = document.createElement('canvas');
                canvas.width = canvas.height = 1;
                var ctx = canvas.getContext('2d');
                ctx.drawImage(image, -width + 1, 0);
                return ctx.getImageData(0, 0, 1, 1).data[3] === 0;
            } else {
                return false;
            }
        }

        function detectVerticalSquash(image, width, height) {
            var canvas = document.createElement('canvas');
            canvas.width = 1;
            canvas.height = height;
            var ctx = canvas.getContext('2d');
            ctx.drawImage(image, 0, 0);
            var data = ctx.getImageData(0, 0, 1, height).data;
            var sy = 0;
            var ey = height;
            var py = height;
            while (py > sy) {
                var alpha = data[(py - 1) * 4 + 3];
                if (alpha === 0) {
                    ey = py;
                } else {
                    sy = py;
                }

                py = (ey + sy) >> 1;
            }

            return py / height;
        }

        function transformCoordinate(canvas, width, height, orientation) {
            switch (orientation) {
            case 5:
            case 6:
            case 7:
            case 8:
                canvas.width = height;
                canvas.height = width;
                break;
            default:
                canvas.width = width;
                canvas.height = height;
            }
            var ctx = canvas.getContext('2d');
            switch (orientation) {
            case 2:
                // horizontal.
                ctx.translate(width, 0);
                ctx.scale(-1, 1);
                break;
            case 3:
                // 180 rotate left.
                ctx.translate(width, height);
                ctx.rotate(Math.PI);
                break;
            case 4:
                // vertical.
                ctx.translate(0, height);
                ctx.scale(1, -1);
                break;
            case 5:
                // vertical + 90 rotate right.
                ctx.rotate(0.5 * Math.PI);
                ctx.scale(1, -1);
                break;
            case 6:
                // 90 rotate right.
                ctx.rotate(0.5 * Math.PI);
                ctx.translate(0, -height);
                break;
            case 7:
                // horizontal + 90 rotate right.
                ctx.rotate(0.5 * Math.PI);
                ctx.translate(width, -height);
                ctx.scale(-1, 1);
                break;
            case 8:
                // 90 rotate left.
                ctx.rotate(-0.5 * Math.PI);
                ctx.translate(-width, 0);
                break;
            default:
                break;
            }
        }
    }

    function uploadLocal(options) {
        var settings = extend({
            url: '',
            data: {},
            formDataName: 'file',
            type: 'POST',
            percentIndicator: '',
            progressIndicator: '',
            success: function() {
            },
            error: function() {
            },
            complete: function() {
            }
        }, options);

        (function() {
            /* 
            // Firefox doesn't work with blob and FormData.
            // This method works with blob not with data string.
            var xhr = new XMLHttpRequest();
            xhr.open(settings.type, settings.url, true);
            xhr.upload.addEventListener("progress", uploadProgress, false);
            xhr.addEventListener("load", success, false);
            xhr.addEventListener("error", error, false);

            var formData = new FormData();
            formData.append(settings.formDataName, settings.data);

            if (xhr.sendAsBinary) {
            xhr.sendAsBinary(formData);
            } else {
            xhr.send(formData);
            } */

            var xhr = new XMLHttpRequest();
            xhr.open(settings.type, settings.url, true);
            xhr.upload.addEventListener("progress", uploadProgress, false);
            xhr.addEventListener("load", success, false);
            xhr.addEventListener("error", error, false);

            var data = settings.data.replace('data:' + settings.mimeType + ';base64,', '');
            data = data.replace('data:image/png;base64,', ''); /* Android issue workaround. */

            if (XMLHttpRequest.prototype.sendAsBinary === undefined) {
                XMLHttpRequest.prototype.sendAsBinary = function(string) {
                    var bytes = Array.prototype.map.call(string, function(c) { return c.charCodeAt(0) & 0xff; });
                    this.send(new Uint8Array(bytes).buffer);
                };
            }

            var boundary = 'boundary';
            xhr.setRequestHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
            xhr.sendAsBinary([
                '--' + boundary,
                'Content-Disposition: form-data;'
                    + 'name="' + settings.formDataName + '"; '
                    + 'filename="' + settings.fileName + '" ',
                'Content-Type: multipart/form-data',
                '',
                atob(data),
                '--' + boundary + '--'
            ].join('\r\n') + '\r\n');
        })();

        function uploadProgress(event) {
            var percentIndicator = document.querySelector(settings.percentIndicator) || document.createElement("div");
            var progressIndicator = document.querySelector(settings.progressIndicator) || document.createElement("div");
            if (event.lengthComputable) {
                var percentComplete = Math.round(event.loaded * 100 / event.total);
                var percent = percentComplete.toString() + '%';
                percentIndicator.innerHTML = percent;
                progressIndicator.style.width = percent;
            } else {
                percentIndicator.innerHTML = '';
            }
        }

        function success(event) {
            validateCallback(settings.success).call(this, event);
        }

        function error(event) {
            validateCallback(settings.error).call(this, event);
        }
    }

    function asyncLoadLocal(options) {
        var settings = (function(obj, data) {
            for (var p in data) {
                obj[p] = data[p];
            }

            return obj;
        })({}, options);

        var src = settings.src;
        settings.src = 'data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==';

        return $('<img />', settings).on('load', function() { $(this).unbind('load').attr('src', src); });
    }

    /*************************************
    End public methods implementations.
    *************************************/

    /*************************************
    Start helpers.
    *************************************/

    function extend(obj, data) {
        for (var p in data) {
            obj[p] = data[p];
        }

        return obj;
    }

    function validateCallback(callback) {
        return !isNullOrEmpty(callback) && (typeof(callback) == "function")
            ? callback
            : function(data) { return data; };
    }

    function isNullOrEmpty(obj) { return (obj === '' || obj === null || obj === undefined); }

    function dataUriToBlob(data) {
        var mimeType = data.split(',')[0].split(':')[1].split(';')[0];
        var byteString = atob(data.split(',')[1]);
        var arrayBuffer = new ArrayBuffer(byteString.length);
        var uintArray = new Uint8Array(arrayBuffer);
        for (var i = 0; i < byteString.length; i++) {
            uintArray[i] = byteString.charCodeAt(i);
        }

        var blobBuilder = (window.BlobBuilder || window.WebKitBlobBuilder || window.MozBlobBuilder);
        if (blobBuilder) {
            blobBuilder = new (window.BlobBuilder || window.WebKitBlobBuilder || window.MozBlobBuilder)();
            blobBuilder.append(arrayBuffer);
            return blobBuilder.getBlob(mimeType);
        } else {
            blobBuilder = new Blob([arrayBuffer], { 'type': mimeType });
            return blobBuilder;
        }
    }

    /*************************************
    End helpers.
    *************************************/
})(window.prj1551 = window.prj1551 || {});




/*************************************
High quality processing.
*************************************/
/*
//returns a function that calculates lanczos weight
function lanczosCreate(lobes){
  return function(x){
    if (x > lobes) 
      return 0;
    x *= Math.PI;
    if (Math.abs(x) < 1e-16) 
      return 1
    var xx = x / lobes;
    return Math.sin(x) * Math.sin(xx) / x / xx;
  }
}

//elem: canvas element, img: image element, sx: scaled width, lobes: kernel radius
function thumbnailer(elem, img, sx, lobes){ 
    this.canvas = elem;
    elem.width = img.width;
    elem.height = img.height;
    elem.style.display = "none";
    this.ctx = elem.getContext("2d");
    this.ctx.drawImage(img, 0, 0);
    this.img = img;
    this.src = this.ctx.getImageData(0, 0, img.width, img.height);
    this.dest = {
        width: sx,
        height: Math.round(img.height * sx / img.width),
    };
    this.dest.data = new Array(this.dest.width * this.dest.height * 3);
    this.lanczos = lanczosCreate(lobes);
    this.ratio = img.width / sx;
    this.rcp_ratio = 2 / this.ratio;
    this.range2 = Math.ceil(this.ratio * lobes / 2);
    this.cacheLanc = {};
    this.center = {};
    this.icenter = {};
    setTimeout(this.process1, 0, this, 0);
}

thumbnailer.prototype.process1 = function(self, u){
    self.center.x = (u + 0.5) * self.ratio;
    self.icenter.x = Math.floor(self.center.x);
    for (var v = 0; v < self.dest.height; v++) {
        self.center.y = (v + 0.5) * self.ratio;
        self.icenter.y = Math.floor(self.center.y);
        var a, r, g, b;
        a = r = g = b = 0;
        for (var i = self.icenter.x - self.range2; i <= self.icenter.x + self.range2; i++) {
            if (i < 0 || i >= self.src.width) 
                continue;
            var f_x = Math.floor(1000 * Math.abs(i - self.center.x));
            if (!self.cacheLanc[f_x]) 
                self.cacheLanc[f_x] = {};
            for (var j = self.icenter.y - self.range2; j <= self.icenter.y + self.range2; j++) {
                if (j < 0 || j >= self.src.height) 
                    continue;
                var f_y = Math.floor(1000 * Math.abs(j - self.center.y));
                if (self.cacheLanc[f_x][f_y] == undefined) 
                    self.cacheLanc[f_x][f_y] = self.lanczos(Math.sqrt(Math.pow(f_x * self.rcp_ratio, 2) + Math.pow(f_y * self.rcp_ratio, 2)) / 1000);
                weight = self.cacheLanc[f_x][f_y];
                if (weight > 0) {
                    var idx = (j * self.src.width + i) * 4;
                    a += weight;
                    r += weight * self.src.data[idx];
                    g += weight * self.src.data[idx + 1];
                    b += weight * self.src.data[idx + 2];
                }
            }
        }
        var idx = (v * self.dest.width + u) * 3;
        self.dest.data[idx] = r / a;
        self.dest.data[idx + 1] = g / a;
        self.dest.data[idx + 2] = b / a;
    }

    if (++u < self.dest.width) 
        setTimeout(self.process1, 0, self, u);
    else 
        setTimeout(self.process2, 0, self);
};
thumbnailer.prototype.process2 = function(self){
    self.canvas.width = self.dest.width;
    self.canvas.height = self.dest.height;
    self.ctx.drawImage(self.img, 0, 0);
    self.src = self.ctx.getImageData(0, 0, self.dest.width, self.dest.height);
    var idx, idx2;
    for (var i = 0; i < self.dest.width; i++) {
        for (var j = 0; j < self.dest.height; j++) {
            idx = (j * self.dest.width + i) * 3;
            idx2 = (j * self.dest.width + i) * 4;
            self.src.data[idx2] = self.dest.data[idx];
            self.src.data[idx2 + 1] = self.dest.data[idx + 1];
            self.src.data[idx2 + 2] = self.dest.data[idx + 2];
        }
    }
    self.ctx.putImageData(self.src, 0, 0);
    self.canvas.style.display = "block";
}*/