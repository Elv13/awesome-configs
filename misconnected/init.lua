local lgi = require 'lgi'
local Gio = lgi.require 'Gio'
local core = require 'lgi.core'

local introspection_data = Gio.DBusNodeInfo.new_for_xml([=[<!DOCTYPE node PUBLIC "-//freedesktop//DTD D-BUS Object
    Introspection 1.0//EN"
    "http://www.freedesktop.org/standards/dbus/1.0/introspect.dtd">
    <node>
      <interface name="org.freedesktop.DBus.Introspectable">
        <method name="Introspect">
          <arg name="data" direction="out" type="s"/>
        </method>
      </interface>
      <interface name="org.freedesktop.Notifications">
        <method name="GetCapabilities">
          <arg name="caps" type="as" direction="out"/>
        </method>
        <method name="CloseNotification">
          <arg name="id" type="u" direction="in"/>
        </method>
        <method name="Notify">
          <arg name="app_name" type="s" direction="in"/>
          <arg name="id" type="u" direction="in"/>
          <arg name="icon" type="s" direction="in"/>
          <arg name="summary" type="s" direction="in"/>
          <arg name="body" type="s" direction="in"/>
          <arg name="actions" type="as" direction="in"/>
          <arg name="hints" type="a{sv}" direction="in"/>
          <arg name="timeout" type="i" direction="in"/>
          <arg name="return_id" type="u" direction="out"/>
        </method>
        <method name="GetServerInformation">
          <arg name="return_name" type="s" direction="out"/>
          <arg name="return_vendor" type="s" direction="out"/>
          <arg name="return_version" type="s" direction="out"/>
          <arg name="return_spec_version" type="s" direction="out"/>
        </method>
        <method name="GetServerInfo">
          <arg name="return_name" type="s" direction="out"/>
          <arg name="return_vendor" type="s" direction="out"/>
          <arg name="return_version" type="s" direction="out"/>
       </method>
      </interface>
      <interface name='de.piware.Demo.Hello'>
        <method name='hello'>
            <arg type='s' name='greeting' direction='in'/>
            <arg type='s' name='response' direction='out'/>
            </method>
            <property type='i' name='number' access='readwrite'/>"
        </interface>
    </node>]=])
    
print(introspection_data)

print(lgi.GObject.Closure)
print("sdfsdf",Gio.BusNameOwnerFlags.NONE)

local function method_call(conn, sender, object_path, iface_name, method_name, parameters, invocation, user_data)
    print("In method call",conn, sender, object_path, iface_name, method_name, parameters, invocation, user_data)
end

local function set_property()
    print("In method cal3")
    
end

local function get_property()
    print("In method call34")
    
end

local clos1 = lgi.GObject.Closure(function(conn, name)
    print("On bus qau",conn,name)
    
    print("dfsf",core.marshal,core.marshal.callback)
    local get_prop_guard, get_prop_addr = core.marshal.callback(Gio.DBusInterfaceGetPropertyFunc, get_property)
    local method_call_guard, method_call_addr = core.marshal.callback(Gio.DBusInterfaceMethodCallFunc , method_call)
    local set_prop_guard, set_prop_addr = core.marshal.callback(Gio.DBusInterfaceSetPropertyFunc, set_property)
    
    
    local vtable = Gio.DBusInterfaceVTable()--{method_call=method_call,get_property=get_property,set_property = set_property})
    vtable.method_call  = method_call_addr
    vtable.get_property = get_prop_addr
    vtable.set_property = set_prop_addr

--     local node_info = Gio.DBusNodeInfo.new_for_xml(introspection_xml)
--     
    
--     local iface_info = introspection_data:lookup_interface('org.freedesktop.DBus.Introspectable')
--     
--     local registration_id,vat = conn:register_object (
--         "/",
--         iface_info,
--         vtable,
--         nil,  --/* user_data */
--         nil,  --/* user_data_free_func */
--         nil); --/* GError** */
--         
--         
    local iface_info2 = introspection_data:lookup_interface('org.freedesktop.Notifications')
    
    local registration_id2,vat2 = conn:register_object (
        "/",
        iface_info2,
        vtable,
        nil,  --/* user_data */
        nil,  --/* user_data_free_func */
        nil); --/* GError** */
        
    local iface_info3 = introspection_data:lookup_interface('de.piware.Demo.Hello')
    
    local registration_id3,vat3 = conn:register_object (
        "/",
        iface_info3,
        vtable,
        nil,  --/* user_data */
        nil,  --/* user_data_free_func */
        nil); --/* GError** */
        
    print(registration_id,vat)
end)
local clos2 = lgi.GObject.Closure(function()
    print("On name")
end)
local clos3 = lgi.GObject.Closure(function()
    print("On name lost")
end)

local owner_id = Gio.bus_own_name(Gio.BusType.SESSION,"org.gtk.GDBus.TestServer"
,Gio.BusNameOwnerFlags.NONE,clos1,clos2,clos3)
print("bus id",owner_id)