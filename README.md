# SBCI - Simply Business Continuous Integration

This command-line utility provides an easy way for Jenkins job configuration to be exported to disk.
Great for backup purposes and later restoring to the same or other Jenkins instances.

## Installation

### Through RVM global gemset (recommended)

    rvm gemset use global
    gem install sbci

### Or per project basis only - Gemfile

    gem 'sbci'

## Example Usage

We recommend that you create a .jenkins directory checked into your project git repo to keep a backup of your Jenkins job configuration.

### Exporting / Backing up a job from your Jenkins server
    sbci dump --host localhost --port 8080 --job-name development --path .jenkins

### Restoring / Updating a job from your backup
    sbci publish --host localhost --port 8080 --job-name development --path .jenkins
  
### To view other commands
    sbci --help
