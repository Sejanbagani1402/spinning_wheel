import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> with SingleTickerProviderStateMixin {
  // Checking and testing
  List<double> sectors = [100, 20, 0.15, 0.5, 50, 20, 100, 50, 20, 50];
  int randomSectorIndex = -1; //any index on sectors
  List<double> sectorRadians = []; //sector degree/radians
  double angle = 0; //angle in radians to spin to
  //
  bool spinning = false;
  double earnedValue = 0;
  double totalEarnings = 0;
  int spins = 0;

  math.Random random = math.Random();
  late AnimationController controller;
  late Animation<double> animation;

  //initital setup
  @override
  void initState() {
    super.initState();
    generateSectorRadians();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600), //3.6 seconds
    );

    Tween<double> tween = Tween<double>(begin: 0, end: 1);
    CurvedAnimation curve = CurvedAnimation(parent: controller, curve: Curves.decelerate);

    animation = tween.animate(curve);
    controller.addListener(() {
      if (controller.isCompleted) {
        setState(() {
          recordstats();
          spinning = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown,
      body: _body(),
    );
  }//

  Widget _body() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg.jpg"), 
          fit: BoxFit.cover),
      ),
      child: _gameContent(),
    );
  }

  Widget _gameContent() {
    return Stack(
      children: [
        _gameTitle(),
        _gameWheel(),
        _gameActions(),
        _gamestats(),
      ],
    );
  }

  Widget _gameTitle() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 70),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            color: CupertinoColors.systemYellow,
            width: 2,
          ),
          gradient: const LinearGradient(
            colors: [
              Color(0xff2d014c),
               Color(0xff80009e),
               ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: const Text(
          "Game Title",
          style: TextStyle(
            fontSize: 40,
             color: CupertinoColors.systemYellow
             ),
        ),
      ),
    );
  }

  Widget _gameWheel() {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(top: 20, left: 5),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          image: DecorationImage(fit: BoxFit.contain, image: AssetImage("assets/images/belt.png")),
        ),
        child: InkWell(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: controller.value * angle,
                child: Container(
                  margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.07),
                  decoration: const BoxDecoration(
                    image: DecorationImage(fit: BoxFit.contain, image: AssetImage("assets/images/wheel.png")),
                  ),
                ),
              );
            },
          ),
          onTap: () {
            setState(() {
              if (!spinning) {
                spin();
                spinning = true;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _gameActions() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.17,
          left: 20,
          right: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: CupertinoColors.systemYellow),
                ),
                child: IconButton(
                  onPressed: () {
                    print("Ready to withdraw");
                  }, 
                  icon: const Icon(Icons.arrow_circle_down),
                ),
              ),
            ),
            // Reset button
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: CupertinoColors.systemYellow),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text(
                  "Reset",
                  style: TextStyle(
                    fontSize: spinning ? 20 : 35,
                    color: const Color(0xff41006e),
                  ),
                ),
              ),
              onTap: () {
                if (spinning) return;
                setState(() {
                  resetGame();
                });
              },
            ),
            // Spin Button
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: CupertinoColors.systemYellow),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text(
                  spinning ? "Spinning" : "Spin",
                  style: TextStyle(
                    fontSize: spinning ? 20 : 35,
                    color: const Color(0xff41006e),
                  ),
                ),
              ),
              onTap: () {
                setState(() {
                  if (!spinning) {
                    spin();
                    spinning = true;
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _gamestats() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            color: CupertinoColors.systemYellow,
            width: 2,
          ),
          gradient: const LinearGradient(
            colors: [Color(0xff2d014c), Color(0xff80009e)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Table(
          border: TableBorder.all(color: CupertinoColors.systemYellow),
          children: [
            TableRow(
              children: [
                _titleColumn("Earned"),
                _titleColumn("Earnings"),
                _titleColumn("Spins"),
              ],
            ),
            TableRow(
              children: [
                _valueColumn(earnedValue.toString()),
                _valueColumn(totalEarnings.toString()),
                _valueColumn(spins.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void generateSectorRadians() {
    //radian for one sector.
    double sectorRadian = 2 * math.pi / sectors.length; // i.e. 360 degree = 2xpi
    //make it some how large
    for (int i = 0; i < sectors.length; i++) {
      sectorRadians.add((i + 1) * sectorRadian);
    }
  }

  void recordstats() {
    earnedValue = sectors[
      sectors.length - (randomSectorIndex + 1)]; //current earned value.
    totalEarnings = totalEarnings + earnedValue; //total earning
    spins = spins + 1;
  }

  void spin() {
    randomSectorIndex = random.nextInt(sectors.length);
    double randomRadian = generateRandomRadianToSpinTo();
    controller.reset();
    angle = randomRadian;
    controller.forward();
  }

  double generateRandomRadianToSpinTo() {
    return (2 * math.pi * sectors.length) + sectorRadians[randomSectorIndex];
  }

  void resetGame() {
    spinning = false;
    angle = 0;
    earnedValue = 0;
    totalEarnings = 0;
    spins = 0;
    controller.reset();
  }
}

Column _titleColumn(String title) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20.0,
            color: CupertinoColors.systemYellow,
          ),
        ),
      ),
    ],
  );
}

Column _valueColumn(String value) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(
          '$value',
          style: const TextStyle(
            fontSize: 25.0,
            color: CupertinoColors.white,
          ),
        ),
      ),
    ],
  );
}
