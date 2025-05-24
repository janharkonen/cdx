# cdx

A fast and intuitive directory navigation tool for Linux that lets you quickly `cd` into directories using fuzzy search.

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/janharkonen/cdx.git /home/[username]/[path]/cdx
   ```

2. Add the following line to your `~/.bashrc`:
   ```bash
   source /home/[username]/[path]/cdx/bash_function.sh
   ```

3. Reload your shell configuration:
   ```bash
   source ~/.bashrc
   ```

## Usage

Simply type `cdx` followed by any part of the directory name you want to navigate to. The tool will present you with a fuzzy-searchable list of matching directories.

Example:
   ```bash
   cdx my_project
   ```
For any help just type:
   ```bash
   cdx --help
   ```
