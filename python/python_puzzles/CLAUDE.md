# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Python puzzle collection package named `abk-apple` containing string manipulation algorithms. Each puzzle is implemented as a standalone function in its own module with comprehensive unit tests.

## Commands

### Testing
```bash
# Run all tests
python -m pytest tests/

# Run specific test file
python -m pytest tests/test_palindrome.py

# Run tests with verbose output
python -m pytest -v tests/
```

### Package Management
```bash
# Install dependencies (uses uv)
uv sync

# Install in development mode
pip install -e .
```

### Running Individual Modules
```bash
# Run specific test modules directly
python -m unittest tests.test_palindrome

# Run from command line (if main block exists)
python src/abk_apple/palindrome.py
```

## Architecture

### Code Structure
- **src/abk_apple/**: Main package directory containing puzzle solutions
- **tests/**: Unit tests following `test_<module_name>.py` naming convention
- Each puzzle module contains a single `solution()` function as the main entry point
- Test files use `unittest` framework with descriptive test case methods

### Puzzle Module Pattern
Each puzzle follows this structure:
- One main `solution(input_params)` function
- Helper functions defined within the solution scope when needed
- Algorithmic implementations avoid built-in shortcuts to demonstrate fundamental concepts
- Comments include TODO markers for incomplete implementations

### Testing Pattern
- Test classes inherit from `unittest.TestCase`
- Multiple test cases cover edge cases and typical scenarios
- Each test method follows `test_case_N()` naming convention
- Tests import the solution function directly from the puzzle module

## Development Notes

- Project uses Python 3.13+ (specified in pyproject.toml)
- Package managed with uv (lock file present)
- No external dependencies beyond standard library
- Code emphasizes educational value over optimization