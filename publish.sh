#!/bin/bash
set -e

echo "=== py-clob-client-felix Publishing Script ==="

if ! command -v poetry &> /dev/null; then
    echo "Error: Poetry is not installed. Please install it first:"
    echo "  curl -sSL https://install.python-poetry.org | python3 -"
    exit 1
fi

DRY_RUN=false
BUMP_VERSION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --bump)
            BUMP_VERSION="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: ./publish.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run      Build but don't upload to PyPI"
            echo "  --bump TYPE    Bump version before publishing (patch|minor|major)"
            echo "  -h, --help     Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

CURRENT_VERSION=$(poetry version -s)
echo "Current version: ${CURRENT_VERSION}"

if [ -n "$BUMP_VERSION" ]; then
    echo "Bumping $BUMP_VERSION version..."
    poetry version "$BUMP_VERSION"
    NEW_VERSION=$(poetry version -s)
    echo "New version: ${NEW_VERSION}"
fi

if [ -n "$(git status --porcelain)" ]; then
    echo "Warning: You have uncommitted changes"
    git status --short
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Cleaning previous builds..."
rm -rf dist/ build/ *.egg-info

echo "Building package..."
poetry build

echo "Built packages:"
ls -la dist/

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

if [ "$DRY_RUN" = true ]; then
    echo "Dry run mode - skipping upload to PyPI"
    echo "Package built successfully! To publish manually, run:"
    echo "  poetry publish"
else
    echo "Publishing to PyPI..."

    if [ -n "$PYPI_TOKEN" ]; then
        echo "Using PYPI_TOKEN from environment"
        poetry publish --username __token__ --password "$PYPI_TOKEN"
    else
        echo "No PYPI_TOKEN found. You will be prompted for credentials."
        poetry publish
    fi

    FINAL_VERSION=$(poetry version -s)
    echo "Successfully published py-clob-client-felix ${FINAL_VERSION} to PyPI!"
    echo "View at: https://pypi.org/project/py-clob-client-felix/${FINAL_VERSION}/"
fi

echo "Done!"
