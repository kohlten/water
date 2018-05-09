import dsfml.graphics;
import dsfml.window;
import dsfml.system;

import std.conv : to;
import std.random : uniform;
import std.stdio : writeln;

import helpFuncs;

class Game
{
	RenderWindow	window;
	Vector2i		size;
	ContextSettings	*options;
	Color			color;

	float[][] buff1;
	float[][] buff2;
	Vertex[][] vals;

	float damp = 0.97;

	Vector2i mousePos;

	this()
	{
		this.color	 = 	Color(0, 0, 0);
		this.size  	 =	Vector2i(800, 800);

		this.options = 	new ContextSettings();
		this.options.antialiasingLevel = 8;

		this.window  = 	new RenderWindow(VideoMode(this.size.x, this.size.y), "Ripples", Window.Style.DefaultStyle, *options);
		this.window.setFramerateLimit(60);
		this.buff1.length = this.size.x;
		this.buff2.length = this.size.x;
		this.vals.length = this.size.x;
		foreach (i; 0 .. this.buff1.length)
		{
			this.buff1[i].length = this.size.y;
			this.buff2[i].length = this.size.y;
			this.vals[i].length = this.size.y;
			foreach (j; 0 .. this.buff1.length)
			{
				this.buff1[i][j] = 0;
				this.buff2[i][j] = 0;
				this.vals[i][j].position = Vector2f(i, j);
			}
		}
	}

	void run()
	{
		while (this.window.isOpen())
		{
			if (Mouse.getPosition(this.window) != this.mousePos)
			{
				this.mousePos = Mouse.getPosition(this.window);
				if (this.mousePos.x >= 0 && this.mousePos.x <= this.size.x &&
					this.mousePos.y >= 0 && this.mousePos.y <= this.size.y)
					this.buff1[this.mousePos.x][this.mousePos.y] = 255;
			}
			else
			{
				if (uniform(0, 101) == 100)
				{
					int i = uniform(0, this.size.x);
					int j = uniform(0, this.size.y);
					this.buff1[i][j] = 255;
				}
			}
			this.getEvents();
			this.window.clear(this.color);
			this.update_buffers();
			this.set_pixels();
			foreach (i; 0 .. this.size.x)
				this.window.draw(this.vals[i], PrimitiveType.Points);
			this.window.display();
		}
	}

	void getEvents()
	{
		Event event;
		while (this.window.pollEvent(event))
		{
			if (event.type == Event.EventType.Closed)
				window.close();
		}
	}

	void update_buffers()
	{
		foreach (i; 1 .. this.buff2.length - 1)
		{
			foreach (j; 1 .. this.buff2[i].length - 1)
			{
				this.buff2[i][j] = (this.buff1[i - 1][j] + this.buff1[i + 1][j] +
									this.buff1[i][j + 1] + this.buff1[i][j - 1]) / 2 - this.buff2[i][j];
				this.buff2[i][j] = this.buff2[i][j] * damp;
			}
		}
	}

	void set_pixels()
	{
		foreach (i; 0 .. this.size.x)
			foreach (j; 0 .. this.size.y)
			{
				ubyte val = cast(ubyte) this.buff2[i][j];
				this.vals[i][j].color = Color(val, val, val); 
			}
		this.swap();
	}

	void swap()
	{
		float[][] tmp;

		tmp = this.buff1;
		this.buff1 = this.buff2;
		this.buff2 = tmp;
	}
}