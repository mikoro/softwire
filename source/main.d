import derelict.glfw3.glfw3;
import derelict.opengl3.gl3;
import derelict.freetype.ft;

import game;

int main()
{
	DerelictGLFW3.load();
	DerelictGL3.load();
	DerelictFT.load();

	Game game = new Game();

	game.initialize();
	game.mainloop();
	game.shutdown();

	return 0;
}
