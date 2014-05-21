-- Links:
-- * DBus spec: http://dbus.freedesktop.org/doc/dbus-specification.html
-- * GVariant API: https://developer.gnome.org/glib/stable/glib-GVariantType.html
-- * More GVariant info: https://developer.gnome.org/glib/stable/gvariant-format-strings.html

--TODO:
-- Create service object, use function myservice:my_method(sdfsdfs,sdfsdf) end
-- function myservice.property:get_foo() return dsfdfg end
-- add way to call methods after getting a service object
-- handle signals myservice:connect_signal("foo",function(43534,345) end)

local lgi  = require     'lgi'
local Gio  = lgi.require 'Gio'
local core = require     'lgi.core'
local GLib = lgi.require 'GLib'
local type,unpack = type,unpack


--------------
--  OBJECT  --
--------------
--[[
local function create_object()
    local obj = {}
    
    return obj
end]]

--------------
--  LOGIC   --
--------------

-- Get the interface_info from its name
local ifaces = {}
local function iface_lookup(service,name)
    if not ifaces[name] then
        local iface = service.introspection_data:lookup_interface(service.iname)
        ifaces[name] = iface
        return iface
    end
    return ifaces[name]
end

-- Get a method information

local function common_get_info(service,cache,interface_name,method,func)
    if not cache[interface_name] then
        cache[interface_name] = {}
    end
    local iface_sigs = cache[interface_name]

    if not iface_sigs[method] then
        local iface = service:iface_lookup(interface_name)
        if iface then
            local info = iface[func](iface,method)
            if info then
                iface_sigs[method] = info
                return info
            end
        end
    end
    return iface_sigs[method]
end

local function get_property_info(service,interface_name,property)
    local prop_info = {}
    return service:common_get_info(prop_info,interface_name,property,"lookup_property")
end

local function get_method_info(service,interface_name,method)
    local method_info = {}
    return service:common_get_info(method_info,interface_name,method,"lookup_method")
end

local function get_signal_info(service,interface_name,signal)
    local sign_info = {}
    return service:common_get_info(sign_info,interface_name,signal,"lookup_signal")
end



-- Get a method output signature
local function get_out_signature(service,interface_name,method)
    local info = service:get_method_info(interface_name,method)
    if info then
        local ret_t = "("
        for k,v in pairs(info.out_args or {}) do
            ret_t = ret_t .. v.signature
        end
        ret_t = ret_t .. ")"
        return ret_t --TODO add a cache for this
    end
    return ""
end

-----------------------
--  Service methods  --
-----------------------

local function register_object(service,name)
    --------------
    -- CLOSURES --
    --------------


    -- Called when a remote method is called
    -- This closure dispatch the calls to the right function
    local method_call_guard, method_call_addr = core.marshal.callback(Gio.DBusInterfaceMethodCallFunc ,
    function(conn, sender, path, interface_name,method_name,parameters,invok)
        -- Only call if the method have been defined
        if service[method_name] then
            local rets = {service[method_name](service,unpack(parameters.value))}
            local out_sig = service:get_out_signature(interface_name,method_name)

            local gvar = GLib.Variant(out_sig,rets)
            Gio.DBusMethodInvocation.return_value(invok,gvar)
        else
            print("Trying to call "..method_name..[=[ but no implementation was found\n
                please implement myService:]=]..method_name.."(arg1,arg2)")
        end
    end)

    -- Called when there is a property request (get the current value)
    local property_get_guard, property_get_addr = core.marshal.callback(Gio.DBusInterfaceGetPropertyFunc , 
    function(conn, sender, path, interface_name,property_name,parameters,error)
        local sig = service:get_property_info(interface_name,property_name).signature
        print("I get here")
        if service.properties["get_"..property_name] then
            return GLib.Variant(sig,service.properties["get_"..property_name](service))
        else
            print("Trying to read "..property_name..[=[ but no getter was found\n
                please implement myService.properties.get_]=]..property_name)
        end
        return GLib.Variant(sig)
    end)

    -- Called when there is a property request (set the current value)
    local property_set_guard, property_set_addr = core.marshal.callback(Gio.DBusInterfaceSetPropertyFunc , 
    function(conn, sender, path, interface_name,method_name,parameters)
        print("Set a property")
    end)

    local function on_conn_aquired(conn,iname)
        service.introspection_data = Gio.DBusNodeInfo.new_for_xml(service.xml)
        print("The bus is aquired!")
        local iface_info = iface_lookup(service,service.iname)

        --introspection_data
        conn:register_object (
            name,
            iface_info,
            Gio.DBusInterfaceVTable({
            method_call   = method_call_addr ,
            get_property  = property_get_addr,
            set_property  = property_get_addr,
            }),
            {},  --/* user_data */
            lgi.GObject.Closure(function()
            print("Closing the object")
            end),  --/* user_data_free_func */
            lgi.GObject.Closure(function()
            print("There was an error")
            end)
        )
    end
    if service.conn then
        on_conn_aquired(service.conn,service.iname)
    else
        service.on_connection_aquired = on_conn_aquired
    end
end


--------------------
--  Module gears  --
--------------------

local module = {}

-- Create a new service
function module.create_service(iname,xml_introspection)

    --Setup object
    local service = {properties = {},iname = iname,introspection_data=nil,
        get_out_signature = get_out_signature,
        get_property_info = get_property_info,
        get_method_info   = get_method_info,
        common_get_info   = common_get_info,
        iface_lookup      = iface_lookup,
        register_object   = register_object,
        xml               = xml_introspection
    }

    print("attempting to create a server")
    -- Called when the bus is aquired, it is used to register the
    -- XML spec
    local bus_aquired = lgi.GObject.Closure(function(conn, name)
        service.connection = conn
        if service.on_connection_aquired then
            service.on_connection_aquired(conn,name)
            service.on_connection_aquired = nil
        end
    end)

    -- Called when the name is aquired
    local name_aquired = lgi.GObject.Closure(function(conn, name,c,d,e)
        print("The name is aquired!",c,d,e)
    end)

    -- Called when the name is lost
    local name_lost = lgi.GObject.Closure(function(conn, name)
        print("The name is lost!")
    end)


    -- First, aquire the Session bus
    local owner_id = Gio.bus_own_name(Gio.BusType.SESSION,
    iname,                                   --Interface name
    Gio.BusNameOwnerFlags.ALLOW_REPLACEMENT, --We want to take control of the existing service
    bus_aquired,                             --Called when the bus is aquired
    name_aquired,                            -- Called when the name is aquired
    name_lost                                -- Called when the name is lost
    --Errors handling is not implemented
    )
    return service
end








-- Test
local service = module.create_service("com.example.SampleInterface",[=[ <!DOCTYPE node PUBLIC '-//freedesktop//DTD D-BUS Object Introspection 1.0//EN'
  'http://www.freedesktop.org/standards/dbus/1.0/introspect.dtd'>
<node name='/com/example/sample_object'>
  <interface name='com.example.SampleInterface'>
    <method name='Frobate'>
      <arg name='foo' type='i' direction='in'/>
      <arg name='bar' type='s' direction='out'/>
      <arg name='baz' type='a{us}' direction='out'/>
      <!--<annotation name='org.freedesktop.DBus.Deprecated' value='true'/>'-->
    </method>
    <method name='Bazify'>
      <arg name='bar' type='(iiu)' direction='in'/>
      <arg name='bar' type='v' direction='out'/>
    </method>
    <method name='Barify'>
      <arg name='bar' type='a{ss}' direction='in'/>
      <arg name='foo' type='i' direction='in'/>
      <arg name='bar' type='i' direction='out'/>
    </method>
    <method name='Mogrify'>
      <arg name='bar' type='(iiav)' direction='in'/>
    </method>
    <signal name='Changed'>
      <arg name='new_value' type='b'/>
    </signal>
    <property name='Bar' type='s' access='readwrite'/>
    <property name='Bar2' type='s' access='write'/>
  </interface>
  <node name='child_of_sample_object'/>
  <node name='another_child_of_sample_object'/>
</node>]=])


function service:Frobate(integer)
    print("Frobate",integer)
    return "123123123",{[12]="234234",[13]="vxcxcvxcv"}
end

function service:Barify(dict,int)
    print("Barify",dict.werwer,int)
    return 12
end

function service:Bazify ()
    print("Bazify")
end

function service:Mogrify()
    print("Mogrify")
end

function service.properties.get_Bar(service)
    print("property getter!")
    return "foo"
end

service:register_object("/com/example/SampleInterface/Test")
-- service:register_object("/com/example/SampleInterface/Test2")


--TODO check if a mainloop and running or start one

-- This is a test app, so we start the loop directly
local main_loop = GLib.MainLoop()
main_loop:run()

return module