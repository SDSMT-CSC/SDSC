<?php
{
  $prop_array = array('Name','Group','Interface');
  include_once('util.php');
  if(isset($_REQUEST['action']))
  {
    switch($_REQUEST['action'])
    {
      case 'Confirm Delete Device':
        $val = remove_node('devices.php', 'devices.ini');
        if($val)
        {
          print $val;
        }
        else
        {
          print get_header('Devices Menu') . print_generic_menu('Devices', 'devices.php', 'devices.ini', array('Edit Device', 'Delete Device'), array('Add Device',) ) . get_content_tail();
        }
        break;
      case 'Delete Device':
        print confirm_remove_node('devices.php');
        break;
      /* Edit Device form */
      case 'Edit Device':
        if(isset($_REQUEST['name']) && format_from_ini($_REQUEST['name'], 'devices.ini'))
        {
          {
            $str = get_header('Edit Device') . print_generic_form('Edit', 'devices.php', 'Device', $prop_array) . get_content_tail();
            print $str;
          }
        }
        else
        {
            print get_header('Devices Menu') . print_generic_menu('Devices', 'devices.php', 'devices.ini', array('Edit Device', 'Delete Device'), array('Add Device',) ) . get_content_tail();
        }
        break;
      case 'Edit':
        $val = validate_generic_form('Edit', 'devices.php', 'Device', $prop_array, 'devices.ini');
        if($val != "")
        {
          print($val);
          break;
        }
        else
        {
          print get_header('Device Menu') . print_generic_menu('Devices', 'devices.php', 'devices.ini', array('Edit Device', 'Delete Device'), array('Add Device',) ) . get_content_tail();
          break;
        }
        break;
      /* Add Device form */
      case 'Add Device':
        print get_header('Add Device') . print_generic_form('Add', 'devices.php', 'Device', $prop_array) . get_content_tail();
        break;
      /* Try to add a device submitted by Add Device */
      case 'Add':
        $val = validate_generic_form('Add', 'devices.php', 'Device', $prop_array, 'devices.ini');
        if($val != "")
        {
          print($val);
          break;
        }
        else
        {
          print get_header('Device Menu') . print_generic_menu('Devices', 'devices.php', 'devices.ini', array('Edit Device', 'Delete Device'), array('Add Device',) ) . get_content_tail();
          break;
        }
      /* If everything else didn't match, print a menu. */
      default: 
        print $_REQUEST['action'];
        print get_header('Devices Menu') . print_generic_menu('Devices', 'devices.php', 'devices.ini', array('Edit Device', 'Delete Device'), array('Add Device',) );
        break;
    }
  }
  else
  {
    $str = get_header('Devices Menu') . print_generic_menu('Devices', 'devices.php', 'devices.ini', array('Edit Device', 'Delete Device'), array('Add Device',) ) . get_content_tail();
    print $str;
  }
}
?>
