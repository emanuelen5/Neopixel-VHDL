library ieee ;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

use work.neopixel_pkg.all;
library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

package message_types_pkg is

  ------------------------------------------------------------------------------
  -- NB. Records cannot be used yet in message passing, so they have been split
  --     and each signal is passed by its own...
  ------------------------------------------------------------------------------

  type color_m_msg_type_t is (color_m);
  type color_m_msg_t is record
    msg_type  : color_m_msg_type_t;
    red       : color_t;
    green     : color_t;
    blue      : color_t;
  end record color_m_msg_t;

  type reply_msg_type_t is (get_status_reply);
  type reply_msg_t is record
    msg_type : reply_msg_type_t;
    done     : boolean;
  end record reply_msg_t;

  ------------------------------------------------------------------------------
  -- Conversion functions from messages to buses
  ------------------------------------------------------------------------------
  function to_rgb_color_t (
    constant color_m_msg : color_m_msg_t
  ) return rgb_color_t;

  procedure write (
    signal net : inout network_t;
    constant actor : in actor_t;
    constant color : in rgb_color_t
  );

  procedure read (
    signal net : inout network_t;
    constant actor : in actor_t;
    variable color : out rgb_color_t
  );

end package; -- message_types_pkg

package body message_types_pkg is
  function to_rgb_color_t (
    constant color_m_msg : color_m_msg_t
  ) return rgb_color_t is
    variable ret_val : rgb_color_t;
  begin
    ret_val.red := color_m_msg.red;
    ret_val.green := color_m_msg.green;
    ret_val.blue := color_m_msg.blue;
    return ret_val;
  end function;

  procedure write (
    signal net : inout network_t;
    constant actor : in actor_t;
    constant color : in rgb_color_t
  ) is
    variable msg : msg_t := new_msg;
  begin
    push(msg, color.red);
    push(msg, color.green);
    push(msg, color.blue);
    send(net, actor, msg);
  end procedure;

  procedure read (
    signal net : inout network_t;
    constant actor : in actor_t;
    variable color : out rgb_color_t
  ) is
    variable msg : msg_t;
  begin
    receive(net, actor, msg);
    color.red := pop(msg);
    color.green := pop(msg);
    color.blue := pop(msg);
    delete(msg);
  end procedure read;
end package body message_types_pkg;