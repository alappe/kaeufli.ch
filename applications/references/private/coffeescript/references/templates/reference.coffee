namespace 'References.Templates', (exports) ->
  exports.Reference = """
  <form action="#" method="post" enctype="multipart/form-data" class="form references reference-new">
    <fieldset>
      <legend>Basics</legend>
      <input type="hidden" name="<%= id %>" />
      <label>
        <span>Published</span>
        <input type="checkbox" <%= (published) ? 'checked="checked"' : '' %> name="published" />
      </label>
      <label>
        <span>Title</span>
        <input type="text" name="name" value="<%= name %>"/>
      </label>
      <label>
        <span>Slug</span>
        <input type="text" name="slug" readonly="readonly" value="<%= slug %>"/>
      </label>
      <label>
        <span>Start</span>
        <input type="date" name="start" value="<%= start %>" />
      </label>
      <label>
        <span>End</span>
        <input type="date" name="end" value="<%= end %>" />
      </label>
      <label>
        <span>Company</span>
        <input type="text" name="company" value="<%= company %>" />
      </label>
    </fieldset>
    <fieldset>
    	<legend>Short</legend>
      <textarea id="short" name="body.short" rows="10" cols="30"><%= body.short %></textarea>
    </fieldset>
    <fieldset>
      <legend>Long</legend>
      <textarea id="long" name="body.long" rows="10" cols="30"><%= body.long %></textarea>
    </fieldset>
    <fieldset>
      <legend>Frameworks</legend>
      <ul class="frameworks">
        <% _.each(frameworks, function(framework, i) { %>
          <li class="framework <%= (i === 0) ? 'first' : '' %><%= (framework.name === '') ? 'fade' : '' %>">
            <a href="#" class="icon icon-minus">
              <span>-</span>
            </a>
            <label class="first">
              <span>Name</span>
              <input type="text" name="frameworks[<%= i %>][name]" value="<%= framework.name %>" />
            </label>
            <label>
              <span>URL</span>
              <input type="text" name="frameworks[<%= i %>][url]" value="<%= framework.url %>" />
            </label>
          </li>
        <% }); %>
      </ul>
      <a href="#" class="icon icon-plus framework">
        <span>+</span>
      </a>
    </fieldset>
    <fieldset>
      <legend>Images</legend>
      <div class="imageDrop">
        <p class="dropText">Drop images here…</p>
        <ul class="images">
          <% _.each(this.model.getThumbnails(), function(thumbnail) { %>
            <li class="image">
              <img src="<%= thumbnail.address %>" alt="Thumbnail of Image <%= thumbnail.name %>" data:id="<%= thumbnail.name %>"  width="60px" />
            </li>
          <% }); %>
        </ul>
      </div>
    </fieldset>
    <fieldset>
      <legend>Tags</legend>
      <% var tagList = tags.join(', '); %>
      <textarea id="tags" name="tags" rows="10" cols="30"><%= tagList %></textarea>
    </fieldset>
  </form>
  """
