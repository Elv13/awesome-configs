#Forgotten: A simple registry system
====================================

This module is designed to make persistent data storage easy. It is intended
to be used with AwesomeWM, but can be ported to any other Lua scripts.

##Installation

<pre>
cd ~/.config/awesome
git clone git@github.com:Elv13/forgotten.git
</pre>

And add this to your rc.lua:
<pre>
local forgotten = require("forgotten")
</pre>

You are done!

##Usage
Use Forgotten is easy. It does everything for you. To add/set a variable:
<pre>
forgotten.some.domaine.path.my_variable = "Hello World!"
</pre>
This will:
 * Create the domaine path
 * Create the varible if it doesn't already exist
 * Save it to the disk after 5 seconds

Acessing your stored data is as easy:
<pre>
local my_variable = forgotten.some.domaine.path.my_variable
print(my_variable)
>>> Hello World!
</pre>

##Supported data types

 * boolean
 * number
 * string
 * arrays

Not supported:
 * functions
 * userdata
 * thread

##Special variables and functions

|     Name      |                Description                | Read | Write | Default |
| ------------- | ----------------------------------------- | ---- | ----- | ------- |
| **auto_save** | Enable or disable automatic serialization | yes  | yes   | false   |
| **load()**    | Force reloading                           | N\A  | N\A   | N\A     |
| **save()**    | Serialize now                             | N\A  | N\A   | N\A     |
