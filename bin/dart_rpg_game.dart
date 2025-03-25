import 'dart:io';
import 'dart:math';
import 'dart:convert';

class Character {
  String name;
  int health;
  int attackPower;
  int defense;
  bool hasUsedItem = false; // 도전 과제

  Character(this.name, this.health, this.attackPower, this.defense);

  // 도전 과제 추가
  void applyHealthBonus() {
    if (Random().nextInt(100) < 30) {
      health += 10;
      print('보너스 체력을 얻었습니다! 현재 체력: $health');
    }
  }

  void attackMonster(Monster monster) {
    int damage = max(attackPower - monster.defense, 0);
    monster.health -= damage;
    print('$name이(가) ${monster.name}을(를) 공격하여 $damage의 피해를 입혔습니다!');
  }

  // 도전 과제 추가
  void useItem() {
    if (!hasUsedItem) {
      attackPower *= 2;
      hasUsedItem = true;
      print('$name이(가) 특수 아이템을 사용하여 공격력이 두 배가 되었습니다! 현재 공격력: $attackPower');
    } else {
      print('아이템을 이미 사용했습니다!');
    }
  }

  void defend() {
    health += 5;
    print('$name이(가) 방어 자세를 취하여 체력을 5 회복했습니다.');
  }

  void showStatus() {
    print('$name - 체력: $health, 공격력: $attackPower, 방어력: $defense');
  }
}

class Monster {
  String name;
  int health;
  int attackMax;
  int defense = 0;
  int turnCounter = 0; // 도전 과제

  Monster(this.name, this.health, this.attackMax);

  int get attackPower => Random().nextInt(attackMax) + 1;

  void attackCharacter(Character character) {
    int damage = max(attackPower - character.defense, 0);
    character.health -= damage;
    print('$name이(가) ${character.name}을(를) 공격하여 $damage의 피해를 입혔습니다!');
  }

  // 도전 과제 추가
  void increaseDefense() {
    turnCounter++;
    if (turnCounter % 3 == 0) {
      defense += 2;
      print('$name의 방어력이 증가했습니다! 현재 방어력: $defense');
    }
  }

  void showStatus() {
    print('$name - 체력: $health, 공격력: $attackMax');
  }
}

class Game {
  Character character;
  List<Monster> monsters;
  int defeatedMonsters = 0;

  Game(this.character, this.monsters);

  void startGame() {
    print('게임을 시작합니다!');
    character.showStatus();
    character.applyHealthBonus(); // 도전 과제

    while (character.health > 0) {
      if (monsters.every((m) => m.health <= 0)) {
        print('모든 몬스터를 처치했습니다!');
        saveResult('승리');
        return;
      }

      Monster monster = getRandomMonster();
      print('\n===== ${monster.name}이(가) 등장! =====');
      battle(monster);

      if (character.health <= 0) {
        print('게임 오버! ${character.name}이(가) 패배했습니다.');
        saveResult('패배');
        return;
      }

      print('다음 몬스터와 싸우시겠습니까? (y/n)');
      String? choice = stdin.readLineSync();
      if (choice?.toLowerCase() != 'y') {
        print('게임 종료! ${character.name}이(가) 승리했습니다.');
        saveResult('승리');
        return;
      }
    }
  }

  void battle(Monster monster) {
    while (character.health > 0 && monster.health > 0) {
      character.showStatus();
      monster.showStatus();

      print('행동을 선택하세요: 공격(1) 방어(2), 아이템 사용(3)');
      String? input = stdin.readLineSync();

      switch (input) {
        case '1':
          character.attackMonster(monster);
          break;
        case '2':
          print('${character.name}이(가) 방어 자세를 취합니다!');
          break;
        case '3':
          character.useItem();
          break;
        default:
          print('잘못된 입력입니다.');
          continue;
      }

      if (monster.health > 0) {
        monster.attackCharacter(character);
        monster.increaseDefense();
      } else {
        print('${monster.name}을(를) 물리쳤습니다!');
        defeatedMonsters++;
        break;
      }
    }
  }

  Monster getRandomMonster() {
    List<Monster> aliveMonsters = monsters.where((m) => m.health > 0).toList();
    if (aliveMonsters.isEmpty) {
      print('모든 몬스터를 처치했습니다!');
      saveResult('승리');
      exit(0);
    }
    return aliveMonsters[Random().nextInt(monsters.length)];
  }

  void saveResult(String result) {
    print('결과를 저장하시겟습니까? (y/n)');
    String? choice = stdin.readLineSync();
    if (choice?.toLowerCase() == 'y') {
      File(
        'result.txt',
      ).writeAsStringSync('${character.name},${character.health},$result');
      print('결과가 저장되었습니다.');
    }
  }
}

Character loadCharacter() {
  final file = File('characters.txt');
  final stats = file.readAsStringSync().split(',');
  return Character(
    getCharacterName(),
    int.parse(stats[0]),
    int.parse(stats[1]),
    int.parse(stats[2]),
  );
}

List<Monster> loadMonsters() {
  final file = File('monsters.txt');
  return file.readAsLinesSync().map((line) {
    var stats = line.split(',');
    return Monster(stats[0], int.parse(stats[1]), int.parse(stats[2]));
  }).toList();
}

String getCharacterName() {
  while (true) {
    print('캐릭터의 이름을 입력하세요:');
    String? name = stdin.readLineSync(encoding: utf8);
    if (name != null && RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(name)) {
      return name;
    }
    print('올바른 이름을 입력하세요. (한글 또는 영문)');
  }
}

void main() {
  Character character = loadCharacter();
  List<Monster> monsters = loadMonsters();
  Game game = Game(character, monsters);
  game.startGame();
}
