
/*
 Copyright (c) 2012, Andreas Lappe <a.lappe@kuehlhaus.com>, kuehlhaus AG
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:
 
 - Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
 - Neither the name of the kuehlhaus AG nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
@author Andreas Lappe <nd@kaeufli.ch>
*/

(function() {
  var namespace,
    __slice = Array.prototype.slice,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  namespace = function(target, name, block) {
    var item, top, _i, _len, _ref, _ref2;
    if (arguments.length < 3) {
      _ref = [(typeof exports !== 'undefined' ? exports : window)].concat(__slice.call(arguments)), target = _ref[0], name = _ref[1], block = _ref[2];
    }
    top = target;
    _ref2 = name.split('.');
    for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
      item = _ref2[_i];
      target = target[item] || (target[item] = {});
    }
    return block(target, top);
  };

  namespace('References.Model', function(exports) {
    return exports.Reference = (function(_super) {

      __extends(Reference, _super);

      function Reference() {
        this.addFramework = __bind(this.addFramework, this);
        Reference.__super__.constructor.apply(this, arguments);
      }

      Reference.prototype.idAttribute = '_id';

      Reference.prototype.initialize = function() {
        return console.log('model init');
      };

      Reference.prototype.persist = function() {
        var _this = this;
        return this.save(this.toJSON(), {
          success: function(model, response) {
            return _this.set({
              _rev: response.rev,
              silent: true
            });
          }
        });
      };

      Reference.prototype.addFramework = function(framework) {
        var frameworks, index, knownFramework, updated, _len;
        frameworks = this.get('frameworks');
        if (framework != null) {
          updated = false;
          for (index = 0, _len = frameworks.length; index < _len; index++) {
            knownFramework = frameworks[index];
            if ((knownFramework.name === '') && (knownFramework.url === '')) {
              frameworks.splice(index, 1);
            } else if (knownFramework.name !== '' && ((knownFramework.name === framework.name) || (knownFramework.url === framework.url))) {
              frameworks[index] = {
                name: framework.name,
                url: framework.url
              };
              updated = true;
            }
          }
          if (!updated) frameworks.push(framework);
        } else {
          frameworks.push({
            name: '',
            url: ''
          });
        }
        return this.set({
          frameworks: frameworks,
          silent: true
        });
      };

      Reference.prototype.getThumbnails = function() {
        var images, name;
        console.log('getting thumbnails');
        images = [];
        for (name in this.get('_attachments')) {
          if (name.match(/^thumb-/)) {
            images.push({
              name: "" + name,
              address: "/references/" + (this.get('slug')) + "/images/" + name
            });
          }
        }
        return images;
      };

      Reference.prototype.deleteImage = function(id) {
        var images, name;
        console.log('deleting ' + id);
        images = this.get('_attachments');
        for (name in this.get('_attachments')) {
          if ((name === id) || (name === ("thumb-" + id))) delete images[name];
        }
        this.set('_attachments', images);
        return this.persist();
      };

      Reference.prototype.addImages = function(files) {
        var file;
        if (files.item != null) {
          console.log('converting to array');
          files = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = files.length; _i < _len; _i++) {
              file = files[_i];
              console.log(file.name);
              _results.push(file);
            }
            return _results;
          })();
        }
        if (files.length > 0) {
          file = files.pop();
          return this.sendImage(file, files);
        }
      };

      Reference.prototype.sendImage = function(image, images) {
        var reader,
          _this = this;
        console.log(image);
        reader = new FileReader();
        reader.onloadstart = function() {
          return console.log('onloadstart');
        };
        reader.onprogress = function() {
          return console.log('onprogress');
        };
        reader.onload = function(event) {
          console.log('POSTing image…');
          return jQuery.ajax({
            url: "/references/admin/" + (_this.get('slug')) + "/images",
            type: 'POST',
            contentType: image.type,
            data: event.target.result,
            processData: false,
            success: function(response, status) {
              console.log('POSTed…');
              _this.addImages(images);
              return _this.fetch();
            },
            error: function(a, b, c) {
              console.log(a);
              console.log(b);
              return console.log(c);
            }
          });
        };
        reader.onabort = function() {
          return console.log('onabort');
        };
        reader.onerror = function(event) {
          console.log('onerror');
          return console.log(event.target.error.code);
        };
        reader.onloadend = function() {
          return console.log('onloadend');
        };
        reader.readAsArrayBuffer(image);
        return null;
      };

      return Reference;

    })(Backbone.Model);
  });

  namespace('References.View', function(exports) {
    return exports.Reference = (function(_super) {

      __extends(Reference, _super);

      function Reference() {
        this.render = __bind(this.render, this);
        this.renderFrameworks = __bind(this.renderFrameworks, this);
        Reference.__super__.constructor.apply(this, arguments);
      }

      Reference.prototype.events = {
        'change': 'save',
        'click .icon-plus': 'addEntry',
        'click .icon-minus': 'removeEntry',
        'click li.image img': 'deleteImage',
        'drop .imageDrop': 'addImages',
        'dragover .imageDrop': 'addHoverClass',
        'dragleave .imageDrop': 'removeHoverClass'
      };

      Reference.prototype.tagName = 'article';

      Reference.prototype.className = 'reference';

      Reference.prototype.initialize = function() {
        this.template = _.template(top.References.Templates.Reference);
        this.model.bind('change', this.render);
        this.model.bind('change:frameworks', this.renderFrameworks);
        return jQuery.event.props.push('dataTransfer');
      };

      Reference.prototype.renderFrameworks = function() {
        console.log('fraaaaame');
        return this;
      };

      Reference.prototype.render = function() {
        var toFadeIn;
        console.log('render!');
        (jQuery(this.el)).html(this.template(this.model.toJSON()));
        (jQuery('#container')).append(this.el);
        toFadeIn = jQuery('.fade', this.el);
        toFadeIn.animate({
          opacity: 1
        }, 900, 'linear', function() {
          return toFadeIn.removeClass('fade');
        });
        return this;
      };

      Reference.prototype.save = function(event) {
        var body, changedElement, entryName, entryNumber, entryURL, name, slug, value;
        changedElement = jQuery(event.srcElement);
        name = changedElement.attr('name');
        value = changedElement.val();
        console.log(name);
        console.log(value);
        switch (name) {
          case 'name':
            slug = (value.replace(/[^a-z0-9\-\.]/gi, '-')).toLowerCase();
            this.model.set('slug', slug);
            this.model.set('name', value);
            break;
          case 'body.short':
            body = this.model.get('body');
            body.short = value;
            this.model.set('body', body);
            break;
          case 'body.long':
            body = this.model.get('body');
            body.long = value;
            this.model.set('body', body);
            break;
          case 'tags':
            this.model.set('tags', this.parseTags(value));
            break;
          case 'imageDrop':
            return null;
          default:
            if ((name.match(/frameworks\[/)) != null) {
              console.log('fiddling with frameworks!');
              entryNumber = name.replace(/frameworks\[(\d+)\].*/, '$1');
              entryName = (jQuery("input[name='frameworks[" + entryNumber + "][name]']", this.el)).val();
              entryURL = (jQuery("input[name='frameworks[" + entryNumber + "][url]']", this.el)).val();
              console.log("it is all about {name:" + entryName + ",url:" + entryURL + "}");
              this.model.addFramework({
                name: entryName,
                url: entryURL
              });
            } else {
              this.model.set(name, value);
            }
        }
        return this.model.persist();
      };

      Reference.prototype.addEntry = function(event) {
        var clickedElement;
        event.preventDefault();
        clickedElement = jQuery(event.srcElement);
        if (clickedElement.hasClass('framework')) this.model.addFramework();
        return false;
      };

      Reference.prototype.removeEntry = function(event, b, c) {
        event.stopPropagation();
        event.preventDefault();
        console.log('remove');
        console.log(event);
        console.log(b);
        return console.log(c);
      };

      Reference.prototype.parseTags = function(tagString) {
        var preliminary, tag, tags;
        if (tagString === '' || tagString.match(/^\s+$/)) {
          return [];
        } else {
          preliminary = tagString.split(',');
          tags = (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = preliminary.length; _i < _len; _i++) {
              tag = preliminary[_i];
              tag = tag.replace(/^\s+/, '');
              tag = tag.replace(/\s+$/, '');
              _results.push(tag.replace(/[^a-z0-9\.\-]/gi, '-'));
            }
            return _results;
          })();
          return _.uniq(tags);
        }
      };

      Reference.prototype.addImages = function(dropEvent) {
        var files;
        dropEvent.stopPropagation();
        dropEvent.preventDefault();
        files = dropEvent.dataTransfer.files;
        if (files.length > 0) return this.model.addImages(files);
      };

      Reference.prototype.deleteImage = function(image) {
        var imageId;
        imageId = (jQuery(image.srcElement)).attr('data:id');
        imageId = imageId.replace(/^thumb-/, '');
        return this.model.deleteImage(imageId);
      };

      Reference.prototype.addHoverClass = function(event) {
        return (jQuery(event.currentTarget)).addClass('hover');
      };

      Reference.prototype.removeHoverClass = function(event) {
        if ((jQuery(event.srcElement)).hasClass('dropText')) {
          return (jQuery(event.currentTarget)).removeClass('hover');
        }
      };

      return Reference;

    })(Backbone.View);
  });

  namespace('References.Templates', function(exports) {
    return exports.Reference = "<form action=\"#\" method=\"post\" enctype=\"multipart/form-data\" class=\"form references reference-new\">\n  <fieldset>\n    <legend>Basics</legend>\n    <input type=\"hidden\" name=\"<%= id %>\" />\n    <label>\n      <span>Published</span>\n      <input type=\"checkbox\" <%= (published) ? 'checked=\"checked\"' : '' %> name=\"published\" />\n    </label>\n    <label>\n      <span>Title</span>\n      <input type=\"text\" name=\"name\" value=\"<%= name %>\"/>\n    </label>\n    <label>\n      <span>Slug</span>\n      <input type=\"text\" name=\"slug\" readonly=\"readonly\" value=\"<%= slug %>\"/>\n    </label>\n    <label>\n      <span>Start</span>\n      <input type=\"date\" name=\"start\" value=\"<%= start %>\" />\n    </label>\n    <label>\n      <span>End</span>\n      <input type=\"date\" name=\"end\" value=\"<%= end %>\" />\n    </label>\n    <label>\n      <span>Company</span>\n      <input type=\"text\" name=\"company\" value=\"<%= company %>\" />\n    </label>\n  </fieldset>\n  <fieldset>\n  	<legend>Short</legend>\n    <textarea id=\"short\" name=\"body.short\" rows=\"10\" cols=\"30\"><%= body.short %></textarea>\n  </fieldset>\n  <fieldset>\n    <legend>Long</legend>\n    <textarea id=\"long\" name=\"body.long\" rows=\"10\" cols=\"30\"><%= body.long %></textarea>\n  </fieldset>\n  <fieldset>\n    <legend>Frameworks</legend>\n    <ul class=\"frameworks\">\n      <% _.each(frameworks, function(framework, i) { %>\n        <li class=\"framework <%= (i === 0) ? 'first' : '' %><%= (framework.name === '') ? 'fade' : '' %>\">\n          <a href=\"#\" class=\"icon icon-minus\">\n            <span>-</span>\n          </a>\n          <label class=\"first\">\n            <span>Name</span>\n            <input type=\"text\" name=\"frameworks[<%= i %>][name]\" value=\"<%= framework.name %>\" />\n          </label>\n          <label>\n            <span>URL</span>\n            <input type=\"text\" name=\"frameworks[<%= i %>][url]\" value=\"<%= framework.url %>\" />\n          </label>\n        </li>\n      <% }); %>\n    </ul>\n    <a href=\"#\" class=\"icon icon-plus framework\">\n      <span>+</span>\n    </a>\n  </fieldset>\n  <fieldset>\n    <legend>Images</legend>\n    <div class=\"imageDrop\">\n      <p class=\"dropText\">Drop images here…</p>\n      <ul class=\"images\">\n        <% _.each(this.model.getThumbnails(), function(thumbnail) { %>\n          <li class=\"image\">\n            <img src=\"<%= thumbnail.address %>\" alt=\"Thumbnail of Image <%= thumbnail.name %>\" data:id=\"<%= thumbnail.name %>\"  width=\"60px\" />\n          </li>\n        <% }); %>\n      </ul>\n    </div>\n  </fieldset>\n  <fieldset>\n    <legend>Tags</legend>\n    <% var tagList = tags.join(', '); %>\n    <textarea id=\"tags\" name=\"tags\" rows=\"10\" cols=\"30\"><%= tagList %></textarea>\n  </fieldset>\n</form>";
  });

  namespace('References.Router', function(exports) {
    return exports.App = (function(_super) {

      __extends(App, _super);

      function App() {
        App.__super__.constructor.apply(this, arguments);
      }

      App.prototype.routes = {
        '': 'indexAction'
      };

      App.prototype.initialize = function() {
        return console.log('router init');
      };

      App.prototype.indexAction = function() {
        var reference,
          _this = this;
        reference = new top.References.Model.Reference();
        reference.url = top.window.location.href;
        return reference.fetch({
          success: function(model, response) {
            return _this.showAction(model);
          }
        });
      };

      App.prototype.showAction = function(model) {
        var referenceView;
        referenceView = new top.References.View.Reference({
          model: model
        });
        return referenceView.render();
      };

      return App;

    })(Backbone.Router);
  });

  (jQuery('document')).ready(function() {
    window.references = new window.References.Router.App();
    return Backbone.history.start();
  });

}).call(this);
