module main;

import std.stdio;

import wackyRender;

void main()
{
    WackyRender engine = new WackyRender(400, 200, "Testing", WackyWindowMode.WINDOW_MODE);
    engine.setExitKeyAndAction(WackyKeys.KEY_ESCAPE, WackyActions.RELEASE);

    engine.execute();
}
