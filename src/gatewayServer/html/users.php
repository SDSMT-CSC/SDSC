<?php
{
  $prop_array = array('Name','Group');
  include_once('util.php');
  if(isset($_REQUEST['action']))
  {
    switch($_REQUEST['action'])
    {
      case 'Confirm Delete User':
        $val = remove_node('users.php', 'users.ini');
        if($val)
        {
          print $val;
        }
        else
        {
          print get_header('Users Menu') . print_generic_menu('Users', 'users.php', 'users.ini', array('Edit User', 'Delete User'), array('Add User',) ) . get_content_tail();
        }
        break;
      case 'Delete User':
        print confirm_remove_node('users.php');
        break;
      /* Edit User form */
      case 'Edit User':
        if(isset($_REQUEST['name']) && format_from_ini($_REQUEST['name'], 'users.ini'))
        {
          {
            $str = get_header('Edit User') . print_generic_form('Edit', 'users.php', 'User', $prop_array) . get_content_tail();
            print $str;
          }
        }
        else
        {
            print get_header('Users Menu') . print_generic_menu('Users', 'users.php', 'users.ini', array('Edit User', 'Delete User'), array('Add User',) ) . get_content_tail();
        }
        break;
      case 'Edit':
        $val = validate_generic_form('Edit', 'users.php', 'User', $prop_array, 'users.ini');
        if($val != "")
        {
          print($val);
          break;
        }
        else
        {
          print get_header('User Menu') . print_generic_menu('Users', 'users.php', 'users.ini', array('Edit User', 'Delete User'), array('Add User',) ) . get_content_tail();
          break;
        }
        break;
      /* Add User form */
      case 'Add User':
        print get_header('Add User') . print_generic_form('Add', 'users.php', 'User', $prop_array) . get_content_tail();
        break;
      /* Try to add a user submitted by Add User */
      case 'Add':
        $val = validate_generic_form('Add', 'users.php', 'User', $prop_array, 'users.ini');
        if($val != "")
        {
          print($val);
          break;
        }
        else
        {
          print get_header('User Menu') . print_generic_menu('Users', 'users.php', 'users.ini', array('Edit User', 'Delete User'), array('Add User',) ) . get_content_tail();
          break;
        }
      /* If everything else didn't match, print a menu. */
      default: 
        print $_REQUEST['action'];
        print get_header('Users Menu') . print_generic_menu('Users', 'users.php', 'users.ini', array('Edit User', 'Delete User'), array('Add User',) );
        break;
    }
  }
  else
  {
    $str = get_header('Users Menu') . print_generic_menu('Users', 'users.php', 'users.ini', array('Edit User', 'Delete User'), array('Add User',) ) . get_content_tail();
    print $str;
  }
}
/*
  $topmatter = file_get_contents('header.html');
  $title = $topmatter . "  <title>User Menu - Remote Home Base Station</title>\n </head>\n <body>\n";
  $users = parse_ini_file('users.ini', true, INI_SCANNER_RAW);
  if ($users === False)
  {
    $content = "<p class='error'>Something went wrong, and we could not open the users.ini file for you. A new, empty users file will be made for you, so feel free to add any users you want. If you have already added users to this system, please contact customer service.</p>\n";
  }
  else
  {
    $content = "<h1>Users</h1>\n";
  }
  if(isset($_REQUEST['action']) && $_REQUEST['action'] == 'Delete User')
  {
    $body .= "<p class=\"error\">You cannot delete the last user.</p>\n";
  }
  $content .= "<form action='user_update.php' method='POST'>\n";
  $content .= " <select name='name'>\n";
  foreach ($users as $user => $attrlist)
  {
    $content .= "  <option>$user</option>\n";
  }
  $content .= " </select>\n";
  $content .= " <input type='submit' name='action' value='Edit User' />\n";
  $content .= " <input type='submit' name='action' value='Delete User'/>\n";
  $content .= "</form>\n";
  $content .= "<form action='user_update.php' method='POST'>\n";
  $content .= " <input type='submit' name='action' value='Add User'/>\n";
  $content .= "</form>\n";
  $content .= "</body>\n";
  $content .= "</html>\n";
  print $title;
  print $content;
*/
?>
