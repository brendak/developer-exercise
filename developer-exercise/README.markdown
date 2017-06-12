Please fork the repository and complete all of the following exercises.
When you are finished, submit a pull request for review.

If you have any questions, feel free to email developers@benchprep.com

## JavaScript/CoffeeScript

### Simple Backbone.js List

In `quotes.html` you will need to build a simple [Backbone.js](http://backbonejs.org/) view to list the given quotes. Please do not use any libraries or plugins to do this other than [jQuery](https://jquery.com/), [Backbone.js](http://backbonejs.org/), and [underscore.js](http://underscorejs.org/).

Please provide the following functionality:

 * Required: Fetch quotes from the source [quotes.json](https://gist.githubusercontent.com/anonymous/8f61a8733ed7fa41c4ea/raw/1e90fd2741bb6310582e3822f59927eb535f6c73/quotes.json) and display the available information in a list-like structure (table/list)
 * Required: Provide client-side pagination (up to 15 quotes per page)
 * Optional: Provide a way to filter between game and movie quotes
 * Optional: Provide a client-side search that filters by the quote text

Please use your discretion in implementing the optional, nice-to-have features (if interested).

## Ruby

### Array extension

Please write a module that gives `where` behavior to an array of hashes. (See `test.rb` and make it pass, or feel free to convert the tests to your favorite test framework.)

### Simplified Blackjack

`blackjack.rb` contains initial work on a Blackjack simulation.

Your implementation should satisfy the following use cases and Blackjack rules:

 * As a Player I can get a hand with two cards in it
 * As a Dealer I can get a hand with two cards in it
 * As a Player I can see what card the dealer is showing
 * As a Player I can bust (lose immediately) when I am getting cards
 * As a Player I can blackjack (win immediately) when I am dealt cards (this is a simplification)
 * As a Dealer I can draw cards after the player until I win or lose

**Rules:**

 * Bust - Occurs when all possible hand values are greater than 21 points
 * Blackjack - Occurs when a player or dealer is dealt an ace and a 10-point card
 * Dealer - Stays on 17 or above

Please use your discretion in fixing/adding tests. You are free to use/convert to any testing framework you want.

**Optional:**

 * Simulate a random round of the game (you don't have to write educated player decision logic - it could be just guesses)

 For more information on blackjack, please refer to its [wiki page](http://en.wikipedia.org/wiki/Blackjack).
