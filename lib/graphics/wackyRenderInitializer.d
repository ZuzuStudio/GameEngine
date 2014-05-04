module wackyRenderInitializer;

private import wackyRender;

class WackyRenderInitializer
{
    public static void initialize (WackyRender render)
    {
        render.setMinimalTimePerFrame(0.016f);
        render.disableVSync();
        render.setExitKeyAndAction(WackyKeys.KEY_ESCAPE, WackyActions.PRESS);

        render.pipeline.setScale(1.0f, 1.0f, 1.0f);
        render.pipeline.setWorldPosition(0.0f, 0.0f, 0.0f);
        render.pipeline.setRotation(0.0f, 0.0f, 0.0f);
        render.pipeline.setPerspectiveData(30.0f, render.windowWidth, render.windowHeight, 1.0f, 1000.0f);

        render.observer.setPosition(0.0f, 0.0f, -10.0f);
        render.observer.setTarget(0.0f, 0.0f, 1.0f);
        render.observer.setUp(0.0f, 1.0f, 0.0f);
        render.observer.setStep(2.0f);
        render.observer.setSensitivity(0.003f);
    }
}
