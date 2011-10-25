Ram
===

Ram is an asset packaging library, written in Ruby.  It is entirely taken from the Jammit gem, but stripped of any Rails dependencies or helpers.  It was primarily written for packaging nanoc assets, though I suppose it could be used for many types of web development projects.

Installation:
  
    gem install ram
    
Status of Project
=================

Since this is a re-purposed Jammit, this tentatively works tonight, but without any guarantees.  There are 13 failing tests at the moment, but I can get my regular use case working with nanoc.  

If this version of Ram doesn't work for you, you might want to try the [musical version](http://www.youtube.com/watch?v=lpGtqeMH4Rs&feature=youtu.be) instead.

Usage
=====

Basically add a config/assets.yml file in your project (see [Jammit documentation](http://documentcloud.github.com/jammit/) for now).  Then, from your project source:

    ram

I'll put some better documentation together once I'm more comfortable that I have what I want with this gem.

Path Ahead
==========

Just a few things:

* Get the tests running
* Add a few features and feedback in the CLI
* Documentation

License
=======

Copyright (c) 2011 David Richards, Fleet Ventures

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.