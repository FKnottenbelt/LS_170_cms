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

### Requirement 12

When a user views the index page, they should see a "delete" button
next to each document.

When a user clicks a "delete" button, the application should delete
the appropriate document and display a message: "$FILENAME was deleted".

### Requirement 13

When a signed-out user views the index page of the site, they should
see a "Sign In" button.

When a user clicks the "Sign In" button, they should be taken to a
new page with a sign in form. The form should contain a text input
labeled "Username" and a password input labeled "Password". The form
should also contain a submit button labeled "Sign In".

When a user enters the username "admin" and password "secret" into
the sign in form and clicks the "Sign In" button, they should be
signed in and redirected to the index page. A message should display
that says "Welcome!"

When a user enters any other username and password into the sign in
form and clicks the "Sign In" button, the sign in form should be
redisplayed and an error message "Invalid Credentials" should be shown.
The username they entered into the form should appear in the username
input.

When a signed-in user views the index page, they should see a message
at the bottom of the page that says "Signed in as $USERNAME.",
followed by a button labeled "Sign Out".

When a signed-in user clicks this "Sign Out" button, they should be
signed out of the application and redirected to the index page of
the site. They should see a message that says "You have been signed
out.".

### Requirement 14

Update all existing tests to use the MockRequest object for verifying
session values. This means that many tests will become shorter as
assertions can be made directly about the session instead of the
content of a response's body. Specifically, instead of loading a
page using get and then checking to see if a given message is
displayed on it, session[:message] can be used to access the session
value directly.

### Requirement 15

When a signed-out user attempts to perform the following actions,
they should be redirected back to the index and shown a message
that says "You must be signed in to do that.":

    Visit the edit page for a document
    Submit changes to a document
    Visit the new document page
    Submit the new document form
    Delete a document

### Requirement 16

An administrator should be able to modify the list of users who may
sign into the application by editing a configuration file using
their text editor.

### Requirement 17

User passwords must be hashed using bcrypt before being stored
so that raw passwords are not being stored anywhere.

### Requirement 18

Add a "duplicate" button that creates a new document based on an
old one.

