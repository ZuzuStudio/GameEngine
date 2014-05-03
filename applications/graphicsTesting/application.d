import std.stdio;

import wackyRender;
import wackyPipeline;
import wackyRenderInitializer;
import WackyShaderProgram;

void main()
{
    WackyRender engine = new WackyRender(400, 200, "Testing", WackyWindowMode.WINDOW_MODE);
    WackyRenderInitializer.initialize(engine);

    WackyShaderProgram shader = new WackyShaderProgram;
    shader.attachShader("vertexShader.glsl", WackyShaderTypes.VERTEX_SHADER);
    shader.attachShader("fragmentShader.glsl", WackyShaderTypes.FRAGMENT_SHADER);
    shader.linkShaderProgram();
    shader.useShaderProgram();

    engine.execute!({})(shader.getId);
}
