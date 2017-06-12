require 'minitest/autorun'

module Rules
  NAME_VALUE = [2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "K", "A"]
  SUITES = ["Spade", "Heart", "Diamond", "Club"]
  MAX_CARDS_PER_PLAYER = 4
  MAX_NUM_OF_PLAYERS = 7
  DEALER_STAY_VALUE = 17
  BLACKJACK_VALUE = 21
end

class Card < Minitest::Test
    include Rules
    attr_reader :value, :is_ace_card

    def initialize(nameval, suite)
        unless Deck::NAME_VALUE.include?nameval
            raise ArgumentError.new("Bad card!")
        end

        unless Deck::SUITES.include?suite
            raise ArgumentError.new("Wrong suite!")
        end

        @name = "#{nameval.to_s} #{suite}"
        @is_ace_card = false

        case nameval
          when 2..10 then @value = nameval
          when "J" then @value = 10
          when "Q" then @value = 10
          when "K" then  @value = 10
          when "A"
              @value = 1
              @is_ace_card = true
        end
    end
end

class Deck < Minitest::Test
    include Rules
    attr_accessor :cards
    def initialize
        reset
    end

    def reset
        @cards = create_52_card_deck()
        @cards.shuffle!
    end

    def create_52_card_deck
        SUITES.map{|suite| NAME_VALUE.map{|name| Card.new(name, suite)}}.flatten
    end

    def to_s
        @cards.join(", ")
    end

    def empty?
        @cards.empty?
    end

    def pop
        reset if empty?
        @cards.pop
    end
end

class Hand < Minitest::Test
    include Rules
    attr_reader :cards

    def initialize
        reset
    end

    def reset
        @cards = []
        @value = 0
        @num_aces = 0
    end

    def push(card)
        @num_aces += 1 if card.is_ace_card

        @cards.push(card)
        @value += card.value
    end

    def value
        if has_ace? && @value < 12
            @value + 10
        else
            @value
        end
    end

    def pop
        card = @cards.pop
        @value -= card.value
        return card
    end

    def just_received?
        @cards.length == 2
    end

    def can_be_split?
        just_received? && @cards[-1].value == @cards[-2].value
    end

    def is_bust?
        value > BLACKJACK_VALUE
    end

    def has_ace?
        @num_aces > 0
    end

    def is_blackjack?
        just_received?
        @num_aces == 1
        value == BLACKJACK_VALUE
    end
end

class Player < Minitest::Test
    attr_reader :position, :hands

    def initialize(position)
        @position = position
        @hands = [Hand.new]
    end

    def reset_hands
        @hands = [Hand.new]
    end

    def ask_decision(possible_move)
        ask_options_info_msg = possible_move.map{|pair| "'#{pair[0]}' for #{pair[1]}"}.join(", ")
        pick = ""
        loop do
            puts "What do you want to do?"
            pick = gets.chomp
        end
        puts ""
        return pick
    end

    def can_split_hand?(hand)
        @hands.length < MAX_CARDS_PER_PLAYER && hand.can_be_split?
    end

    def split_hand(hand)
        unless can_split_hand?hand
            raise ArgumentError.new("Can't split this!")
        end
        new_hand = Hand.new
        new_hand.push(hand.pop)
        @hands.push(new_hand)
        return new_hand
    end
end

class Dealer < Minitest::Test
    include Rules
    def initialize(players)
        unless players.length > 0
            raise ArgumentError.new("Game should have at least one player")
        end

        @hand = Hand.new
        @deck = Deck.new
        @players = players
        @game_over = false
    end

    def play_game
        puts "Game starting!"
        play_round until @game_over
        puts "Game over!"
    end

    def play_round
        puts "New round!"

        setup_round

        @players.each do |player|
            player.hands.each do |player_hand|
                process_player_hand(player, player_hand)
            end
        end

        dealer_deals_to_self unless @hand.is_blackjack?

        @game_over = is_game_over?
    end

    def setup_round
        reset_player_hands
        reset_self_hand

        @players.each do |player|
            player.hands.each do |player_hand|
                deal_cards_to_hand(player_hand)
                show_hand(player, player_hand)
            end
        end

        deal_cards_to_hand(@hand)
        show_dealer_hand
        puts ">>> Initial cards dealt\n\n\n\n"
    end

    def reset_player_hands
        @players.map{|player| player.reset_hands}
    end

    def reset_self_hand
        @hand.reset
    end

    def deal_cards_to_hand(hand)
        2.times{deal_to_hand(hand)}
    end

    def show_dealer_hand
        show_hand(self, @hand)
    end

    def show_hand(player, hand)
        puts "#{player}'s cards:\n" +
             "#{hand}"
    end

    def process_player_hand(player, player_hand)
        show_hand(player, player_hand)
        show_dealer_hand

        if player_hand.is_blackjack?
            puts "#{player} gets blackjack!"
            game_over
        end

        possible_move = build_possible_move_for_hand(player, player_hand)
        move = player.ask_decision(possible_move)

        if player_stay_with_move(move)
            return

        else
            if player_splits_with_move(move)
                new_hand = player.split_hand(player_hand)

                deal_to_hand(player_hand)
                deal_to_hand(new_hand)

                puts "Here is your split hand:"
                show_hand(player, player_hand)
                show_hand(player, new_hand)

            else
                deal_to_hand(player_hand)
            end

            if player_hand.is_bust?
                show_hand(player, player_hand)
                puts "Busted!"
            else
                process_player_hand(player, player_hand)
            end
        end
    end

    def player_stay_with_move(move)
        move == STAY_KEY
    end

    def player_splits_with_move(move)
        move == SPLIT_KEY
    end

    def dealer_deals_to_self
        puts "Dealing to #{self}\n\n"
        until self.should_stay?
            deal_to_hand(@hand)
        end
        show_dealer_hand
    end

    def should_stay?
        @hand.value >= DEALER_STAY_VALUE
    end

    def deal_to_hand(hand)
        card = @deck.pop
        hand.push(card)
    end

    def is_game_over?
        return true if @players.empty?
        return ask_if_end_game
    end

    def ask_if_end_game
        play_again = ""
        loop do
            puts "Want to play again? (y/n)"
            play_again = gets.chomp
            break if (play_again == "y" || play_again == "n")
            puts "Please pick the 'y' or 'n' key."
        end
        puts

        if(play_again == "n")
            return true
        else
            return false
        end
    end
end

# TEST TEST TEST

class DeckTest < Minitest::Test
    def setup
        @class_tested = Deck.new
    end

    def test_initialize
        assert_equal(52, @class_tested.cards.length)
    end

    def test_pop
        @class_tested.pop
        assert_equal(51, @class_tested.cards.length)
    end

    def test_deck_replenishes_on_too_many_pops
        until @class_tested.cards.empty?
            @class_tested.pop
        end
        assert(@class_tested.cards.empty?)
    end
end

class CardTest < Minitest::Test
    include Rules
    def setup
        @class_tested = Card.new(NAME_VALUE[0],SUITES[0])
    end

    def test_value
        assert_equal(NAME_VALUE[0], @class_tested.value)
    end

    def test_is_ace_card
        assert_equal(false, @class_tested.is_ace_card)

        @class_tested = Card.new(NAME_VALUE[-1],SUITES[0])
        assert(@class_tested.is_ace_card)
    end
end

class HandTest < Minitest::Test
    include Rules
    def setup
        @class_tested = Hand.new
    end

    def test_initialize
        assert(@class_tested.cards.empty?)
        assert_equal(0, @class_tested.value)
    end

    def test_push
        card = Card.new(NAME_VALUE[0], SUITES[0])
        @class_tested.push(card)
        assert_equal(1, @class_tested.cards.length)
        assert_equal(2, @class_tested.value)
    end

    def test_pop
        card = Card.new(NAME_VALUE[0], SUITES[0])
        @class_tested.push(card)
        assert_equal(card, @class_tested.pop)
        assert(@class_tested.cards.empty?)
        assert_equal(0, @class_tested.value)
    end

    def test_just_received
        assert_equal(false, @class_tested.just_received?)

        card = Card.new(NAME_VALUE[0], SUITES[0])
        2.times{@class_tested.push(card)}
        assert(@class_tested.just_received?)
    end

    def test_has_ace
        assert_equal(false, @class_tested.has_ace?)

        card = Card.new(NAME_VALUE[-1], SUITES[0])
        @class_tested.push(card)
        assert(@class_tested.has_ace?)
    end

    def test_is_bust
        assert_equal(false, @class_tested.is_bust?)

        card = Card.new(NAME_VALUE[8], SUITES[0])
        3.times{@class_tested.push(card)}
        assert(@class_tested.is_bust?)
    end

    def test_is_blackjack
        assert_equal(false, @class_tested.is_blackjack?)

        card = Card.new(NAME_VALUE[-1], SUITES[0])
        @class_tested.push(card)
        card = Card.new(NAME_VALUE[8], SUITES[0])
        @class_tested.push(card)
        assert(@class_tested.is_blackjack?)
    end

    def test_can_be_split
        assert_equal(false, @class_tested.can_be_split?)

        card = Card.new(NAME_VALUE[-1], SUITES[0])
        2.times{@class_tested.push(card)}
        assert(@class_tested.can_be_split?)
    end
end

class TestPlayer < Minitest::Test
    include Rules
    def setup
        @class_tested = Player.new(0)
    end

    def test_initialize
        assert_equal(0, @class_tested.position)
        assert_equal(1, @class_tested.hands.length)
    end

    def test_reset_hands
        @class_tested.hands.push(Hand.new)
        assert_equal(2, @class_tested.hands.length)

        @class_tested.reset_hands
        assert_equal(1, @class_tested.hands.length)
    end
end


class TestDealer < Minitest::Test
    include Rules
    def setup
        @player = Player.new(0)
        card = Card.new(NAME_VALUE[0], SUITES[0])
        @player.hands[0].push(card)
        @player_array = [@player]
        @class_tested = Dealer.new(@player_array)
    end

    def test_reset_player_hands
        assert_equal(1, @player.hands[0].cards.length)

        @class_tested.reset_player_hands
        assert(0, @player.hands[0].cards.length)
    end
end
