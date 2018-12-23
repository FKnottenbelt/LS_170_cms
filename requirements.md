# Introduction

The goal of this project is to build a simple file-based content
management system.

This project uses the filesystem to persist data, and as a result,
it isn't a good fit for Heroku. Applications running on Heroku only
have access to an ephemeral filesystem. This means any files that
are written by a program will be lost each time the application
goes to sleep, is redeployed, or restarts (which typically happens
every 24 hours).

### Requirement 1
When a user visits the path "/", the application should display
the text "Getting started."

### Requirement 2
When a user visits the home page, they should see a list of the
documents in the CMS: history.txt, changes.txt and about.txt:
unorderd list of files when visiting '/'
nb: this have to be actual files in the file system
