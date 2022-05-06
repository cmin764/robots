# Template: Basic Python only robot

Get started with just Python.

This template robot:

- Uses only Python.
- Provides a simple template to start from (`task.py`).

## Learning materials

- [Python basics](https://robocorp.com/docs/languages-and-frameworks/python)
- [Best practices in creating Python robots](https://robocorp.com/docs/development-guide/qa-and-best-practices/python-robots)

## Instructions

1. `rcc run -t venv` -> makes available a *.venv*
2. `rcc run -t which` -> get a path similar to */Users/cmin/.robocorp/holotree/5a1fac3c5_9fcd2534/bin/python*
3. In your **poetry** project (containing *pyproject.toml* file) run `poetry env use <path>`
4. `poetry install` -> creates a local *.venv* based on the **rcc** *.venv* above
5. Add the same `<path>` in your favorite IDE as the Python interpreter to develop with

## Next steps (nice to have)

- `rcc develop` command which self-contains the robot files (*conda.yaml*, *robot.yaml*,
  *setupvenv.sh*) needed to create the virtual environment and initializes **poetry**
  (`poetry install`) with it. (so we don't need a robot structure anymore for this)
  - `rcc develop <path/to/conda.yaml>` will be supported to develop with custom envs
- Making sure the **rcc**'s *.venv* shortcut will cooperate with **poetry**'s *.venv*
  dir and not delete/affect each other.
