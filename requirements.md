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

### Requirement 3
When a user visits the index page, they are presented with a list of
links, one for each document in the CMS.

When a user clicks on a document link in the index, they should be
taken to a page that displays the content of the file whose name was
clicked.

When a user visits the path /history.txt, they will be presented
with the content of the document history.txt.

The browser should render a text file as a plain text file.

### Requirement 4
Write tests for the routes that the application already supports.
Run them and you should see something similar to this:
2 runs, 12 assertions

### Requirement 5
When a user attempts to view a document that does not exist, they
should be redirected to the index page and shown the message:
$DOCUMENT does not exist.:
message and underneath the ordered list of files

When the user reloads the index page after seeing an error message,
the message should go away.

### Requirement 6
When a user views a document written in Markdown format, the browser
should render the rendered HTML version of the document's content.

### Requirement 7
When a user views the index page, they should see an “Edit” link next
to each document name.

When a user clicks an edit link, they should be taken to an edit page
for the appropriate document.

When a user views the edit page for a document, that document's
content should appear within a textarea:
- url looks like: /changes.txt/edit
- label: Edit content of changes.txt:
- then there is a big textbox that has a placeholder "Documents can
  be edited now"
- underneath the left bottom of the textbox there is a button
  'Save changes'

When a user edits the document's content and clicks a “Save Changes”
button, they are redirected to the index page and are shown a
message: '$FILENAME has been updated.'.

### Requirement 8

Right now the application is using the same data during both development
and testing. This means that as we modify the data as we continue
development, there is a chance we break some of the tests we've already
written.

We currently have two active environments: development and test. Since
our data is stored entirely on the filesystem, though, we can use two
different directories to hold the data for our two environments.

Make it so the test set up their own files (in a test/data directory)
and remove them (incuding the test/data directory) after they are done.

### Requirement 9

When a message is displayed to a user, that message should appear
against a yellow background. (yellow bar)

Messages should disappear if the page they appear on is reloaded.

Text files should continue to be displayed by the browser as plain text.

The entire site (including markdown files, but not text files) should
be displayed in a sans-serif typeface.

### Requirement 10

Add a favicon.ico

### Requirement 11

When a user views the index page, they should see a link that says
"New Document".

When a user clicks the "New Document" link, they should be taken
to a page with a text input labeled "Add a new document:" and a
submit button labeled "Create"

When a user enters a document name and clicks "Create", they should
be redirected to the index page. The name they entered in the form
should now appear in the file list. They should see a message that
says "$FILENAME was created.", where $FILENAME is the name of the
document just created.

If a user attempts to create a new document without a name, the form
should be re-displayed and a message should say "A name is required."
