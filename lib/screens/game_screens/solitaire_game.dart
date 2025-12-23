import 'dart:math';
import 'package:flutter/material.dart';

class SolitaireGame extends StatefulWidget {
  const SolitaireGame({super.key});

  @override
  State<SolitaireGame> createState() => _SolitaireGameState();
}

class _SolitaireGameState extends State<SolitaireGame> {
  List<List<Card>> tableau = [];
  List<Card> stock = [];
  List<Card> waste = [];
  List<List<Card>> foundations = List.generate(4, (_) => []);
  Card? selectedCard;
  int selectedPile = -1;
  int moves = 0;
  int score = 0;
  DateTime? startTime;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    final deck = _createDeck();
    deck.shuffle(Random());

    setState(() {
      tableau = List.generate(7, (i) => []);
      stock = [];
      waste = [];
      foundations = List.generate(4, (_) => []);
      selectedCard = null;
      selectedPile = -1;
      moves = 0;
      score = 0;
      startTime = DateTime.now();

      // Deal cards to tableau
      int cardIndex = 0;
      for (int i = 0; i < 7; i++) {
        for (int j = 0; j <= i; j++) {
          final card = deck[cardIndex++];
          if (j == i) {
            card.isFaceUp = true;
          }
          tableau[i].add(card);
        }
      }

      // Remaining cards go to stock
      stock = deck.sublist(cardIndex);
    });
  }

  List<Card> _createDeck() {
    final suits = ['♠', '♥', '♦', '♣'];
    final ranks = [
      'A',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'J',
      'Q',
      'K'
    ];
    final deck = <Card>[];

    for (var suit in suits) {
      for (var rank in ranks) {
        deck.add(Card(
          suit: suit,
          rank: rank,
          isRed: suit == '♥' || suit == '♦',
        ));
      }
    }

    return deck;
  }

  void onCardTap(Card card, int pileIndex, int cardIndex) {
    if (selectedCard == null) {
      // Select card
      if (card.isFaceUp) {
        setState(() {
          selectedCard = card;
          selectedPile = pileIndex;
        });
      }
    } else {
      // Try to move card
      if (selectedPile == pileIndex && cardIndex == _getSelectedCardIndex()) {
        // Deselect
        setState(() {
          selectedCard = null;
          selectedPile = -1;
        });
      } else {
        _tryMoveCard(pileIndex, cardIndex);
      }
    }
  }

  int _getSelectedCardIndex() {
    if (selectedPile == -1) return -1; // Stock/Waste
    if (selectedPile >= 0 && selectedPile < 7) {
      return tableau[selectedPile].indexOf(selectedCard!);
    }
    return -1;
  }

  void _tryMoveCard(int targetPile, int targetIndex) {
    if (selectedCard == null) return;

    bool moved = false;

    if (selectedPile == -1) {
      // Moving from waste
      if (targetPile >= 0 && targetPile < 7) {
        // To tableau
        if (_canPlaceOnTableau(selectedCard!, targetPile)) {
          waste.remove(selectedCard);
          tableau[targetPile].add(selectedCard!);
          moved = true;
        }
      } else if (targetPile >= 7 && targetPile < 11) {
        // To foundation
        final foundationIndex = targetPile - 7;
        if (_canPlaceOnFoundation(selectedCard!, foundationIndex)) {
          waste.remove(selectedCard);
          foundations[foundationIndex].add(selectedCard!);
          moved = true;
          score += 10;
        }
      }
    } else if (selectedPile >= 0 && selectedPile < 7) {
      // Moving from tableau
      final sourcePile = tableau[selectedPile];
      final cardIndex = sourcePile.indexOf(selectedCard!);
      final cardsToMove = sourcePile.sublist(cardIndex);

      if (targetPile >= 0 && targetPile < 7 && targetPile != selectedPile) {
        // To tableau
        if (_canPlaceOnTableau(cardsToMove.first, targetPile)) {
          tableau[targetPile].addAll(cardsToMove);
          tableau[selectedPile].removeRange(cardIndex, sourcePile.length);
          if (tableau[selectedPile].isNotEmpty &&
              !tableau[selectedPile].last.isFaceUp) {
            tableau[selectedPile].last.isFaceUp = true;
            score += 5;
          }
          moved = true;
        }
      } else if (targetPile >= 7 && targetPile < 11) {
        // To foundation (only single card)
        if (cardsToMove.length == 1) {
          final foundationIndex = targetPile - 7;
          if (_canPlaceOnFoundation(selectedCard!, foundationIndex)) {
            foundations[foundationIndex].add(selectedCard!);
            tableau[selectedPile].removeLast();
            if (tableau[selectedPile].isNotEmpty &&
                !tableau[selectedPile].last.isFaceUp) {
              tableau[selectedPile].last.isFaceUp = true;
              score += 5;
            }
            moved = true;
            score += 10;
          }
        }
      }
    }

    if (moved) {
      setState(() {
        selectedCard = null;
        selectedPile = -1;
        moves++;
      });
    } else {
      setState(() {
        selectedCard = null;
        selectedPile = -1;
      });
    }
  }

  bool _canPlaceOnTableau(Card card, int pileIndex) {
    if (tableau[pileIndex].isEmpty) {
      return card.rank == 'K';
    }
    final topCard = tableau[pileIndex].last;
    return card.isRed != topCard.isRed &&
        _getCardValue(card.rank) == _getCardValue(topCard.rank) - 1;
  }

  bool _canPlaceOnFoundation(Card card, int foundationIndex) {
    if (foundations[foundationIndex].isEmpty) {
      return card.rank == 'A';
    }
    final topCard = foundations[foundationIndex].last;
    return card.suit == topCard.suit &&
        _getCardValue(card.rank) == _getCardValue(topCard.rank) + 1;
  }

  int _getCardValue(String rank) {
    if (rank == 'A') return 1;
    if (rank == 'J') return 11;
    if (rank == 'Q') return 12;
    if (rank == 'K') return 13;
    return int.parse(rank);
  }

  void drawCard() {
    if (stock.isEmpty) {
      setState(() {
        stock = waste.reversed.toList();
        waste = [];
        for (var card in stock) {
          card.isFaceUp = false;
        }
      });
    } else {
      setState(() {
        final card = stock.removeLast();
        card.isFaceUp = true;
        waste.add(card);
        moves++;
      });
    }
  }

  void onStockTap() {
    drawCard();
  }

  void onWasteTap() {
    if (waste.isNotEmpty) {
      setState(() {
        selectedCard = waste.last;
        selectedPile = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solitaire'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: startGame,
            tooltip: 'New Game',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Score and moves
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Score: $score',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Moves: $moves', style: const TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                // Foundations and stock/waste
                Row(
                  children: [
                    // Stock
                    _buildCardPlaceholder(
                      onTap: onStockTap,
                      child: stock.isEmpty
                          ? const SizedBox()
                          : Container(
                              width: 60,
                              height: 84,
                              decoration: BoxDecoration(
                                color: Colors.green[700],
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.black, width: 2),
                              ),
                              child:
                                  const Icon(Icons.style, color: Colors.white),
                            ),
                    ),
                    const SizedBox(width: 8),
                    // Waste
                    _buildCardPlaceholder(
                      onTap: onWasteTap,
                      child: waste.isEmpty
                          ? const SizedBox()
                          : _buildCard(waste.last, -1, -1),
                    ),
                    const Spacer(),
                    // Foundations
                    ...List.generate(4, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _buildCardPlaceholder(
                          onTap: () {
                            if (selectedCard != null) {
                              _tryMoveCard(7 + i, -1);
                            }
                          },
                          child: foundations[i].isEmpty
                              ? Container(
                                  width: 60,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey, width: 2),
                                  ),
                                )
                              : _buildCard(foundations[i].last, 7 + i, -1),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                // Tableau
                ...List.generate(7, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      height: 100,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: Text('${i + 1}',
                                style: const TextStyle(fontSize: 12)),
                          ),
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: tableau[i].length,
                              itemBuilder: (context, j) {
                                final card = tableau[i][j];
                                final isSelected =
                                    selectedCard == card && selectedPile == i;
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: j == 0
                                        ? 0
                                        : (card.isFaceUp ? -40.0 : -20.0),
                                  ),
                                  child: GestureDetector(
                                    onTap: () => onCardTap(card, i, j),
                                    child: Transform.scale(
                                      scale: isSelected ? 1.1 : 1.0,
                                      child: _buildCard(card, i, j),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardPlaceholder(
      {required VoidCallback onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        height: 84,
        child: child,
      ),
    );
  }

  Widget _buildCard(Card card, int pileIndex, int cardIndex) {
    final isSelected = selectedCard == card && selectedPile == pileIndex;

    if (!card.isFaceUp) {
      return Container(
        width: 60,
        height: 84,
        decoration: BoxDecoration(
          color: Colors.blue[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.yellow : Colors.black,
            width: isSelected ? 3 : 2,
          ),
        ),
        child: const Icon(Icons.credit_card, color: Colors.white70),
      );
    }

    return Container(
      width: 60,
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.yellow : Colors.black,
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.rank,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: card.isRed ? Colors.red : Colors.black,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  card.suit,
                  style: TextStyle(
                    fontSize: 24,
                    color: card.isRed ? Colors.red : Colors.black,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                card.rank,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: card.isRed ? Colors.red : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Card {
  final String suit;
  final String rank;
  final bool isRed;
  bool isFaceUp;

  Card({
    required this.suit,
    required this.rank,
    required this.isRed,
    this.isFaceUp = false,
  });
}
