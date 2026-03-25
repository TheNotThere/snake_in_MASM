#include <iostream>
#include <cstdio>
#include <Windows.h>
#include <chrono>
#include <random>
#include <thread>
extern "C" int addNumbers();
const int mapXSize = 25;
const int mapYSize = 25;
std::string gameOver = 
R"(    
########       #      ###########  ########    #########   #       #  ########  #######           
#             # #     #    #    #  #           #       #    #     #   #         #    #
#            #####    #    #    #  ########    #       #     #   #    ########  #   #
#    ###    #     #   #         #  #           #       #      # #     #         #    #
########   #       #  #         #  ########    #########       #      ########  #     #

)";
void drawMap();
struct Pos {
	int x = 0;
	int y = 0;

};
Pos foodPos = { 10,10 };
struct Snake{
	Pos pos = { 15,15 };
	int snakeSize = 10; // len of snake
	int snakeTurnPoses[25*25]; // holds turn dir 
	int turnDir = 0;
	bool dead = false;

};
const auto frameTime = std::chrono::milliseconds(150);
Snake snake = Snake();
void processInput();
void growSnake();

void updateSnake();
Pos getRandom(int min, int max);

int main()
{
	addNumbers();
	//while (true) {
	//	auto start = std::chrono::steady_clock::now();

	//	processInput();

	//	updateSnake();
	//	drawMap();

	//	auto end = std::chrono::steady_clock::now();
	//	auto elapsed = end - start;
	//	if (elapsed < frameTime) {
	//		std::this_thread::sleep_for(frameTime - elapsed);
	//	}
	//}

}
Pos getRandom(Pos min, Pos max) {
	static std::mt19937 rng(std::random_device{}());
	std::uniform_int_distribution<int> distX(min.x, min.y);
	std::uniform_int_distribution<int> distY(max.x, max.y);

	int rX = distX(rng);
	int rY = distY(rng);
	return { rX,rY };


}
void growSnake() {
	snake.snakeSize++;
}
void updateSnake() {
	if (snake.turnDir == 0) {
		snake.pos.x--;
	}
	else if (snake.turnDir == 1) {
		snake.pos.x++;
	}
	else if (snake.turnDir == 3) {
		snake.pos.y--;
	}
	else if (snake.turnDir == 2) {
		snake.pos.y++;
	
	}
	for (int i = snake.snakeSize; i >= 0; i--) {
		snake.snakeTurnPoses[i + 1] = snake.snakeTurnPoses[i];

	}
	snake.snakeTurnPoses[0] = snake.turnDir;


	
}
void processInput() {
	if (GetAsyncKeyState('W')&1 &&snake.turnDir!=1) {
		snake.turnDir = 0;
		snake.snakeTurnPoses[0] = 0;

	}
	else if (GetAsyncKeyState('S')&1 && snake.turnDir !=0){
		snake.turnDir = 1;
		snake.snakeTurnPoses[0] = 1;

	}
	else if (GetAsyncKeyState('D')&1 && snake.turnDir != 3) {
		snake.turnDir = 2;

		snake.snakeTurnPoses[0] = 2;
	}
	else if (GetAsyncKeyState('A')&1 && snake.turnDir != 2) {
		snake.turnDir = 3;

		snake.snakeTurnPoses[0] = 3;
	}

}
void drawMap() {
	int yPos = 0;
	int xPos = 0;
	uintptr_t map[mapXSize] = { 0 };

	for (int i = 0; i < mapXSize; i++) {
		int* nums = new int[mapYSize]();
		for (int x = 0; x < mapXSize; x++) {
			if (x == 0 || x == 24 || i == 0 || i == 24) {
				nums[x] = 1;


			}
		}
		map[i] = (uintptr_t)(nums);
	}
		if ((snake.pos.x == 0) || (snake.pos.x == 24) || (snake.pos.y == 0) || (snake.pos.y == 24)) {
			snake.dead = true;
			Sleep(1000);
		}
		(((int*)(map[snake.pos.x]))[snake.pos.y]) = 2;
		if ((snake.pos.x == foodPos.x) && (foodPos.y == snake.pos.y)) {
			growSnake();
			foodPos = getRandom({ 1,23 }, { 1,23 });

		}
	for (int i = 1; i < snake.snakeSize; i++) {
	
		
		if (snake.snakeTurnPoses[i] == 0) {
			xPos--;

		}
		else if (snake.snakeTurnPoses[i] == 1) {
			xPos++;

		}
		else if (snake.snakeTurnPoses[i] == 3) {
			yPos--;

		}
		else if (snake.snakeTurnPoses[i] == 2) {
			yPos++;

		}
		


		if ((((int*)(map[snake.pos.x-xPos]))[snake.pos.y-yPos]) == 2) {
			snake.dead = true;
			Sleep(1000);
		}
	
		(((int*)(map[snake.pos.x-xPos]))[snake.pos.y-yPos]) = 2;

	}
	while ((((int*)(map[foodPos.x]))[foodPos.y]) == 2) {
		foodPos.x++;
		if (foodPos.x >= 24) {
			foodPos.x = 1;
			foodPos.y++;

		}
		if (foodPos.y >= 24) {
			foodPos.y = 1;

		}
	}
	(((int*)(map[foodPos.x]))[foodPos.y]) = 3;

	system("cls");
	if (!snake.dead) {
		for (int x = 0; x < mapXSize; x++) {
			for (int y = 0; y < mapYSize; y++) {

				switch (((int*)(map[x]))[y]) {
				case 0:
					std::cout << "  ";
					break;
				case 1:
					std::cout << "? ";
					break;
				case 2:
					std::cout << "# ";
					break;
				case 3:
					std::cout << "@ ";
					break;
				}

			}
			std::cout << "\n";
		}
	}
	else {
		std::cout << gameOver;
	}
	for (int i = 0; i < mapXSize; i++) {
		delete[](int*)map[i];

	}

}
