# /pytest

Run Python tests using pytest with coverage reporting.

## Usage
```
/pytest [options] [file_or_directory]
```

## What it does
1. Discovers and runs all tests in the project
2. Generates coverage report
3. Identifies failing tests
4. Suggests fixes for failures
5. Recommends additional test cases

## Examples
```
/pytest                    # Run all tests
/pytest tests/            # Run tests in specific directory  
/pytest --focus failing   # Focus on failing tests
/pytest --coverage        # Emphasize coverage gaps
```

## Process
1. Check pytest installation
2. Discover test files
3. Run tests with coverage
4. Analyze failures if any
5. Report coverage gaps
6. Suggest improvements

## Options
- `--verbose`: Detailed output
- `--coverage`: Focus on coverage analysis
- `--fix`: Attempt to fix failing tests
- `--quick`: Run only fast tests (marked with @pytest.mark.fast)