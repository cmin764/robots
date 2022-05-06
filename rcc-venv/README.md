# Manage Python venv through rcc

## Instructions

1. `rcc run` -> makes available a *.venv* and prints a path similar to
   */Users/cmin/.robocorp/holotree/5a1fac3c5_9fcd2534/bin/python*
2. Activate the virtual environment created above: `. .venv/bin/activate`
3. In your **poetry** project (containing *pyproject.toml* file) run
   `poetry env use <path>` with the path at step **1.**
4. `poetry install` -> creates a local *.venv* based on the **rcc** *.venv* above
5. Add the same `<path>` in your favorite IDE as the Python interpreter to develop with

## Next steps (nice to have)

- `rcc develop` command which self-contains the robot files (*conda.yaml*, *robot.yaml*,
  *setupvenv.sh*) needed to create the virtual environment and initializes **poetry**
  (`poetry install`) with it. (so we don't need a robot structure anymore for this)
  - `rcc develop <path/to/conda.yaml>` will be supported to develop with custom envs
- Making sure the **rcc**'s *.venv* shortcut will cooperate with **poetry**'s *.venv*
  dir and not delete/affect each other.
  - Caveat: After a while the *activate* script goes away, I guess **poetry** removes
    it.
