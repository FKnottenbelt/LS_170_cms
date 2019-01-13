## Sinatra app for a filebased CMS webapp

Based on [these requirements](requirements.md)

***
Home page:

![homepage](/public/images/cms.png)

***


#### Getting started

To get started with the app, clone the repo and then install the needed gems:

```
$ bundle install --without production
```
Run the test suite to verify that everything is working correctly:

```
$ rake
```

If the test suite passes, you'll be ready to run the app in a local server:

```
$ ruby cms.rb
```
