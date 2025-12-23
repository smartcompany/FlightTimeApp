import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TowerDefenseGame extends StatefulWidget {
  const TowerDefenseGame({super.key});

  @override
  State<TowerDefenseGame> createState() => _TowerDefenseGameState();
}

class _TowerDefenseGameState extends State<TowerDefenseGame> {
  int money = 100;
  int lives = 20;
  int wave = 1;
  int score = 0;
  bool gameRunning = false;
  bool gameOver = false;
  bool gameWon = false;
  
  List<Enemy> enemies = [];
  List<Tower> towers = [];
  List<Projectile> projectiles = [];
  Timer? gameTimer;
  
  final List<PathPoint> path = [
    PathPoint(0.1, 0.5),
    PathPoint(0.3, 0.5),
    PathPoint(0.3, 0.3),
    PathPoint(0.6, 0.3),
    PathPoint(0.6, 0.7),
    PathPoint(0.9, 0.7),
    PathPoint(0.9, 0.5),
    PathPoint(1.1, 0.5), // End
  ];
  
  double nextEnemySpawn = 0;
  int enemiesInWave = 0;
  int enemiesSpawned = 0;

  @override
  void initState() {
    super.initState();
  }

  void startGame() {
    setState(() {
      gameRunning = true;
      gameOver = false;
      gameWon = false;
      money = 100;
      lives = 20;
      wave = 1;
      score = 0;
      enemies = [];
      towers = [];
      projectiles = [];
      enemiesInWave = 5;
      enemiesSpawned = 0;
      nextEnemySpawn = 0;
    });
    
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (gameRunning && mounted) {
        updateGame();
      }
    });
  }

  void updateGame() {
    if (!mounted) return;
    
    setState(() {
      // Spawn enemies
      nextEnemySpawn -= 0.016;
      if (nextEnemySpawn <= 0 && enemiesSpawned < enemiesInWave) {
        enemies.add(Enemy(
          x: path[0].x,
          y: path[0].y,
          pathIndex: 0,
          health: 50 + wave * 10,
          maxHealth: 50 + wave * 10,
          speed: 0.0003,
        ));
        enemiesSpawned++;
        nextEnemySpawn = 2.0;
      }
      
      // Move enemies
      for (var enemy in enemies) {
        if (enemy.pathIndex < path.length - 1) {
          final target = path[enemy.pathIndex + 1];
          final dx = target.x - enemy.x;
          final dy = target.y - enemy.y;
          final distance = sqrt(dx * dx + dy * dy);
          
          if (distance < 0.01) {
            enemy.pathIndex++;
            if (enemy.pathIndex >= path.length - 1) {
              // Enemy reached end
              lives--;
              if (lives <= 0) {
                gameOver = true;
                gameRunning = false;
                gameTimer?.cancel();
                return;
              }
            }
          } else {
            enemy.x += (dx / distance) * enemy.speed;
            enemy.y += (dy / distance) * enemy.speed;
          }
        }
      }
      
      // Remove dead enemies
      enemies.removeWhere((enemy) {
        if (enemy.health <= 0) {
          money += 10;
          score += 10;
          return true;
        }
        return false;
      });
      
      // Tower shooting
      for (var tower in towers) {
        tower.cooldown -= 0.016;
        if (tower.cooldown <= 0) {
          Enemy? target;
          double minDistance = double.infinity;
          
          for (var enemy in enemies) {
            final dx = enemy.x - tower.x;
            final dy = enemy.y - tower.y;
            final distance = sqrt(dx * dx + dy * dy);
            if (distance < tower.range && distance < minDistance) {
              minDistance = distance;
              target = enemy;
            }
          }
          
          if (target != null) {
            tower.cooldown = tower.fireRate;
            projectiles.add(Projectile(
              x: tower.x,
              y: tower.y,
              targetX: target.x,
              targetY: target.y,
              damage: tower.damage,
              target: target,
            ));
          }
        }
      }
      
      // Move projectiles
      projectiles.removeWhere((projectile) {
        final dx = projectile.targetX - projectile.x;
        final dy = projectile.targetY - projectile.y;
        final distance = sqrt(dx * dx + dy * dy);
        
        if (distance < 0.01) {
          // Hit target
          if (projectile.target != null && enemies.contains(projectile.target)) {
            projectile.target!.health -= projectile.damage;
          }
          return true;
        }
        
        projectile.x += (dx / distance) * 0.01;
        projectile.y += (dy / distance) * 0.01;
        return false;
      });
      
      // Check wave completion
      if (enemiesSpawned >= enemiesInWave && enemies.isEmpty) {
        wave++;
        enemiesInWave = 5 + wave;
        enemiesSpawned = 0;
        money += 50;
        score += 100;
        
        if (wave > 10) {
          gameWon = true;
          gameRunning = false;
          gameTimer?.cancel();
        }
      }
    });
  }

  void placeTower(double x, double y) {
    if (money >= 50) {
      // Check if position is valid (not on path)
      bool onPath = false;
      for (var point in path) {
        final dx = x - point.x;
        final dy = y - point.y;
        if (sqrt(dx * dx + dy * dy) < 0.05) {
          onPath = true;
          break;
        }
      }
      
      // Check if too close to existing tower
      bool tooClose = false;
      for (var tower in towers) {
        final dx = x - tower.x;
        final dy = y - tower.y;
        if (sqrt(dx * dx + dy * dy) < 0.08) {
          tooClose = true;
          break;
        }
      }
      
      if (!onPath && !tooClose) {
        setState(() {
          towers.add(Tower(
            x: x,
            y: y,
            range: 0.15,
            damage: 20,
            fireRate: 1.0,
          ));
          money -= 50;
        });
      }
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tower Defense')),
      body: SafeArea(
        child: Column(
          children: [
            // Stats
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Money: \$$money', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Lives: $lives', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Wave: $wave', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Score: $score', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Game area
            Expanded(
              child: GestureDetector(
                onTapDown: (details) {
                  if (gameRunning) {
                    final renderBox = context.findRenderObject() as RenderBox;
                    final localPosition = details.localPosition;
                    final x = localPosition.dx / renderBox.size.width;
                    final y = localPosition.dy / renderBox.size.height;
                    placeTower(x, y);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.green[300]!, Colors.green[100]!],
                    ),
                  ),
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: TowerDefensePainter(
                          path: path,
                          enemies: enemies,
                          towers: towers,
                          projectiles: projectiles,
                        ),
                        size: Size.infinite,
                      ),
                      if (gameOver)
                        Container(
                          color: Colors.black.withOpacity(0.7),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Game Over!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 16),
                                Text('Score: $score', style: const TextStyle(fontSize: 24, color: Colors.white)),
                                const SizedBox(height: 16),
                                ElevatedButton(onPressed: startGame, child: const Text('Play Again')),
                              ],
                            ),
                          ),
                        )
                      else if (gameWon)
                        Container(
                          color: Colors.black.withOpacity(0.7),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('You Win!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 16),
                                Text('Score: $score', style: const TextStyle(fontSize: 24, color: Colors.white)),
                                const SizedBox(height: 16),
                                ElevatedButton(onPressed: startGame, child: const Text('Play Again')),
                              ],
                            ),
                          ),
                        )
                      else if (!gameRunning)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Tower Defense', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 16),
                                const Text('Tap to place towers (\$50)', style: TextStyle(fontSize: 18, color: Colors.white)),
                                const SizedBox(height: 16),
                                ElevatedButton(onPressed: startGame, child: const Text('Start Game')),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Instructions
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: const Text('Tap to place towers. Defend against 10 waves!'),
            ),
          ],
        ),
      ),
    );
  }
}

class PathPoint {
  final double x;
  final double y;
  
  PathPoint(this.x, this.y);
}

class Enemy {
  double x;
  double y;
  int pathIndex;
  int health;
  int maxHealth;
  double speed;
  
  Enemy({
    required this.x,
    required this.y,
    required this.pathIndex,
    required this.health,
    required this.maxHealth,
    required this.speed,
  });
}

class Tower {
  double x;
  double y;
  double range;
  int damage;
  double fireRate;
  double cooldown = 0;
  
  Tower({
    required this.x,
    required this.y,
    required this.range,
    required this.damage,
    required this.fireRate,
  });
}

class Projectile {
  double x;
  double y;
  double targetX;
  double targetY;
  int damage;
  Enemy? target;
  
  Projectile({
    required this.x,
    required this.y,
    required this.targetX,
    required this.targetY,
    required this.damage,
    this.target,
  });
}

class TowerDefensePainter extends CustomPainter {
  final List<PathPoint> path;
  final List<Enemy> enemies;
  final List<Tower> towers;
  final List<Projectile> projectiles;

  TowerDefensePainter({
    required this.path,
    required this.enemies,
    required this.towers,
    required this.projectiles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw path
    final pathPaint = Paint()..color = Colors.brown[700]!;
    final pathPath = Path();
    pathPath.moveTo(path[0].x * size.width, path[0].y * size.height);
    for (int i = 1; i < path.length; i++) {
      pathPath.lineTo(path[i].x * size.width, path[i].y * size.height);
    }
    canvas.drawPath(pathPath, pathPaint..strokeWidth = 40..style = PaintingStyle.stroke);
    
    // Draw towers
    final towerPaint = Paint()..color = Colors.blue[700]!;
    final rangePaint = Paint()..color = Colors.blue.withOpacity(0.2);
    for (var tower in towers) {
      // Range circle
      canvas.drawCircle(
        Offset(tower.x * size.width, tower.y * size.height),
        tower.range * size.width,
        rangePaint,
      );
      // Tower
      canvas.drawCircle(
        Offset(tower.x * size.width, tower.y * size.height),
        15,
        towerPaint,
      );
    }
    
    // Draw enemies
    for (var enemy in enemies) {
      final healthRatio = enemy.health / enemy.maxHealth;
      final enemyPaint = Paint()..color = Colors.red[700]!;
      canvas.drawCircle(
        Offset(enemy.x * size.width, enemy.y * size.height),
        12,
        enemyPaint,
      );
      // Health bar
      final barWidth = 24.0;
      final barHeight = 4.0;
      canvas.drawRect(
        Rect.fromLTWH(
          enemy.x * size.width - barWidth / 2,
          enemy.y * size.height - 20,
          barWidth,
          barHeight,
        ),
        Paint()..color = Colors.grey[300]!,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          enemy.x * size.width - barWidth / 2,
          enemy.y * size.height - 20,
          barWidth * healthRatio,
          barHeight,
        ),
        Paint()..color = Colors.green,
      );
    }
    
    // Draw projectiles
    final projectilePaint = Paint()..color = Colors.yellow;
    for (var projectile in projectiles) {
      canvas.drawCircle(
        Offset(projectile.x * size.width, projectile.y * size.height),
        4,
        projectilePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

