(function($) {

  /* MODELS MODELS MODELS */
  var Quote = Backbone.Model.extend({
    defaults: {
      "source": "",
      "context": "",
      "quote": "",
      "theme": ""
    }
  });

  var Quotes = Backbone.PageableCollection.extend({
    model: Quote,
    mode: "client",
    url: 'https://gist.githubusercontent.com/anonymous/8f61a8733ed7fa41c4ea/raw/1e90fd2741bb6310582e3822f59927eb535f6c73/quotes.json',
    state: {
      pageSize: 15,
    },

    filterModel: function(attributes){
      var paredResultsArr = this.fullCollection.where(attributes);
      return new Quotes(paredResultsArr);
    }
  });

  var PageLink = Backbone.Model.extend({
    defaults: {
      "pageNum": "",
    }
  });

  /* VIEWS VIEWS VIEWS */
  var QuoteView = Backbone.View.extend({
    tagName: "table",
    className: "quote-container",
    template: $("#quoteTemplate").html(),

    render: function(){
      var temp = _.template(this.template);
      $(this.el).html(temp(this.model.toJSON()));
      return this;
    },
  });

  var FilterOptionsView = Backbone.View.extend({
    tagName: "div",
    className: "filterOptions-container",
    template: $("#filterTemplate").html(),

    render: function(){
      var temp = _.template(this.template);
      $(this.el).html(temp);
      return this;
    }
  });

  var PageView = Backbone.View.extend({
    tagName: "div",
    className: "links-container",
    template: $("#pageTemplate").html(),

    render: function(){
      var temp = _.template(this.template);
      $(this.el).html(temp(this.model.toJSON()));
      return this;
    }
  });

  var QuotesView = Backbone.View.extend({
    el: $("#quotes"),
    events: {
      "click #pageNumber": function(){ this.renderPage(event) },
      "click #allQuotes":  function(){ this.resetToAllQuotes() },
      "click #gameQuotes": function(){ this.filterView("games") },
      "click #movieQuotes": function(){ this.filterView("movies") },
    },

    render: function(){
      var display = this;
      display.clearBinding();
      display.renderfilterOptions();
      display.renderPageLinks();
      this.currentView = _.each(this.collection.models, function(quote){
        display.renderQuote(quote);
      }, this);
    },

    clearBinding: function(){
      if(this.currentView){
        $(this.el).empty();
      }
    },

    renderQuote: function(quote){
      var quoteView = new QuoteView({ model: quote });
      this.$el.append(quoteView.render().el);
    },

    renderfilterOptions: function(){
      var filterOptions = new FilterOptionsView()
      this.$el.append(filterOptions.render().el)
    },

    renderPageLinks: function(){
      for(num = 1; num <= this.collection.state.totalPages; num++){
        var linkNum = new PageLink({pageNum: num})
        var link = new PageView({ model: linkNum })
        this.$el.append(link.render().el)
      }
    },

    findNumPages: function(){
      for(num = 1; num <= this.collection.state.totalPages; num++){
        var linkNum = new PageLink({pageNum: num})
      }
    },

    filterView: function(filterQuery){
      showCollection = allQuotesCollection.filterModel({theme: filterQuery});
      this.collection = showCollection;
      this.render();
    },

    resetToAllQuotes: function(){
      this.collection = allQuotesCollection;
      this.render();
    },

    renderPage: function(event){
      var numString = $(event.target).attr("data-id");
      var pageNum = parseInt(numString);
      collectionPage = showCollection.getPage(pageNum);
      this.collection = collectionPage;
      this.render();
    }
  });

  var showCollection;
  var allQuotesCollection = new Quotes();
  var allQuotesDisplay = new QuotesView({
    collection: allQuotesCollection
  });

  allQuotesCollection.fetch({
    success: function(){
      showCollection = allQuotesCollection;
      allQuotesDisplay.render();
    }
  });

}(jQuery));
